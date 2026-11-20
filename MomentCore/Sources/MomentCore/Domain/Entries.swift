import Foundation

/// A saved decision: what was asked, what MOMENT showed, what the person chose and how it went.
public struct DecisionEntry: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var createdAt: Date
    public var input: MomentInput
    public var analysis: MomentAnalysis
    public var selectedScenarioID: UUID?
    public var outcome: DecisionOutcome?
    /// 1...5, or nil when the person has not rated the recommendation.
    public var rating: Int?
    public var reflection: String

    public init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        input: MomentInput,
        analysis: MomentAnalysis,
        selectedScenarioID: UUID? = nil,
        outcome: DecisionOutcome? = nil,
        rating: Int? = nil,
        reflection: String = ""
    ) {
        self.id = id
        self.createdAt = createdAt
        self.input = input
        self.analysis = analysis
        self.selectedScenarioID = selectedScenarioID
        self.outcome = outcome
        self.rating = rating
        self.reflection = reflection
    }

    public var personID: UUID? { input.personID }

    public var selectedScenario: Scenario? {
        guard let selectedScenarioID else { return nil }
        return analysis.scenarios.first { $0.id == selectedScenarioID }
    }

    public var followedRecommendation: Bool? {
        guard let selectedScenarioID else { return nil }
        return selectedScenarioID == analysis.recommendedScenarioID
    }
}

/// Optional private context for a relationship. Nobody has to create these.
public struct PersonEntry: Identifiable, Hashable, Codable, Sendable {
    public var id: UUID
    public var nickname: String
    public var relationship: RelationshipType
    public var metOn: Date?
    public var notes: String
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        nickname: String,
        relationship: RelationshipType,
        metOn: Date? = nil,
        notes: String = "",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.nickname = nickname
        self.relationship = relationship
        self.metOn = metOn
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
