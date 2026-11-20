import Foundation

public struct ReplyInput: Hashable, Codable, Sendable {
    public static let minimumMessageLength = 2

    public var receivedMessage: String
    public var draft: String
    public var intent: ReplyIntent
    public var tone: ReplyTone

    public init(
        receivedMessage: String = "",
        draft: String = "",
        intent: ReplyIntent = .reply,
        tone: ReplyTone = .natural
    ) {
        self.receivedMessage = receivedMessage
        self.draft = draft
        self.intent = intent
        self.tone = tone
    }

    public var hasValidMessage: Bool {
        receivedMessage.trimmingCharacters(in: .whitespacesAndNewlines).count >= Self.minimumMessageLength
    }
}

public struct ReplySuggestion: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var text: String
    public var note: String

    public init(id: UUID = UUID(), text: String, note: String) {
        self.id = id
        self.text = text
        self.note = note
    }
}

/// Reply Studio output. Interpretations are possibilities, never facts about the other person.
public struct ReplyAnalysis: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var observations: [String]
    public var interpretations: [String]
    public var unknowns: [String]
    public var suggestions: [ReplySuggestion]
    public var fitExplanation: String
    /// Neutral remarks about the person's own draft, if they wrote one.
    public var draftNotes: [String]

    public init(
        id: UUID = UUID(),
        observations: [String],
        interpretations: [String],
        unknowns: [String],
        suggestions: [ReplySuggestion],
        fitExplanation: String,
        draftNotes: [String] = []
    ) {
        self.id = id
        self.observations = observations
        self.interpretations = interpretations
        self.unknowns = unknowns
        self.suggestions = suggestions
        self.fitExplanation = fitExplanation
        self.draftNotes = draftNotes
    }
}
