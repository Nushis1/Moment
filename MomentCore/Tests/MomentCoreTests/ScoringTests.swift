import Testing
@testable import MomentCore

@Suite("Scenario scoring")
struct ScoringTests {
    @Test("Weights add up to 100%")
    func weightsSumToOne() {
        let total = ScoreFactors.Weight.goal + ScoreFactors.Weight.values + ScoreFactors.Weight.evidence
            + ScoreFactors.Weight.risk + ScoreFactors.Weight.emotion + ScoreFactors.Weight.profile
        #expect(abs(total - 1.0) < 0.0001)
    }

    @Test("A single factor contributes exactly its weight")
    func singleFactor() {
        let goalOnly = ScoreFactors(goal: 100, values: 0, evidence: 0, risk: 0, emotion: 0, profile: 0)
        #expect(goalOnly.weightedScore == 30)
        let valuesOnly = ScoreFactors(goal: 0, values: 100, evidence: 0, risk: 0, emotion: 0, profile: 0)
        #expect(valuesOnly.weightedScore == 20)
    }

    @Test("Mixed factors follow the documented formula")
    func mixedFactors() {
        // 80*.30 + 60*.20 + 50*.15 + 70*.15 + 40*.10 + 30*.10 = 61
        let factors = ScoreFactors(goal: 80, values: 60, evidence: 50, risk: 70, emotion: 40, profile: 30)
        #expect(factors.weightedScore == 61)
    }

    @Test("Out-of-range ratings are clamped to 0...100")
    func clamping() {
        let high = ScoreFactors(goal: 500, values: 500, evidence: 500, risk: 500, emotion: 500, profile: 500)
        #expect(high.weightedScore == 100)
        let low = ScoreFactors(goal: -20, values: -20, evidence: -20, risk: -20, emotion: -20, profile: -20)
        #expect(low.weightedScore == 0)
    }
}

@Suite("Input validation")
struct InputValidationTests {
    @Test("Situation needs a minimum number of real characters")
    func situationLength() {
        #expect(MomentInput(situation: "short").hasValidSituation == false)
        #expect(MomentInput(situation: "          x          ").hasValidSituation == false)
        #expect(MomentInput(situation: "They have not replied since Monday.").hasValidSituation)
    }

    @Test("Draft detection ignores whitespace")
    func draftContent() {
        #expect(MomentInput().hasDraftContent == false)
        #expect(MomentInput(situation: "   \n ").hasDraftContent == false)
        #expect(MomentInput(context: "Something").hasDraftContent)
    }

    @Test("Reply input needs a received message")
    func replyValidation() {
        #expect(ReplyInput().hasValidMessage == false)
        #expect(ReplyInput(receivedMessage: "Hey!").hasValidMessage)
    }
}
