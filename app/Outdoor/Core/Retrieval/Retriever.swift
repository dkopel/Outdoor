import Foundation

/// Retrieval-contract API. Phase 3's PromptBuilder consumes this directly.
///
/// See `docs/retrieval-llm-contract.md` for the canonical spec. Default args
/// per contract: `k = 5`, `keywordWeight = 0.3`, `vectorWeight = 0.7`.
public protocol Retriever: Sendable {
    func query(
        _ text: String,
        k: Int,
        keywordWeight: Double,
        vectorWeight: Double
    ) async throws -> [RetrievedChunk]
}

public extension Retriever {
    /// Convenience overload with contract defaults.
    func query(_ text: String) async throws -> [RetrievedChunk] {
        try await query(text, k: 5, keywordWeight: 0.3, vectorWeight: 0.7)
    }
}

/// FTS5-backed retriever, the v1 concrete implementation.
///
/// Phase 3 vector layer plugs in here (or as a peer behind the same protocol).
/// SQLite reads are sub-ms on pack sizes we ship, so `query` runs synchronously
/// inside the async wrapper — the `async` signature is for forward-compat with
/// the vector path which will likely use a Metal kernel.
public struct FTS5Retriever: Retriever {
    private let database: PackDatabase

    public init(database: PackDatabase) {
        self.database = database
    }

    public func query(
        _ text: String,
        k: Int,
        keywordWeight: Double,
        vectorWeight: Double
    ) async throws -> [RetrievedChunk] {
        try database.search(
            text,
            limit: k,
            keywordWeight: keywordWeight,
            vectorWeight: vectorWeight
        )
    }
}

/// Façade that pairs a Retriever with the active pack's safety rules and
/// returns a packaged result the UI can render. Used by ChatViewModel +
/// EmergencyView. Phase 3 wraps this with a PromptBuilder + LLM streamer.
@MainActor
public final class RetrievalService {

    public struct Result {
        public let decision: RouteDecision
        public let chunks: [RetrievedChunk]
    }

    private let retriever: Retriever
    private let safetyRules: [SafetyRule]

    public init(retriever: Retriever, safetyRules: [SafetyRule]) {
        self.retriever = retriever
        self.safetyRules = safetyRules
    }

    /// Classify the intent, then retrieve unless safety routing refuses.
    public func answer(
        _ query: String,
        k: Int = 5
    ) async -> Result {
        let decision = SafetyRouter.classify(query, rules: safetyRules)
        if decision.isRefusal {
            return Result(decision: decision, chunks: [])
        }
        let chunks = (try? await retriever.query(query, k: k,
                                                 keywordWeight: 0.3,
                                                 vectorWeight: 0.7)) ?? []
        return Result(decision: decision, chunks: chunks)
    }
}
