import Foundation
import SwiftUI

/// Owns the chat conversation, the active pack, and the LLM streaming task.
///
/// Pipeline on `send(...)`:
///   1. Retriever runs (FTS + safety routing) — synchronous, sub-ms.
///   2. Route on the resulting `RouteDecision`:
///       - `refuse_with_warning`     → fixed refusal text, no LLM call.
///       - `locked_procedure`        → render procedure card from chunks, no LLM call.
///       - empty / no kept chunks    → "pack doesn't cover this" message, no LLM call.
///       - `rag_freeform` / `rag_with_safety_appendix`
///                                   → build prompt, start LLM stream, append a
///                                     streaming assistant message that mutates
///                                     as tokens arrive.
///   3. When the stream finishes, validate citations (strip invented ids) and
///      flip the answer source from `.streaming` to `.complete(...)`.
///
/// The LLM runner is injected so we can swap MLX for a mock in previews / tests
/// without touching this code.
@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var input: String = ""
    @Published var isThinking: Bool = false

    let packManager: PackManager
    let runner: LLMRunner

    /// The currently-running LLM stream task, if any. Sending a new message
    /// cancels it so we don't have two streams writing to the message list.
    private var streamTask: Task<Void, Never>?

    init(packManager: PackManager, runner: LLMRunner = MockLLMRunner()) {
        self.packManager = packManager
        self.runner = runner
    }

    deinit {
        streamTask?.cancel()
    }

    var canSend: Bool {
        !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isThinking
    }

    func send(prompt: String? = nil) {
        let text = (prompt ?? input).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        input = ""

        // Cancel any in-flight stream from the previous turn.
        streamTask?.cancel()
        streamTask = nil

        messages.append(ChatMessage.user(text))

        // No pack → friendly nudge, skip retrieval and LLM entirely.
        guard let db = packManager.activeDatabase else {
            messages.append(ChatMessage(
                role: .assistant,
                kind: .emptyResult(decision: .general),
                text: "No pack is installed. Open the Packs tab and install the Camping pack to get started.",
                timestamp: .now
            ))
            return
        }

        isThinking = true
        let service = RetrievalService(
            retriever: FTS5Retriever(database: db),
            safetyRules: packManager.activeSafetyRules
        )
        Task { @MainActor [weak self] in
            let result = await service.answer(text, k: PromptBuilder.defaultK)
            self?.continueAfterRetrieval(query: text, result: result)
        }
    }

    /// Continues the `send` pipeline after the async retrieval completes.
    /// Splitting this out lets `send` stay sync-callable from a button tap
    /// while retrieval awaits without blocking the UI.
    private func continueAfterRetrieval(query text: String, result: RetrievalService.Result) {
        // Apply Phase 3 score filtering on top of Retriever's raw output.
        let filtered = PromptBuilder.filterByScore(result.chunks)

        // ---- Bypass-LLM branches ----

        if result.decision.isRefusal {
            isThinking = false
            messages.append(ChatMessage(
                role: .assistant,
                kind: .refusal(decision: result.decision),
                text: PromptBuilder.refusalText(for: result.decision),
                timestamp: .now,
                answerSource: .retrievalOnly
            ))
            return
        }

        if filtered.noneKept {
            isThinking = false
            messages.append(ChatMessage(
                role: .assistant,
                kind: .emptyResult(decision: result.decision),
                text: PromptBuilder.refusalNoContext,
                timestamp: .now,
                answerSource: .retrievalOnly
            ))
            return
        }

        if result.decision.answerMode == "locked_procedure" {
            isThinking = false
            messages.append(ChatMessage(
                role: .assistant,
                kind: .assistantAnswer(chunks: filtered.kept, decision: result.decision),
                text: lockedProcedureFraming(for: result.decision),
                timestamp: .now,
                answerSource: .lockedProcedure
            ))
            return
        }

        // ---- Normal RAG path: build prompt and stream the LLM ----

        let userMessage = PromptBuilder.buildUserMessage(
            query: text,
            chunks: filtered.kept,
            decision: result.decision,
            lowConfidence: filtered.allWeak
        )

        // Append a streaming placeholder message. Its `text` starts empty and
        // grows as tokens arrive; `answerSource` flips to `.complete(...)`
        // when the stream ends.
        let placeholder = ChatMessage(
            role: .assistant,
            kind: .assistantAnswer(chunks: filtered.kept, decision: result.decision),
            text: "",
            timestamp: .now,
            answerSource: .streaming
        )
        let placeholderIndex = messages.count
        messages.append(placeholder)

        // Kick off the LLM stream on a background task and pipe tokens into the
        // placeholder message back on the main actor.
        let retrievedIds = filtered.kept.map { $0.chunkId }
        let runner = self.runner

        streamTask = Task { [weak self] in
            var accumulated = ""
            do {
                let stream = runner.stream(
                    systemPrompt: SystemPrompt.text,
                    userMessage: userMessage,
                    temperature: LLMDefaults.temperature,
                    maxTokens: LLMDefaults.maxTokens
                )
                for try await chunk in stream {
                    if Task.isCancelled { break }
                    accumulated += chunk
                    await self?.appendStreamingChunk(accumulated, at: placeholderIndex)
                }
            } catch is CancellationError {
                // expected when the user sends another message mid-stream
            } catch {
                await self?.finishStreamWithError(error, at: placeholderIndex)
                return
            }

            if Task.isCancelled { return }
            await self?.finalizeStream(
                accumulated: accumulated,
                retrievedIds: retrievedIds,
                at: placeholderIndex
            )
        }
    }

    func clear() {
        streamTask?.cancel()
        streamTask = nil
        messages.removeAll()
        isThinking = false
    }

    /// Cancel any in-flight LLM stream. Called when the view disappears or the
    /// user explicitly aborts.
    func cancelStreaming() {
        streamTask?.cancel()
        streamTask = nil
        isThinking = false
    }

    // MARK: - Streaming helpers

    /// Update the placeholder message's body. Runs on the main actor so
    /// `@Published messages` republishes correctly.
    private func appendStreamingChunk(_ accumulated: String, at index: Int) {
        guard messages.indices.contains(index) else { return }
        messages[index].text = accumulated
        // Once any text has arrived, drop the "thinking" indicator — the
        // streaming bubble itself communicates progress now.
        if isThinking, !accumulated.isEmpty {
            isThinking = false
        }
    }

    /// Stream completed normally. Run citation validation on the full answer,
    /// strip invented chunk ids, and flip the answer source to `.complete`.
    private func finalizeStream(
        accumulated: String,
        retrievedIds: [String],
        at index: Int
    ) {
        guard messages.indices.contains(index) else { return }
        let validation = PromptBuilder.validateCitations(
            in: accumulated,
            retrievedIds: retrievedIds
        )
        var finalText = validation.cleanedAnswer
        if validation.validCitations.isEmpty && !finalText.isEmpty {
            // Model produced an answer with no valid citations — flag it.
            finalText = "⚠️ Answer is not grounded in the pack — verify with a trusted source.\n\n" + finalText
        } else if finalText.isEmpty {
            // Stream produced nothing at all — fall back to a polite refusal.
            finalText = PromptBuilder.refusalLowConfidence
        }
        messages[index].text = finalText
        messages[index].answerSource = .complete(
            validCitations: validation.validCitations,
            strippedCitations: validation.strippedCitations
        )
        isThinking = false
        streamTask = nil
    }

    private func finishStreamWithError(_ error: Error, at index: Int) {
        guard messages.indices.contains(index) else { return }
        let msg = "Couldn't reach the on-device model. Showing retrieved excerpts only."
        messages[index].text = msg
        messages[index].answerSource = .retrievalOnly
        isThinking = false
        streamTask = nil
    }

    // MARK: - Copy

    private func lockedProcedureFraming(for decision: RouteDecision) -> String {
        if !decision.mustInclude.isEmpty {
            return decision.mustInclude.joined(separator: "\n\n")
        }
        return "These are the field steps from your pack. Treat them as a reference — get to professional care as soon as conditions allow."
    }
}
