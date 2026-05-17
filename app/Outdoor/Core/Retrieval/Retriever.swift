import Foundation

/// Façade over `PackDatabase`. Adds safety routing and post-filters so the rest
/// of the app doesn't need to know about pack internals.
@MainActor
final class Retriever {

    private let database: PackDatabase
    private let safetyRules: [SafetyRule]

    init(database: PackDatabase, safetyRules: [SafetyRule]) {
        self.database = database
        self.safetyRules = safetyRules
    }

    struct Result {
        let decision: RouteDecision
        let chunks: [RetrievedChunk]
    }

    /// Run the query: classify intent, decide answer mode, then retrieve
    /// chunks unless the query is refused outright.
    /// SQLite queries are sub-ms on the pack sizes we ship, so we run
    /// synchronously on the main actor. Phase 3 (LLM streaming) is where
    /// real async work shows up.
    func search(_ query: String, limit: Int = 6) -> Result {
        let decision = SafetyRouter.classify(query, rules: safetyRules)
        if decision.isRefusal {
            return Result(decision: decision, chunks: [])
        }
        let chunks = (try? database.search(query, limit: limit)) ?? []
        return Result(decision: decision, chunks: chunks)
    }
}
