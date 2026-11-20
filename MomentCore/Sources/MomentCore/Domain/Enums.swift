import Foundation

// MARK: - Situation inputs

public enum RelationshipType: String, CaseIterable, Codable, Sendable, Identifiable {
    case partner, dating, friend, family, work, ex, other
    public var id: String { rawValue }
}

public enum UserGoal: String, CaseIterable, Codable, Sendable, Identifiable {
    case writeFirst, reply, wait, takeFirstStep, continueAcquaintance, shareFeelings, endContact, other
    public var id: String { rawValue }
}

public enum EmotionalState: String, CaseIterable, Codable, Sendable, Identifiable {
    case calm, hopeful, excited, anxious, confused, hurt, angry, sad
    public var id: String { rawValue }
}

public enum Urgency: String, CaseIterable, Codable, Sendable, Identifiable {
    case low, medium, high
    public var id: String { rawValue }
}

// MARK: - Outputs

public enum ActionKind: String, CaseIterable, Codable, Sendable, Identifiable {
    case writeNow, waitUntilCalm, giveSpace, speakInPerson, closeContact
    public var id: String { rawValue }
}

/// Describes how complete and reliable the *input* was. It is never a chance of success.
public enum ConfidenceLevel: String, CaseIterable, Codable, Sendable, Identifiable {
    case low, moderate, good
    public var id: String { rawValue }

    /// 1...3, handy for drawing indicators.
    public var rank: Int {
        switch self {
        case .low: 1
        case .moderate: 2
        case .good: 3
        }
    }
}

public enum DecisionOutcome: String, CaseIterable, Codable, Sendable, Identifiable {
    case asExpected, different, noResult, notSureYet, preferNotToSay
    public var id: String { rawValue }
}

// MARK: - Reply Studio

public enum ReplyIntent: String, CaseIterable, Codable, Sendable, Identifiable {
    case reply, askQuestion, showInterest, setBoundary, decline, followUp
    public var id: String { rawValue }
}

public enum ReplyTone: String, CaseIterable, Codable, Sendable, Identifiable {
    case natural, direct, gentle, confident, light, flirty, neutral
    public var id: String { rawValue }
}

// MARK: - Declared preferences (inputs for the future Personalization Engine)

public enum CommunicationStyle: String, CaseIterable, Codable, Sendable, Identifiable {
    case direct, balanced, gentle
    public var id: String { rawValue }
}

public enum CommunicationPace: String, CaseIterable, Codable, Sendable, Identifiable {
    case quick, balanced, slow
    public var id: String { rawValue }
}

public enum UncertaintyTolerance: String, CaseIterable, Codable, Sendable, Identifiable {
    case low, medium, high
    public var id: String { rawValue }
}

public enum ConflictApproach: String, CaseIterable, Codable, Sendable, Identifiable {
    case avoid, calmTalk, direct
    public var id: String { rawValue }
}
