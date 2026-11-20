import Foundation
@testable import MomentCore

/// A saved decision where the person chose `action` and recorded `outcome`.
func makeDecisionEntry(action: ActionKind, outcome: DecisionOutcome?, goal: UserGoal = .reply) -> DecisionEntry {
    let factors = ScoreFactors(goal: 70, values: 70, evidence: 70, risk: 70, emotion: 70, profile: 70)
    let chosen = Scenario(action: action, title: "Chosen", rationale: "Because", factors: factors)
    let other = Scenario(action: action == .writeNow ? .waitUntilCalm : .writeNow, title: "Other", rationale: "Because", factors: factors)
    let analysis = MomentAnalysis(
        summary: "Summary",
        argumentsForActing: [],
        argumentsForPausing: [],
        scenarios: [chosen, other],
        recommendedScenarioID: chosen.id,
        recommendationReason: "Reason",
        confidence: .moderate
    )
    return DecisionEntry(
        input: MomentInput(situation: "A situation long enough", goal: goal),
        analysis: analysis,
        selectedScenarioID: chosen.id,
        outcome: outcome
    )
}

/// An input with enough information for the engine to be fairly sure about its evidence.
func makeRichInput(goal: UserGoal = .reply, emotion: EmotionalState = .calm, relationship: RelationshipType = .dating) -> MomentInput {
    MomentInput(
        situation: "We talked last week and since Monday there has been no reply, so I am not sure whether I should write first or wait a little longer.",
        relationship: relationship,
        goal: goal,
        emotion: emotion,
        urgency: .medium,
        message: "Hey, are you free this weekend?",
        context: "We usually text a few times a week and it has been a good conversation so far."
    )
}
