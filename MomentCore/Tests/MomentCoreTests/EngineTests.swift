import Foundation
import Testing
@testable import MomentCore

@Suite("Context analysis")
struct ContextAnalyzerTests {
    @Test("More information gives a higher evidence score")
    func evidenceGrows() {
        let thin = ContextAnalyzer.analyze(MomentInput(situation: "I am not sure what to do."))
        let rich = ContextAnalyzer.analyze(makeRichInput())
        #expect(rich.evidenceScore > thin.evidenceScore)
        #expect(rich.evidenceScore <= 100)
    }

    @Test("Missing information is reported with the message first for replies")
    func missingInformation() {
        let profile = ContextAnalyzer.analyze(MomentInput(situation: "I am not sure what to do.", goal: .reply))
        #expect(profile.missing.first == .theMessage)
        #expect(profile.missing.contains(.background))
    }

    @Test("Stronger emotions have higher intensity")
    func intensityOrdering() {
        let calm = ContextAnalyzer.analyze(makeRichInput(emotion: .calm))
        let angry = ContextAnalyzer.analyze(makeRichInput(emotion: .angry))
        #expect(angry.emotionalIntensity > calm.emotionalIntensity)
    }

    @Test("A request for distance becomes a safety constraint")
    func distanceConstraint() {
        var input = makeRichInput()
        input.situation = "She told me don't text me anymore, but I miss her and want to write."
        #expect(ContextAnalyzer.analyze(input).respectsDistance)
        #expect(ContextAnalyzer.analyze(makeRichInput()).respectsDistance == false)
    }
}

@Suite("Decision engine")
struct DecisionEngineTests {
    @Test("Every goal and emotion yields two or three complete scenarios")
    func scenarioCounts() {
        for goal in UserGoal.allCases {
            for emotion in EmotionalState.allCases {
                let analysis = MomentEngine.analyze(makeRichInput(goal: goal, emotion: emotion))
                #expect(analysis.scenarios.count >= 2)
                #expect(analysis.scenarios.count <= 3)
                #expect(analysis.scenarios.allSatisfy { !$0.rationale.isEmpty && !$0.title.isEmpty })
                #expect(analysis.recommendedScenario != nil)
            }
        }
    }

    @Test("Scenarios are ordered best first and the first one is recommended")
    func ordering() {
        let analysis = MomentEngine.analyze(makeRichInput(emotion: .anxious))
        let scores = analysis.scenarios.map(\.score)
        #expect(scores == scores.sorted(by: >))
        #expect(analysis.recommendedScenarioID == analysis.scenarios[0].id)
    }

    @Test("A steady, well-informed person is pointed towards writing")
    func calmRecommendsWriting() {
        let analysis = MomentEngine.analyze(makeRichInput(goal: .reply, emotion: .calm))
        #expect(analysis.recommendedScenario?.action == .writeNow)
    }

    @Test("Strong emotions favor a pause over writing")
    func heatedRecommendsPause() {
        for emotion in [EmotionalState.anxious, .hurt, .angry] {
            let analysis = MomentEngine.analyze(makeRichInput(goal: .reply, emotion: emotion))
            #expect(analysis.recommendedScenario?.action != .writeNow)
        }
    }

    @Test("When distance was requested, no option involves making contact")
    func distanceIsRespected() {
        var input = makeRichInput(goal: .reply, emotion: .calm)
        input.situation = "She told me don't text me anymore, but I miss her and want to write."
        let analysis = MomentEngine.analyze(input)
        let actions = analysis.scenarios.map(\.action)
        #expect(!actions.contains(.writeNow))
        #expect(!actions.contains(.speakInPerson))
        #expect(actions.contains(.giveSpace))
    }

    @Test("The same input always gives the same scores and recommendation")
    func deterministic() {
        let input = makeRichInput(emotion: .hurt)
        let first = MomentEngine.analyze(input)
        let second = MomentEngine.analyze(input)
        #expect(first.scenarios.map(\.action) == second.scenarios.map(\.action))
        #expect(first.scenarios.map(\.score) == second.scenarios.map(\.score))
        #expect(first.confidence == second.confidence)
        #expect(first.summary == second.summary)
        #expect(first.recommendationReason == second.recommendationReason)
    }

    @Test("Thin input gives low confidence, a gap list and one follow-up question")
    func thinInput() {
        let input = MomentInput(situation: "I am not sure what to do.", goal: .reply)
        let analysis = MomentEngine.analyze(input)
        #expect(analysis.confidence == .low)
        #expect(!analysis.missingInformation.isEmpty)
        #expect(analysis.followUpQuestion != nil)
    }

    @Test("Rich input is not rated low confidence and asks no question when nothing is missing")
    func richInput() {
        let analysis = MomentEngine.analyze(makeRichInput())
        #expect(analysis.confidence != .low)
        #expect(analysis.missingInformation.isEmpty)
    }
}

@Suite("Personalization")
struct PersonalizationTests {
    @Test("Declared style and pace shift the profile factor")
    func declaredPreferences() {
        let profile = ContextAnalyzer.analyze(makeRichInput())
        let bold = EngineContext(preferences: UserPreferences(style: .direct, pace: .quick))
        let careful = EngineContext(preferences: UserPreferences(style: .gentle, pace: .slow))
        let boldScore = ScenarioEvaluator.evaluate(profile, context: bold).first { $0.action == .writeNow }?.factors.profile ?? 0
        let carefulScore = ScenarioEvaluator.evaluate(profile, context: careful).first { $0.action == .writeNow }?.factors.profile ?? 0
        #expect(boldScore > carefulScore)
    }

    @Test("History needs enough observations before it matters")
    func minimumObservations() {
        let few = PreferenceSignal(category: "outcome.writeNow", value: 1.0, observationCount: 2)
        let enough = PreferenceSignal(category: "outcome.writeNow", value: 1.0, observationCount: 3)
        #expect(PersonalizationEngine.learnedShift(for: .writeNow, context: EngineContext(signals: [few])) == 0)
        #expect(PersonalizationEngine.learnedShift(for: .writeNow, context: EngineContext(signals: [enough])) > 0)
    }

    @Test("Learning can be switched off")
    func learningOff() {
        let signal = PreferenceSignal(category: "outcome.writeNow", value: 1.0, observationCount: 10)
        let off = EngineContext(preferences: UserPreferences(learningEnabled: false), signals: [signal])
        #expect(PersonalizationEngine.learnedShift(for: .writeNow, context: off) == 0)
    }

    @Test("Learned influence is bounded")
    func boundedInfluence() {
        let great = PreferenceSignal(category: "outcome.writeNow", value: 1.0, observationCount: 50)
        let awful = PreferenceSignal(category: "outcome.writeNow", value: 0.0, observationCount: 50)
        let up = PersonalizationEngine.learnedShift(for: .writeNow, context: EngineContext(signals: [great]))
        let down = PersonalizationEngine.learnedShift(for: .writeNow, context: EngineContext(signals: [awful]))
        #expect(up <= PersonalizationEngine.maximumLearnedShift)
        #expect(down >= -PersonalizationEngine.maximumLearnedShift)
    }

    @Test("Signals are rebuilt from saved outcomes and skip unknown ones")
    func rebuild() {
        let decisions = [
            makeDecisionEntry(action: .writeNow, outcome: .asExpected),
            makeDecisionEntry(action: .writeNow, outcome: .asExpected),
            makeDecisionEntry(action: .writeNow, outcome: .different),
            makeDecisionEntry(action: .writeNow, outcome: .notSureYet),
            makeDecisionEntry(action: .writeNow, outcome: nil),
            makeDecisionEntry(action: .waitUntilCalm, outcome: .noResult),
        ]
        let signals = PersonalizationEngine.rebuild(from: decisions)
        let write = signals.first { $0.category == "outcome.writeNow" }
        #expect(write?.observationCount == 3)
        let expected = (1.0 + 1.0 + 0.35) / 3.0
        #expect(abs((write?.value ?? 0) - expected) < 0.0001)
        #expect(signals.first { $0.category == "outcome.waitUntilCalm" }?.observationCount == 1)
    }
}

@Suite("Feedback")
struct FeedbackTests {
    @Test("Ratings are kept within 1 to 5 and reflections are cleaned")
    func validation() {
        let entry = makeDecisionEntry(action: .writeNow, outcome: nil)
        let high = FeedbackEngine.record(outcome: .asExpected, rating: 9, reflection: "  Good call.  ", on: entry)
        #expect(high.rating == 5)
        #expect(high.reflection == "Good call.")
        #expect(high.outcome == .asExpected)
        #expect(FeedbackEngine.record(outcome: nil, rating: 0, reflection: "", on: entry).rating == nil)
        #expect(FeedbackEngine.record(outcome: nil, rating: nil, reflection: "", on: entry).rating == nil)
    }

    @Test("Very long reflections are capped")
    func lengthCap() {
        let entry = makeDecisionEntry(action: .writeNow, outcome: nil)
        let text = String(repeating: "a", count: 5_000)
        let updated = FeedbackEngine.record(outcome: nil, rating: nil, reflection: text, on: entry)
        #expect(updated.reflection.count == FeedbackEngine.maximumReflectionLength)
    }

    @Test("A feedback record exists only once something was recorded")
    func feedbackRecord() {
        let entry = makeDecisionEntry(action: .writeNow, outcome: nil)
        #expect(FeedbackEngine.feedback(for: entry) == nil)
        let recorded = FeedbackEngine.record(outcome: .different, rating: 3, reflection: "", on: entry)
        let feedback = FeedbackEngine.feedback(for: recorded)
        #expect(feedback?.decisionID == entry.id)
        #expect(feedback?.selectedOutcome == .different)
        #expect(feedback?.userRating == 3)
    }
}

@Suite("Reply Studio")
struct ReplyAdvisorTests {
    @Test("A normal message gets observations, several possible readings and three suggestions")
    func structure() {
        let analysis = MomentEngine.analyzeReply(ReplyInput(receivedMessage: "Are you free this weekend?"))
        #expect(!analysis.observations.isEmpty)
        #expect(analysis.interpretations.count >= 2)
        #expect(!analysis.unknowns.isEmpty)
        #expect(analysis.suggestions.count == 3)
    }

    @Test("A request for distance gets a single respectful acknowledgement")
    func refusal() {
        let analysis = MomentEngine.analyzeReply(ReplyInput(receivedMessage: "Please don't text me again.", intent: .showInterest, tone: .flirty))
        #expect(analysis.suggestions.count == 1)
    }

    @Test("Replies follow the language of the message")
    func polishReply() {
        let analysis = MomentEngine.analyzeReply(ReplyInput(receivedMessage: "Cześć, dzięki za wiadomość. Co u ciebie słychać?", intent: .reply, tone: .natural))
        #expect(analysis.suggestions.first?.text.hasPrefix("Cześć,") == true)
    }

    @Test("A flirty tone is not used for boundaries or refusals")
    func flirtyFallback() {
        let analysis = MomentEngine.analyzeReply(ReplyInput(receivedMessage: "Are you free this weekend?", intent: .decline, tone: .flirty))
        #expect(analysis.suggestions.first?.text.contains("Hey you") == false)
    }

    @Test("Draft notes point out wording that can escalate")
    func draftNotes() {
        let analysis = MomentEngine.analyzeReply(ReplyInput(receivedMessage: "Are you free this weekend?", draft: "You ALWAYS do this!!!"))
        #expect(analysis.draftNotes.count >= 3)
        #expect(MomentEngine.analyzeReply(ReplyInput(receivedMessage: "Are you free this weekend?")).draftNotes.isEmpty)
    }
}
