import Foundation

public struct MomentInput: Hashable, Codable, Sendable {
    public static let minimumSituationLength = 10

    public var situation: String
    public var relationship: RelationshipType
    public var goal: UserGoal
    public var emotion: EmotionalState
    public var urgency: Urgency
    public var message: String
    public var context: String
    public var personID: UUID?

    public init(
        situation: String = "",
        relationship: RelationshipType = .dating,
        goal: UserGoal = .reply,
        emotion: EmotionalState = .calm,
        urgency: Urgency = .medium,
        message: String = "",
        context: String = "",
        personID: UUID? = nil
    ) {
        self.situation = situation
        self.relationship = relationship
        self.goal = goal
        self.emotion = emotion
        self.urgency = urgency
        self.message = message
        self.context = context
        self.personID = personID
    }

    public var trimmedSituation: String {
        situation.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var hasValidSituation: Bool {
        trimmedSituation.count >= Self.minimumSituationLength
    }

    /// True when the person has typed anything worth protecting from an accidental dismiss.
    public var hasDraftContent: Bool {
        !trimmedSituation.isEmpty
            || !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

public struct Scenario: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var action: ActionKind
    public var title: String
    public var rationale: String
    public var pros: [String]
    public var cons: [String]
    /// A rule-of-thumb duration ("a few hours"), when timing matters for this option.
    public var timeframe: String?
    /// Concrete things to do, in order.
    public var steps: [String]
    /// A neutral example of what to say, in the language of the situation. Never a script to push contact.
    public var sampleMessage: String?
    public var factors: ScoreFactors

    public init(
        id: UUID = UUID(),
        action: ActionKind,
        title: String,
        rationale: String,
        pros: [String] = [],
        cons: [String] = [],
        timeframe: String? = nil,
        steps: [String] = [],
        sampleMessage: String? = nil,
        factors: ScoreFactors
    ) {
        self.id = id
        self.action = action
        self.title = title
        self.rationale = rationale
        self.pros = pros
        self.cons = cons
        self.timeframe = timeframe
        self.steps = steps
        self.sampleMessage = sampleMessage
        self.factors = factors
    }

    public var score: Int { factors.weightedScore }
}

public struct MomentAnalysis: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var createdAt: Date
    public var summary: String
    public var argumentsForActing: [String]
    public var argumentsForPausing: [String]
    public var scenarios: [Scenario]
    public var recommendedScenarioID: UUID
    public var recommendationReason: String
    public var confidence: ConfidenceLevel
    public var missingInformation: [String]
    public var followUpQuestion: String?

    public init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        summary: String,
        argumentsForActing: [String],
        argumentsForPausing: [String],
        scenarios: [Scenario],
        recommendedScenarioID: UUID,
        recommendationReason: String,
        confidence: ConfidenceLevel,
        missingInformation: [String] = [],
        followUpQuestion: String? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.summary = summary
        self.argumentsForActing = argumentsForActing
        self.argumentsForPausing = argumentsForPausing
        self.scenarios = scenarios
        self.recommendedScenarioID = recommendedScenarioID
        self.recommendationReason = recommendationReason
        self.confidence = confidence
        self.missingInformation = missingInformation
        self.followUpQuestion = followUpQuestion
    }

    public var recommendedScenario: Scenario? {
        scenarios.first { $0.id == recommendedScenarioID }
    }
}
