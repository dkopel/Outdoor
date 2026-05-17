import Foundation
import SwiftUI

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var input: String = ""
    @Published var isThinking: Bool = false

    let packManager: PackManager

    init(packManager: PackManager) {
        self.packManager = packManager
    }

    var canSend: Bool {
        !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isThinking
    }

    func send(prompt: String? = nil) {
        let text = (prompt ?? input).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        input = ""

        let userMsg = ChatMessage.user(text)
        messages.append(userMsg)

        guard let db = packManager.activeDatabase else {
            let decision = RouteDecision.general
            messages.append(ChatMessage(
                role: .assistant,
                kind: .emptyResult(decision: decision),
                text: "No pack is installed. Open the Packs tab and install the Camping pack to get started.",
                timestamp: .now
            ))
            return
        }

        isThinking = true
        let retriever = Retriever(database: db, safetyRules: packManager.activeSafetyRules)
        let result = retriever.search(text, limit: 5)
        let assistant: ChatMessage = {
            if result.decision.isRefusal {
                return ChatMessage(
                    role: .assistant,
                    kind: .refusal(decision: result.decision),
                    text: refusalCopy(for: result.decision),
                    timestamp: .now
                )
            }
            if result.chunks.isEmpty {
                return ChatMessage(
                    role: .assistant,
                    kind: .emptyResult(decision: result.decision),
                    text: emptyCopy(for: text),
                    timestamp: .now
                )
            }
            return ChatMessage(
                role: .assistant,
                kind: .assistantAnswer(chunks: result.chunks, decision: result.decision),
                text: answerCopy(for: result.decision),
                timestamp: .now
            )
        }()
        // Tiny delay so the typing indicator gets a frame to render — feels less janky.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { [weak self] in
            guard let self else { return }
            self.messages.append(assistant)
            self.isThinking = false
        }
    }

    func clear() {
        messages.removeAll()
    }

    // MARK: - Copy

    /// Pre-LLM copy: in Phase 3, this becomes the LLM's grounded synthesis.
    /// For Phase 2 we render the retrieved chunks with a short framing line.
    private func answerCopy(for decision: RouteDecision) -> String {
        switch decision.answerMode {
        case "locked_procedure":
            return "These are the field steps from your pack. Treat them as a reference — get to professional care as soon as conditions allow."
        case "rag_with_safety_appendix":
            return "Here's what your pack says. Read the safety notes carefully — outdoor conditions vary."
        default:
            return "Here's what your pack covers."
        }
    }

    private func refusalCopy(for decision: RouteDecision) -> String {
        switch decision.intent {
        case "plant_id_edibility", "animal_id_edibility":
            return "I won't identify wild plants, mushrooms, or animals as safe to eat. Misidentification can be fatal — verify with a regional field guide and a qualified person in real life."
        case "medication_dosage":
            return "I can't recommend medication doses. Follow the medication label or a clinician's instructions. Call emergency services (or activate a PLB / satellite SOS) if symptoms are serious."
        default:
            return "I'm not going to answer that one. Try rephrasing, or browse the Guide tab."
        }
    }

    private func emptyCopy(for query: String) -> String {
        "I don't have anything for that in your Camping pack. Try rephrasing, or check the Guide tab to browse what's here."
    }
}
