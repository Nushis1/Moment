import Foundation

/// Declared preferences that personalize scoring. Nothing here is inferred from one situation.
public struct UserPreferences: Hashable, Codable, Sendable {
    public var style: CommunicationStyle
    public var pace: CommunicationPace
    public var uncertainty: UncertaintyTolerance
    public var conflict: ConflictApproach
    /// When false, the engine ignores everything learned from past outcomes.
    public var learningEnabled: Bool

    public init(
        style: CommunicationStyle = .balanced,
        pace: CommunicationPace = .balanced,
        uncertainty: UncertaintyTolerance = .medium,
        conflict: ConflictApproach = .calmTalk,
        learningEnabled: Bool = true
    ) {
        self.style = style
        self.pace = pace
        self.uncertainty = uncertainty
        self.conflict = conflict
        self.learningEnabled = learningEnabled
    }
}

/// A learned tendency, for example how often a kind of action turned out as expected.
/// `value` is 0...1. Signals are only used once enough observations exist.
public struct PreferenceSignal: Identifiable, Hashable, Codable, Sendable {
    public var category: String
    public var value: Double
    public var observationCount: Int
    public var updatedAt: Date

    public var id: String { category }

    public init(category: String, value: Double, observationCount: Int, updatedAt: Date = .now) {
        self.category = category
        self.value = value
        self.observationCount = observationCount
        self.updatedAt = updatedAt
    }
}

/// Everything besides the situation itself that the engine may consider.
public struct EngineContext: Sendable {
    public var preferences: UserPreferences
    public var signals: [PreferenceSignal]

    public init(preferences: UserPreferences = UserPreferences(), signals: [PreferenceSignal] = []) {
        self.preferences = preferences
        self.signals = signals
    }
}

public enum CommunicationIntent: String, CaseIterable, Codable, Sendable {
    case takeInitiative, respondToMessage, pause, keepConnection, expressFeelings, stepBack, seekClarity
}

public enum MissingInformation: String, CaseIterable, Codable, Sendable {
    case theMessage, timing, desiredOutcome, background
}

/// Hard limits that override scoring. They exist to protect the other person's boundaries.
public enum SafetyConstraint: String, CaseIterable, Codable, Sendable {
    case respectDistance
}

/// Organized view of an input: what is known, what is missing and what limits apply.
public struct ContextProfile: Hashable, Sendable {
    public var relationship: RelationshipType
    public var goal: UserGoal
    public var emotion: EmotionalState
    public var urgency: Urgency
    public var intent: CommunicationIntent
    /// 0...100
    public var emotionalIntensity: Int
    /// 0...100: how much usable information the input contains.
    public var evidenceScore: Int
    public var missing: [MissingInformation]
    public var constraints: [SafetyConstraint]
    public var messageSignals: LanguageSignals

    public var respectsDistance: Bool { constraints.contains(.respectDistance) }
}
