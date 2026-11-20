import Foundation
import Testing
@testable import MomentCore

@Suite("Insights summary")
struct InsightsTests {
    private func makeEntry(
        goal: UserGoal = .reply,
        emotion: EmotionalState = .calm,
        relationship: RelationshipType = .friend,
        outcome: DecisionOutcome? = nil,
        followRecommendation: Bool? = nil
    ) -> DecisionEntry {
        let factors = ScoreFactors(goal: 70, values: 70, evidence: 70, risk: 70, emotion: 70, profile: 70)
        let recommended = Scenario(action: .waitUntilCalm, title: "Wait", rationale: "Because", factors: factors)
        let other = Scenario(action: .writeNow, title: "Write", rationale: "Because", factors: factors)
        let analysis = MomentAnalysis(
            summary: "Summary",
            argumentsForActing: [],
            argumentsForPausing: [],
            scenarios: [recommended, other],
            recommendedScenarioID: recommended.id,
            recommendationReason: "Reason",
            confidence: .moderate
        )
        var selected: UUID?
        if let followRecommendation {
            selected = followRecommendation ? recommended.id : other.id
        }
        return DecisionEntry(
            input: MomentInput(situation: "A situation long enough", relationship: relationship, goal: goal, emotion: emotion),
            analysis: analysis,
            selectedScenarioID: selected,
            outcome: outcome
        )
    }

    @Test("Empty history gives an empty summary")
    func empty() {
        let summary = InsightsSummary.make(from: [])
        #expect(summary.totalDecisions == 0)
        #expect(summary.outcomeCounts.isEmpty)
        #expect(summary.hasEnoughData == false)
        #expect(summary.topGoal == nil)
    }

    @Test("No patterns are reported below the minimum number of decisions")
    func notEnoughData() {
        let entries = (0..<4).map { _ in makeEntry(goal: .wait) }
        let summary = InsightsSummary.make(from: entries)
        #expect(summary.hasEnoughData == false)
        #expect(summary.topGoal == nil)
    }

    @Test("A repeated goal becomes a pattern once there is enough data")
    func patternDetected() {
        var entries = (0..<3).map { _ in makeEntry(goal: .wait, emotion: .anxious) }
        entries.append(makeEntry(goal: .reply, emotion: .calm))
        entries.append(makeEntry(goal: .shareFeelings, emotion: .hopeful))
        let summary = InsightsSummary.make(from: entries)
        #expect(summary.hasEnoughData)
        #expect(summary.topGoal == .wait)
        #expect(summary.topEmotion == .anxious)
    }

    @Test("A value seen fewer than three times is not a pattern")
    func weakPatternIgnored() {
        let goals: [UserGoal] = [.wait, .wait, .reply, .reply, .shareFeelings]
        let entries = goals.map { makeEntry(goal: $0) }
        #expect(InsightsSummary.make(from: entries).topGoal == nil)
    }

    @Test("Outcome counts skip outcomes that never happened")
    func outcomeCounts() {
        let entries = [
            makeEntry(outcome: .asExpected),
            makeEntry(outcome: .asExpected),
            makeEntry(outcome: .different),
            makeEntry(outcome: nil),
        ]
        let summary = InsightsSummary.make(from: entries)
        #expect(summary.outcomeCounts.count == 2)
        #expect(summary.outcomeCounts.first { $0.outcome == .asExpected }?.count == 2)
        #expect(summary.outcomeCounts.first { $0.outcome == .different }?.count == 1)
    }

    @Test("Followed-recommendation share only counts decisions where a choice was saved")
    func followedShare() {
        let entries = [
            makeEntry(followRecommendation: true),
            makeEntry(followRecommendation: false),
            makeEntry(followRecommendation: true),
            makeEntry(followRecommendation: nil),
        ]
        let summary = InsightsSummary.make(from: entries)
        #expect(summary.decisionsWithChoiceCount == 3)
        #expect(summary.followedRecommendationCount == 2)
    }
}
