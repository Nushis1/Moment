import Foundation

/// What the person reported after acting: outcome, rating and reflection for one decision.
public struct DecisionFeedback: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var decisionID: UUID
    public var selectedOutcome: DecisionOutcome?
    /// 1...5
    public var userRating: Int?
    public var reflection: String
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        decisionID: UUID,
        selectedOutcome: DecisionOutcome?,
        userRating: Int?,
        reflection: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.decisionID = decisionID
        self.selectedOutcome = selectedOutcome
        self.userRating = userRating
        self.reflection = reflection
        self.createdAt = createdAt
    }
}

/// Validates and records the result of a decision.
public enum FeedbackEngine {
    public static let maximumReflectionLength = 2_000

    /// Returns the entry with cleaned-up feedback applied. Ratings outside 1...5 are dropped
    /// (below 1) or capped (above 5); reflections are trimmed and length-limited.
    public static func record(
        outcome: DecisionOutcome?,
        rating: Int?,
        reflection: String,
        on entry: DecisionEntry
    ) -> DecisionEntry {
        var updated = entry
        updated.outcome = outcome
        updated.rating = validRating(rating)
        updated.reflection = String(
            reflection.trimmingCharacters(in: .whitespacesAndNewlines).prefix(maximumReflectionLength)
        )
        return updated
    }

    /// The feedback record for a decision, or nil if nothing has been recorded yet.
    public static func feedback(for entry: DecisionEntry, now: Date = .now) -> DecisionFeedback? {
        guard entry.outcome != nil || entry.rating != nil || !entry.reflection.isEmpty else { return nil }
        return DecisionFeedback(
            decisionID: entry.id,
            selectedOutcome: entry.outcome,
            userRating: entry.rating,
            reflection: entry.reflection,
            createdAt: now
        )
    }

    static func validRating(_ rating: Int?) -> Int? {
        guard let rating, rating >= 1 else { return nil }
        return min(rating, 5)
    }
}
