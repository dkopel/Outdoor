import Foundation

/// Classifies user queries against the active pack's safety rules.
/// Mirrors `pack_builder.safety.classify` so behavior is identical between
/// the Python CLI demo and the iOS runtime.
enum SafetyRouter {

    /// Run rules in order. First matching rule wins. Refusal patterns within
    /// a rule are checked before its `match` list — if a refuse pattern hits,
    /// the answer is forced to `refuse_with_warning`.
    static func classify(_ query: String, rules: [SafetyRule]) -> RouteDecision {
        let q = query.lowercased()
        for rule in rules {
            for pattern in rule.refusePatterns {
                if matches(pattern: pattern, in: q) {
                    return RouteDecision(
                        intent: rule.intent,
                        answerMode: "refuse_with_warning",
                        risk: rule.risk.isEmpty ? "high" : rule.risk,
                        mustInclude: rule.mustInclude
                    )
                }
            }
            for kw in rule.match {
                if q.contains(kw.lowercased()) {
                    return RouteDecision(
                        intent: rule.intent,
                        answerMode: rule.answerMode,
                        risk: rule.risk.isEmpty ? "low" : rule.risk,
                        mustInclude: rule.mustInclude
                    )
                }
            }
        }
        return .general
    }

    /// Tolerant pattern match: literal substring first, regex fallback.
    private static func matches(pattern: String, in text: String) -> Bool {
        let p = pattern.lowercased()
        if text.contains(p) { return true }
        if let re = try? NSRegularExpression(pattern: p, options: [.caseInsensitive]) {
            let range = NSRange(text.startIndex..., in: text)
            return re.firstMatch(in: text, options: [], range: range) != nil
        }
        return false
    }
}
