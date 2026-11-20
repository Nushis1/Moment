import Foundation

public struct OutcomeCount: Identifiable, Hashable, Sendable {
    public let outcome: DecisionOutcome
    public let count: Int
    public var id: DecisionOutcome { outcome }

    public init(outcome: DecisionOutcome, count: Int) {
        self.outcome = outcome
        self.count = count
    }
}

/// Careful, descriptive statistics about the person's own saved decisions.
/// Patterns are reported only once there is enough data, and never rate other people.
public struct InsightsSummary: Hashable, Sendable {
    /// Saved decisions needed before any pattern is shown.
    public static let minimumForPatterns = 5
    /// A value must appear at least this many times to be called a pattern.
    public static let minimumRepeat = 3

    public let totalDecisions: Int
    public let outcomeCounts: [OutcomeCount]
    public let followedRecommendationCount: Int
    public let decisionsWithChoiceCount: Int
    public let topGoal: UserGoal?
    public let topEmotion: EmotionalState?
    public let topRelationship: RelationshipType?

    public var hasEnoughData: Bool { totalDecisions >= Self.minimumForPatterns }

    public init(
        totalDecisions: Int,
        outcomeCounts: [OutcomeCount],
        followedRecommendationCount: Int,
        decisionsWithChoiceCount: Int,
        topGoal: UserGoal?,
        topEmotion: EmotionalState?,
        topRelationship: RelationshipType?
    ) {
        self.totalDecisions = totalDecisions
        self.outcomeCounts = outcomeCounts
        self.followedRecommendationCount = followedRecommendationCount
        self.decisionsWithChoiceCount = decisionsWithChoiceCount
        self.topGoal = topGoal
        self.topEmotion = topEmotion
        self.topRelationship = topRelationship
    }

    public static func make(from decisions: [DecisionEntry]) -> InsightsSummary {
        let total = decisions.count

        var outcomes: [OutcomeCount] = []
        for outcome in DecisionOutcome.allCases {
            let count = decisions.filter { $0.outcome == outcome }.count
            if count > 0 {
                outcomes.append(OutcomeCount(outcome: outcome, count: count))
            }
        }

        let withChoice = decisions.filter { $0.selectedScenarioID != nil }
        let followed = withChoice.filter { $0.followedRecommendation == true }

        let enough = total >= minimumForPatterns
        return InsightsSummary(
            totalDecisions: total,
            outcomeCounts: outcomes,
            followedRecommendationCount: followed.count,
            decisionsWithChoiceCount: withChoice.count,
            topGoal: enough ? mostFrequent(decisions.map { $0.input.goal }) : nil,
            topEmotion: enough ? mostFrequent(decisions.map { $0.input.emotion }) : nil,
            topRelationship: enough ? mostFrequent(decisions.map { $0.input.relationship }) : nil
        )
    }

    /// Ties are resolved by declaration order so the result is deterministic.
    private static func mostFrequent<T: CaseIterable & Hashable>(_ values: [T]) -> T? {
        var best: T?
        var bestCount = 0
        for candidate in T.allCases {
            let count = values.filter { $0 == candidate }.count
            if count > bestCount {
                best = candidate
                bestCount = count
            }
        }
        return bestCount >= minimumRepeat ? best : nil
    }
}
