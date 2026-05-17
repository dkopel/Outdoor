import Foundation

/// A safety rule as parsed from `safety_rules.yaml`. Mirrors the schema documented in
/// `docs/safety-rules-spec.md`.
struct SafetyRule: Hashable {
    let intent: String
    let match: [String]
    let risk: String
    let answerMode: String
    let mustInclude: [String]
    let refusePatterns: [String]
}

/// Result of routing a user query through the SafetyRouter.
struct RouteDecision: Hashable {
    let intent: String
    let answerMode: String
    let risk: String
    let mustInclude: [String]

    var isRefusal: Bool { answerMode == "refuse_with_warning" }
    var bypassesLLM: Bool {
        answerMode == "locked_procedure" || isRefusal
    }
    var showsSafetyAppendix: Bool { answerMode == "rag_with_safety_appendix" }

    static let general = RouteDecision(
        intent: "general",
        answerMode: "rag_freeform",
        risk: "low",
        mustInclude: []
    )
}
