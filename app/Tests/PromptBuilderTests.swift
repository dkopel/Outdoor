import XCTest
@testable import Outdoor

/// Mirrors `pack-builder/tests/test_rag_prompt.py` so the Swift PromptBuilder
/// and the Python rag.py produce equivalent output for the same inputs.
///
/// If a test fails here AND in `test_rag_prompt.py`, the spec changed and both
/// need updating. If only one fails, the implementations have drifted — fix the
/// outlier before shipping.
final class PromptBuilderTests: XCTestCase {

    // MARK: - Fixtures

    private func chunk(
        chunkId: String = "wildlife.bear-encounter#1",
        sectionTitle: String = "If you see a bear",
        text: String = "Stop and stay calm. Maintain distance.",
        domain: String = "wildlife",
        hazard: HazardLevel = .high,
        scoreHybrid: Double = 0.85,
        scoreKeyword: Double = 0.6,
        scoreVector: Double = 0.95
    ) -> RetrievedChunk {
        RetrievedChunk(
            chunkId: chunkId,
            sectionTitle: sectionTitle,
            text: text,
            domain: domain,
            topic: nil,
            hazardLevel: hazard,
            tags: ["wildlife", "bear"],
            sourceTitle: "Staying Safe Around Bears",
            sourcePublisher: "U.S. National Park Service",
            sourceURL: "https://www.nps.gov/subjects/bears/safety.htm",
            sourceLicense: "public-domain",
            scoreKeyword: scoreKeyword,
            scoreVector: scoreVector,
            scoreHybrid: scoreHybrid
        )
    }

    private func decision(
        intent: String = "general",
        answerMode: String = "rag_freeform",
        risk: String = "low",
        mustInclude: [String] = []
    ) -> RouteDecision {
        RouteDecision(
            intent: intent,
            answerMode: answerMode,
            risk: risk,
            mustInclude: mustInclude
        )
    }

    // MARK: - System prompt

    func test_systemPromptIsLoaded() {
        let sp = SystemPrompt.text
        XCTAssertTrue(sp.contains("Outdoor field guide assistant"))
        XCTAssertTrue(sp.contains("ONLY the reference excerpts"))
        XCTAssertTrue(sp.lowercased().contains("do not draw on prior knowledge"))
    }

    // MARK: - formatContextBlock

    func test_formatContextBlock_singleChunk_containsHeaderAndBody() {
        let out = PromptBuilder.formatContextBlock([chunk()])
        XCTAssertTrue(out.contains("[wildlife.bear-encounter#1]"))
        XCTAssertTrue(out.contains("domain: wildlife"))
        XCTAssertTrue(out.contains("hazard: high"))
        XCTAssertTrue(out.contains("Staying Safe Around Bears"))
        XCTAssertTrue(out.contains("U.S. National Park Service"))
        XCTAssertTrue(out.contains("If you see a bear"))
        XCTAssertTrue(out.contains("Stop and stay calm."))
    }

    func test_formatContextBlock_multipleChunks_areSeparatedByRule() {
        let c1 = chunk(chunkId: "a.b#1", text: "First chunk.")
        let c2 = chunk(chunkId: "a.b#2", text: "Second chunk.")
        let out = PromptBuilder.formatContextBlock([c1, c2])
        XCTAssertTrue(out.contains("\n---\n"))
        XCTAssertTrue(out.contains("[a.b#1]"))
        XCTAssertTrue(out.contains("[a.b#2]"))
    }

    func test_formatContextBlock_truncatesLongText() {
        let long = String(repeating: "x", count: PromptBuilder.chunkTextCapChars + 500)
        let out = PromptBuilder.formatContextBlock([chunk(text: long)])
        XCTAssertTrue(out.contains("…"))
        // Body section after the header lines should be cap or less (allow header overhead margin)
        let parts = out.components(separatedBy: "\n\n")
        if let bodySection = parts.last {
            XCTAssertLessThanOrEqual(bodySection.count, PromptBuilder.chunkTextCapChars + 50)
        }
    }

    func test_formatContextBlock_empty() {
        XCTAssertEqual(PromptBuilder.formatContextBlock([]), "")
    }

    // MARK: - buildUserMessage

    func test_buildUserMessage_includesQuestionAndExcerpts() {
        let msg = PromptBuilder.buildUserMessage(
            query: "what to do if I see a bear",
            chunks: [chunk()],
            decision: decision()
        )
        XCTAssertTrue(msg.hasPrefix("QUESTION:\nwhat to do if I see a bear"))
        XCTAssertTrue(msg.contains("REFERENCE EXCERPTS:"))
        XCTAssertTrue(msg.contains("[wildlife.bear-encounter#1]"))
    }

    func test_buildUserMessage_lowConfidencePrefix() {
        let msg = PromptBuilder.buildUserMessage(
            query: "something obscure",
            chunks: [chunk(scoreHybrid: 0.42)],
            decision: decision(),
            lowConfidence: true
        )
        XCTAssertTrue(msg.hasPrefix(PromptBuilder.lowConfidencePrefix))
    }

    func test_buildUserMessage_safetyAppendix_forRagWithSafetyAppendix() {
        let d = decision(
            intent: "animal_encounter",
            answerMode: "rag_with_safety_appendix",
            risk: "medium",
            mustInclude: ["Behaviors differ by species and region."]
        )
        let msg = PromptBuilder.buildUserMessage(
            query: "grizzly bear sighting",
            chunks: [chunk()],
            decision: d
        )
        XCTAssertTrue(msg.contains("SAFETY REQUIREMENTS"))
        XCTAssertTrue(msg.contains("Behaviors differ by species and region."))
    }

    func test_buildUserMessage_noSafetyAppendix_forFreeform() {
        let d = decision(answerMode: "rag_freeform", mustInclude: ["this should not appear"])
        let msg = PromptBuilder.buildUserMessage(
            query: "any question",
            chunks: [chunk()],
            decision: d
        )
        XCTAssertFalse(msg.contains("SAFETY REQUIREMENTS"))
    }

    // MARK: - validateCitations

    func test_validateCitations_allValid() {
        let chunks = [chunk(chunkId: "a.b#1"), chunk(chunkId: "c.d#2")]
        let answer = "Stop [a.b#1]. Then back away [c.d#2]."
        let v = PromptBuilder.validateCitations(in: answer, retrievedIds: chunks.map(\.chunkId))
        XCTAssertEqual(v.cleanedAnswer, answer)
        XCTAssertEqual(v.validCitations.sorted(), ["a.b#1", "c.d#2"])
        XCTAssertEqual(v.strippedCitations, [])
    }

    func test_validateCitations_stripsInvented() {
        let chunks = [chunk(chunkId: "a.b#1")]
        let answer = "Real cite [a.b#1]. Made up [made-up.fake#9]. Real again [a.b#1]."
        let v = PromptBuilder.validateCitations(in: answer, retrievedIds: chunks.map(\.chunkId))
        XCTAssertFalse(v.cleanedAnswer.contains("[made-up.fake#9]"))
        XCTAssertTrue(v.cleanedAnswer.contains("[a.b#1]"))
        XCTAssertEqual(v.validCitations, ["a.b#1"])
        XCTAssertEqual(v.strippedCitations, ["made-up.fake#9"])
    }

    func test_validateCitations_handlesNoCitations() {
        let chunks = [chunk()]
        let v = PromptBuilder.validateCitations(
            in: "No citations here.",
            retrievedIds: chunks.map(\.chunkId)
        )
        XCTAssertEqual(v.cleanedAnswer, "No citations here.")
        XCTAssertEqual(v.validCitations, [])
        XCTAssertEqual(v.strippedCitations, [])
    }

    func test_validateCitations_dedupes() {
        let chunks = [chunk(chunkId: "a.b#1")]
        let answer = "[a.b#1] something [a.b#1] more [a.b#1]."
        let v = PromptBuilder.validateCitations(in: answer, retrievedIds: chunks.map(\.chunkId))
        XCTAssertEqual(v.validCitations, ["a.b#1"])
        XCTAssertEqual(v.strippedCitations, [])
    }

    func test_validateCitations_recognizesSubsectionIds() {
        // chunk_id may include #N or #N.M (chunker splits long sections)
        let chunks = [chunk(chunkId: "x.y#2.1")]
        let v = PromptBuilder.validateCitations(
            in: "From the pack [x.y#2.1].",
            retrievedIds: chunks.map(\.chunkId)
        )
        XCTAssertEqual(v.validCitations, ["x.y#2.1"])
        XCTAssertEqual(v.strippedCitations, [])
    }

    // MARK: - Refusal strings

    func test_refusalStringsExistAndAreDistinct() {
        XCTAssertFalse(PromptBuilder.refusalNoContext.isEmpty)
        XCTAssertFalse(PromptBuilder.refusalEdibility.isEmpty)
        XCTAssertFalse(PromptBuilder.refusalDosage.isEmpty)
        XCTAssertNotEqual(PromptBuilder.refusalNoContext, PromptBuilder.refusalEdibility)
        XCTAssertNotEqual(PromptBuilder.refusalEdibility, PromptBuilder.refusalDosage)
    }

    func test_intentRefusalMap_coversCriticalIntents() {
        XCTAssertEqual(PromptBuilder.intentRefusalMap["medication_dosage"], PromptBuilder.refusalDosage)
        XCTAssertEqual(PromptBuilder.intentRefusalMap["plant_id_edibility"], PromptBuilder.refusalEdibility)
        XCTAssertEqual(PromptBuilder.intentRefusalMap["animal_id_edibility"], PromptBuilder.refusalEdibility)
    }

    // MARK: - Score filtering

    func test_filterByScore_dropsBelowWeakThreshold() {
        let cs = [
            chunk(chunkId: "a.b#1", scoreHybrid: 0.9),
            chunk(chunkId: "a.b#2", scoreHybrid: 0.3),
            chunk(chunkId: "a.b#3", scoreHybrid: 0.5),
        ]
        let r = PromptBuilder.filterByScore(cs)
        XCTAssertEqual(r.kept.map(\.chunkId), ["a.b#1", "a.b#3"])
        XCTAssertFalse(r.noneKept)
        XCTAssertFalse(r.allWeak)   // 0.9 is strong
    }

    func test_filterByScore_flagsAllWeak() {
        let cs = [chunk(chunkId: "a.b#1", scoreHybrid: 0.42), chunk(chunkId: "a.b#2", scoreHybrid: 0.55)]
        let r = PromptBuilder.filterByScore(cs)
        XCTAssertEqual(r.kept.count, 2)
        XCTAssertTrue(r.allWeak)
        XCTAssertFalse(r.noneKept)
    }

    func test_filterByScore_noneKept() {
        let cs = [chunk(chunkId: "a.b#1", scoreHybrid: 0.1), chunk(chunkId: "a.b#2", scoreHybrid: 0.2)]
        let r = PromptBuilder.filterByScore(cs)
        XCTAssertTrue(r.kept.isEmpty)
        XCTAssertTrue(r.noneKept)
    }

    // MARK: - End-to-end with MockLLMRunner

    func test_mockRunner_streamsAndCitesIdsFromUserMessage() async throws {
        let runner = MockLLMRunner(perTokenDelay: .milliseconds(0))
        let user = "QUESTION:\nfoo\n\nREFERENCE EXCERPTS:\n[a.b#1] etc."
        var collected = ""
        for try await tok in runner.stream(
            systemPrompt: "sys",
            userMessage: user,
            temperature: 0.0,
            maxTokens: 100
        ) {
            collected += tok
        }
        XCTAssertTrue(collected.contains("[a.b#1]"))
    }
}
