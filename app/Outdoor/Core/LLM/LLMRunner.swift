import Foundation

/// The on-device LLM as a streaming text producer.
///
/// `ChatViewModel` doesn't care whether tokens come from MLX-Swift running a
/// 4-bit Llama, from a mock returning canned text in unit tests, or from a
/// future cloud bridge. It only cares that calling `stream(...)` returns an
/// `AsyncThrowingStream<String, Error>` of token chunks (each may be one or
/// more characters).
///
/// Implementations:
///  - `MockLLMRunner`     — canned output for previews and unit tests
///  - `MLXLLMRunner`      — real on-device Llama via MLX-Swift (Phase 3)
///
/// See `docs/prompt-spec.md` for the prompt contract these runners consume.
protocol LLMRunner: Sendable {
    /// Stream a completion for the given system prompt + user message.
    ///
    /// - Parameters:
    ///   - systemPrompt: the role=system message body
    ///   - userMessage: the role=user message body (already includes context block)
    ///   - temperature: sampling temperature (0..1)
    ///   - maxTokens: hard cap on generation length
    /// - Returns: an `AsyncThrowingStream` of token chunks. Concatenating
    ///   all yielded values produces the full answer text.
    func stream(
        systemPrompt: String,
        userMessage: String,
        temperature: Double,
        maxTokens: Int
    ) -> AsyncThrowingStream<String, Error>
}


/// Default sampling parameters — keep in sync with `docs/prompt-spec.md`.
enum LLMDefaults {
    static let temperature: Double = 0.3
    static let topP: Double = 0.9
    static let maxTokens: Int = 512
}


// ============================================================================
// Mock runner
// ============================================================================

/// Returns a canned answer one short fragment at a time. Used in:
///  - SwiftUI previews
///  - Unit tests (so they don't need MLX or a model on disk)
///  - The simulator when no real model has been downloaded yet
///
/// The mock attempts to cite every chunk_id mentioned in the user message so
/// citation validation can be exercised. If no chunk ids are found it still
/// produces an answer (used to verify the "no citations → warn user" path).
struct MockLLMRunner: LLMRunner {

    /// How long to pause between token chunks. Set very low for tests.
    let perTokenDelay: Duration

    /// Override the canned reply. Pass `nil` to use the default builder.
    let cannedAnswer: String?

    init(perTokenDelay: Duration = .milliseconds(40), cannedAnswer: String? = nil) {
        self.perTokenDelay = perTokenDelay
        self.cannedAnswer = cannedAnswer
    }

    func stream(
        systemPrompt: String,
        userMessage: String,
        temperature: Double,
        maxTokens: Int
    ) -> AsyncThrowingStream<String, Error> {
        // Pull chunk ids out of the user message so the mock can cite them.
        let answer = cannedAnswer ?? Self.makeAnswer(from: userMessage)
        // Stream word-by-word so the UI gets to render incremental updates.
        let tokens = Self.tokenize(answer)
        let delay = perTokenDelay
        return AsyncThrowingStream { continuation in
            let task = Task {
                for tok in tokens {
                    if Task.isCancelled {
                        continuation.finish()
                        return
                    }
                    continuation.yield(tok)
                    try? await Task.sleep(for: delay)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    /// Build a deterministic answer that references whatever chunk ids are
    /// in the user message. Useful for snapshot tests and previews.
    private static func makeAnswer(from userMessage: String) -> String {
        let ids = extractChunkIds(from: userMessage)
        if ids.isEmpty {
            return "I don't see grounded content to cite. Please retry."
        }
        var sentences: [String] = []
        sentences.append("Here's what your pack covers \(citationFor(ids[0])).")
        if ids.count > 1 {
            sentences.append("Cross-reference for safety \(citationFor(ids[1])).")
        }
        sentences.append("Seek professional help if conditions warrant.")
        return sentences.joined(separator: " ")
    }

    private static func extractChunkIds(from text: String) -> [String] {
        let pattern = "\\[([a-z0-9_-]+\\.[a-z0-9_-]+(?:#[0-9\\.]+)?)\\]"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }
        let ns = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: ns.length))
        var out: [String] = []
        var seen = Set<String>()
        for m in matches where m.numberOfRanges >= 2 {
            let id = ns.substring(with: m.range(at: 1))
            if seen.insert(id).inserted {
                out.append(id)
            }
        }
        return out
    }

    private static func citationFor(_ id: String) -> String { "[\(id)]" }

    /// Naive whitespace tokenization for streaming. Keeps trailing whitespace
    /// so the rendered text reads naturally as words arrive.
    private static func tokenize(_ s: String) -> [String] {
        var result: [String] = []
        var current = ""
        for ch in s {
            current.append(ch)
            if ch == " " || ch == "\n" {
                result.append(current)
                current = ""
            }
        }
        if !current.isEmpty {
            result.append(current)
        }
        return result
    }
}


// ============================================================================
// MLX runner (real, gated on package availability)
// ============================================================================

#if canImport(MLXLLM) && canImport(MLXLMCommon)

import MLXLLM
import MLXLMCommon

/// On-device LLM runner backed by MLX-Swift.
///
/// Loads a 4-bit quantized Llama 3.2 model and streams generated tokens.
/// Model files are downloaded from HuggingFace on first use and cached to
/// `~/Library/Application Support/Outdoor/Models/<id>/`.
///
/// **Not** marked `@MainActor` — MLX inference is CPU/GPU heavy, kept off the
/// main actor on purpose. Token chunks are delivered via `AsyncThrowingStream`
/// which ChatViewModel iterates on the main actor.
final class MLXLLMRunner: LLMRunner, @unchecked Sendable {

    /// HuggingFace repo id of the chosen model. Default matches
    /// `docs/llm-model-choice.md` § primary candidate.
    let modelId: String

    /// Lazily-loaded model + tokenizer. Loading is expensive (~1–3 s on M-series
    /// Mac, longer on iPhone), so the container is created once and reused.
    private var container: ModelContainer?
    private let loadLock = NSLock()

    init(modelId: String = "mlx-community/Llama-3.2-3B-Instruct-4bit") {
        self.modelId = modelId
    }

    func stream(
        systemPrompt: String,
        userMessage: String,
        temperature: Double,
        maxTokens: Int
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let container = try await self.ensureLoaded()
                    let chat: [Chat.Message] = [
                        .system(systemPrompt),
                        .user(userMessage),
                    ]
                    let userInput = UserInput(chat: chat)
                    let params = GenerateParameters(
                        maxTokens: maxTokens,
                        temperature: Float(temperature),
                        topP: Float(LLMDefaults.topP)
                    )
                    try await container.perform { context in
                        let lmInput = try await context.processor.prepare(input: userInput)
                        let stream = try MLXLMCommon.generate(
                            input: lmInput,
                            parameters: params,
                            context: context
                        )
                        for await event in stream {
                            if Task.isCancelled { break }
                            if case .chunk(let chunk) = event {
                                continuation.yield(chunk)
                            }
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    /// Load the model on first call; subsequent calls return the cached container.
    private func ensureLoaded() async throws -> ModelContainer {
        loadLock.lock()
        if let c = container {
            loadLock.unlock()
            return c
        }
        loadLock.unlock()

        let configuration = ModelConfiguration(id: modelId)
        let c = try await LLMModelFactory.shared.loadContainer(configuration: configuration)

        loadLock.lock()
        container = c
        loadLock.unlock()
        return c
    }
}

#else

/// Fallback stub when MLXLLM isn't available (e.g. package fetch failed offline,
/// or building on a non-Apple platform). Throws a clear error so callers know
/// to fall back to MockLLMRunner.
struct MLXLLMRunner: LLMRunner {
    let modelId: String
    init(modelId: String = "mlx-community/Llama-3.2-3B-Instruct-4bit") {
        self.modelId = modelId
    }
    func stream(
        systemPrompt: String,
        userMessage: String,
        temperature: Double,
        maxTokens: Int
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            continuation.finish(throwing: LLMRunnerError.unavailable(
                "MLXLLM not available in this build. Use MockLLMRunner."
            ))
        }
    }
}

#endif


enum LLMRunnerError: LocalizedError {
    case unavailable(String)

    var errorDescription: String? {
        switch self {
        case .unavailable(let msg): return msg
        }
    }
}
