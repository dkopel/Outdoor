import Foundation

/// One message in the conversation. The "assistant" message carries the
/// retrieval result inline so the UI can render chunks + citations, and may
/// also carry a streaming LLM answer that grows as tokens arrive.
struct ChatMessage: Identifiable, Hashable {
    enum Role: Hashable { case user, assistant }
    enum Kind: Hashable {
        case userQuery
        case assistantAnswer(chunks: [RetrievedChunk], decision: RouteDecision)
        case refusal(decision: RouteDecision)
        case emptyResult(decision: RouteDecision)
    }

    /// Where the assistant answer came from in this turn. Drives the
    /// "streaming…" indicator and downstream citation-validation handling.
    enum AnswerSource: Hashable {
        /// Locked procedure card — LLM was bypassed, text is canned.
        case lockedProcedure
        /// Pre-LLM fallback (no model loaded / mock runner active).
        case retrievalOnly
        /// LLM stream in progress; `text` grows as tokens arrive.
        case streaming
        /// LLM stream finished; citations have been validated.
        case complete(validCitations: [String], strippedCitations: [String])
    }

    let id: UUID
    let role: Role
    let kind: Kind
    /// The body shown in the bubble. For streaming assistant messages this
    /// is mutated as new tokens arrive.
    var text: String
    let timestamp: Date
    /// Set only for assistant messages. Drives the typing indicator + the
    /// ⚠️ "not grounded" warning when stripping invalidates all citations.
    var answerSource: AnswerSource?

    init(
        id: UUID = UUID(),
        role: Role,
        kind: Kind,
        text: String,
        timestamp: Date,
        answerSource: AnswerSource? = nil
    ) {
        self.id = id
        self.role = role
        self.kind = kind
        self.text = text
        self.timestamp = timestamp
        self.answerSource = answerSource
    }

    static func user(_ text: String) -> ChatMessage {
        ChatMessage(role: .user, kind: .userQuery, text: text, timestamp: .now)
    }

    /// True while the LLM stream is still running. The MessageBubble shows a
    /// blinking cursor or similar indicator in this state.
    var isStreaming: Bool {
        if case .streaming = answerSource { return true }
        return false
    }
}

/// Hand-picked starter prompts shown on the empty Chat screen.
let starterPrompts: [String] = [
    "How do I purify water from a stream?",
    "What should I do if I see a bear?",
    "How do I tie a bowline?",
    "Treating hypothermia in the field",
    "Building a fire in the rain",
    "Lightning is close — what do I do?",
]
