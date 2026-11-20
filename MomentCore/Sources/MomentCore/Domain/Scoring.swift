import Foundation

/// Per-factor ratings (0...100) used to compare scenarios.
///
/// `Score = Goal×0.30 + Values×0.20 + Evidence×0.15 + Risk×0.15 + Emotion×0.10 + Profile×0.10`
///
/// A higher `risk` value means a *lower* risk of an unwanted result. The score only
/// compares scenarios with each other; it is not a measurement and not a prediction
/// of how another person will behave.
public struct ScoreFactors: Hashable, Codable, Sendable {
    public enum Weight {
        public static let goal = 0.30
        public static let values = 0.20
        public static let evidence = 0.15
        public static let risk = 0.15
        public static let emotion = 0.10
        public static let profile = 0.10
    }

    public let goal: Int
    public let values: Int
    public let evidence: Int
    public let risk: Int
    public let emotion: Int
    public let profile: Int

    public init(goal: Int, values: Int, evidence: Int, risk: Int, emotion: Int, profile: Int) {
        self.goal = Self.clamp(goal)
        self.values = Self.clamp(values)
        self.evidence = Self.clamp(evidence)
        self.risk = Self.clamp(risk)
        self.emotion = Self.clamp(emotion)
        self.profile = Self.clamp(profile)
    }

    public var weightedScore: Int {
        let total = Double(goal) * Weight.goal
            + Double(values) * Weight.values
            + Double(evidence) * Weight.evidence
            + Double(risk) * Weight.risk
            + Double(emotion) * Weight.emotion
            + Double(profile) * Weight.profile
        return Int(total.rounded())
    }

    private static func clamp(_ value: Int) -> Int {
        min(max(value, 0), 100)
    }
}
