import Foundation

/// One message in the conversation. The "assistant" message carries the
/// retrieval result inline so the UI can render chunks + citations.
struct ChatMessage: Identifiable, Hashable {
    enum Role: Hashable { case user, assistant }
    enum Kind: Hashable {
        case userQuery
        case assistantAnswer(chunks: [RetrievedChunk], decision: RouteDecision)
        case refusal(decision: RouteDecision)
        case emptyResult(decision: RouteDecision)
    }
    let id = UUID()
    let role: Role
    let kind: Kind
    let text: String
    let timestamp: Date

    static func user(_ text: String) -> ChatMessage {
        ChatMessage(role: .user, kind: .userQuery, text: text, timestamp: .now)
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
