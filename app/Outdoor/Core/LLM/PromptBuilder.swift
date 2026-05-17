import Foundation

/// Swift port of `pack-builder/src/pack_builder/rag.py`.
///
/// Builds the system + user prompts the on-device LLM consumes, validates
/// citations after the model finishes, and applies the score-based filtering
/// rules defined in `docs/prompt-spec.md`.
///
/// All public functions here are **pure** — they take inputs, return outputs,
/// no I/O, no state. That makes them trivially testable, mirrors the Python
/// reference implementation, and matches the unit tests in
/// `pack-builder/tests/test_rag_prompt.py`. Any deviation in behavior between
/// Python and Swift is a contract violation and a bug.
enum PromptBuilder {

    // MARK: - Constants (keep in sync with rag.py + prompt-spec.md)

    /// Score threshold above which a match is considered "strong" — no
    /// low-confidence prefix is added.
    static let strongMatchThreshold: Double = 0.6
    /// Score threshold below which a chunk is dropped entirely. If no chunks
    /// survive this filter, the LLM is not called and the standard
    /// "no relevant chunks" refusal is returned.
    static let weakMatchThreshold: Double = 0.4
    /// Hard cap on chunk text included in the prompt. Truncates with an ellipsis.
    static let chunkTextCapChars: Int = 1500
    /// Default number of chunks to retrieve / include.
    static let defaultK: Int = 5

    // MARK: - Refusal templates (must match prompt-spec.md exactly)

    static let refusalNoContext =
        "The downloaded Camping pack does not cover this. " +
        "Try downloading a more specific pack for this topic."

    static let refusalLowConfidence =
        "I'm not confident enough to answer this from your downloaded pack. " +
        "Please check a regional field guide or a local expert."

    static let refusalEdibility =
        "I will not assess whether any wild plant or animal is safe to eat. " +
        "Always confirm edibility with a trained local expert or trusted field guide."

    static let refusalDosage =
        "I will not give medication dosages. " +
        "Use the dosing instructions on the medication's own packaging or call Poison Control (1-800-222-1222 in the U.S.)."

    static let refusalDiagnosis =
        "I will not diagnose medical conditions. " +
        "If you are concerned about an injury or illness, seek professional medical care."

    static let lowConfidencePrefix =
        "NOTE: low-confidence match — answer cautiously and recommend the user " +
        "check a regional guide."

    /// Maps SafetyRouter intents to the appropriate fixed refusal string.
    static let intentRefusalMap: [String: String] = [
        "medication_dosage":   refusalDosage,
        "plant_id_edibility":  refusalEdibility,
        "animal_id_edibility": refusalEdibility,
    ]

    // MARK: - Score filtering

    struct FilterResult {
        let kept: [RetrievedChunk]
        /// All surviving chunks are weak — prepend the low-confidence prefix.
        let allWeak: Bool
        /// No chunks survived — bypass LLM, return refusalNoContext.
        let noneKept: Bool
    }

    /// Filter retrieved chunks by `weakMatchThreshold` and flag whether the
    /// surviving set is entirely below `strongMatchThreshold`.
    static func filterByScore(_ chunks: [RetrievedChunk]) -> FilterResult {
        let kept = chunks.filter { $0.scoreHybrid >= weakMatchThreshold }
        guard !kept.isEmpty else {
            return FilterResult(kept: [], allWeak: false, noneKept: true)
        }
        let allWeak = kept.allSatisfy { $0.scoreHybrid < strongMatchThreshold }
        return FilterResult(kept: kept, allWeak: allWeak, noneKept: false)
    }

    // MARK: - Context block

    /// Render retrieved chunks as the context block defined in prompt-spec.md.
    /// Each chunk becomes:
    ///
    ///     [chunk_id] (domain: ..., hazard: ..., source: ... — ...)
    ///     Section Title
    ///
    ///     Body...
    ///
    /// Separated by `\n---\n`.
    static func formatContextBlock(_ chunks: [RetrievedChunk]) -> String {
        guard !chunks.isEmpty else { return "" }
        let blocks: [String] = chunks.map { rc in
            var text = rc.text
            if text.count > chunkTextCapChars {
                let cutoff = text.index(text.startIndex, offsetBy: chunkTextCapChars - 1)
                text = String(text[..<cutoff]).trimmingCharacters(in: .whitespacesAndNewlines) + "…"
            }
            let header =
                "[\(rc.chunkId)] (domain: \(rc.domain), hazard: \(rc.hazardLevel.rawValue), " +
                "source: \(rc.sourceTitle) — \(rc.sourcePublisher))"
            return "\(header)\n\(rc.sectionTitle)\n\n\(text)"
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return blocks.joined(separator: "\n\n---\n\n")
    }

    // MARK: - User message

    /// Build the full user message body: optional low-confidence prefix,
    /// optional safety appendix (for `rag_with_safety_appendix`), then the
    /// question, then the formatted context block.
    static func buildUserMessage(
        query: String,
        chunks: [RetrievedChunk],
        decision: RouteDecision,
        lowConfidence: Bool = false
    ) -> String {
        var parts: [String] = []

        if lowConfidence {
            parts.append(lowConfidencePrefix)
        }

        if decision.showsSafetyAppendix && !decision.mustInclude.isEmpty {
            let bullets = decision.mustInclude.map { "- \($0)" }.joined(separator: "\n")
            parts.append(
                "SAFETY REQUIREMENTS (include equivalent language in your answer):\n" + bullets
            )
        }

        parts.append("QUESTION:\n\(query)")
        parts.append("REFERENCE EXCERPTS:\n\(formatContextBlock(chunks))")
        return parts.joined(separator: "\n\n")
    }

    // MARK: - Citation validation

    /// Matches `[domain.topic#N]` or `[domain.topic#N.M]` style citations.
    /// Allowed characters in each segment: lowercase letters, digits, dashes,
    /// underscores. This is intentionally strict so we don't accidentally
    /// match incidental bracketed text in the model's output.
    private static let citationRegex: NSRegularExpression = {
        // \[([a-z0-9_-]+\.[a-z0-9_-]+(?:#[0-9.]+)?)\]
        let pattern = "\\[([a-z0-9_-]+\\.[a-z0-9_-]+(?:#[0-9\\.]+)?)\\]"
        return try! NSRegularExpression(pattern: pattern, options: [])
    }()

    /// Result of running the validator over an LLM answer.
    struct CitationValidation {
        let cleanedAnswer: String
        let validCitations: [String]      // sorted, deduplicated
        let strippedCitations: [String]   // invented chunk ids the LLM hallucinated
    }

    /// Strip invented `[chunk_id]` citations from the model's answer.
    /// Returns the cleaned text plus the set of valid and stripped ids.
    static func validateCitations(
        in answer: String,
        retrievedIds: [String]
    ) -> CitationValidation {
        let validSet = Set(retrievedIds)
        let nsAnswer = answer as NSString
        let matches = citationRegex.matches(
            in: answer,
            options: [],
            range: NSRange(location: 0, length: nsAnswer.length)
        )

        var found: Set<String> = []
        for m in matches {
            // Group 1 is the inner id without brackets.
            guard m.numberOfRanges >= 2 else { continue }
            let id = nsAnswer.substring(with: m.range(at: 1))
            found.insert(id)
        }

        let valid = found.intersection(validSet)
        let invalid = found.subtracting(validSet)

        var cleaned = answer
        for badId in invalid {
            cleaned = cleaned.replacingOccurrences(of: "[\(badId)]", with: "")
        }
        // Tidy up double spaces and "space-punctuation" artifacts left behind.
        while cleaned.contains("  ") {
            cleaned = cleaned.replacingOccurrences(of: "  ", with: " ")
        }
        cleaned = cleaned
            .replacingOccurrences(of: " ,", with: ",")
            .replacingOccurrences(of: " .", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return CitationValidation(
            cleanedAnswer: cleaned,
            validCitations: valid.sorted(),
            strippedCitations: invalid.sorted()
        )
    }

    // MARK: - Convenience: refusal text for a given decision

    /// Resolve the appropriate refusal string for a routing decision. Used
    /// when `decision.isRefusal == true` so the LLM is bypassed entirely.
    static func refusalText(for decision: RouteDecision) -> String {
        if let mapped = intentRefusalMap[decision.intent] {
            return mapped
        }
        if !decision.mustInclude.isEmpty {
            return decision.mustInclude.joined(separator: "\n")
        }
        return refusalNoContext
    }
}
