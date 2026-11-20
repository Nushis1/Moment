import Foundation
import MomentCore

// TEMPORARY (phase 1). A stand-in so every screen can be exercised before MOMENT CORE exists.
// It is NOT the decision engine: output depends only on a few input fields and the wording
// is fixed. Phase 2 deletes this file and injects the real engine behind `MomentAnalyzing`.

nonisolated struct DemoAnalyzer: MomentAnalyzing {
    func analyze(_ input: MomentInput) async throws -> MomentAnalysis {
        try await Task.sleep(for: .milliseconds(2_400))
        return Self.makeAnalysis(for: input)
    }

    func analyzeReply(_ input: ReplyInput) async throws -> ReplyAnalysis {
        try await Task.sleep(for: .milliseconds(1_600))
        return Self.makeReplyAnalysis(for: input)
    }

    static func makeAnalysis(for input: MomentInput) -> MomentAnalysis {
        let heated = [EmotionalState.angry, .hurt, .anxious, .sad].contains(input.emotion)
        let hasMessage = !input.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        let writeNow = Scenario(
            action: .writeNow,
            title: String(localized: "Write now"),
            rationale: String(localized: "Reaching out soon keeps the moment fresh and shows you care about clarity."),
            pros: [
                String(localized: "You get an answer sooner."),
                String(localized: "It matches your wish to move things forward."),
            ],
            cons: [
                String(localized: "Strong feelings can shape the wording more than you intend."),
                String(localized: "A message can't be taken back once it's sent."),
            ],
            factors: ScoreFactors(
                goal: 78,
                values: 66,
                evidence: hasMessage ? 62 : 48,
                risk: heated ? 38 : 64,
                emotion: heated ? 30 : 74,
                profile: 60
            )
        )

        let wait = Scenario(
            action: .waitUntilCalm,
            title: String(localized: "Wait until you feel steadier"),
            rationale: String(localized: "A short pause lets you check what you actually want to say."),
            pros: [
                String(localized: "Your words are more likely to reflect your goal."),
                String(localized: "You keep the option to write later."),
            ],
            cons: [
                String(localized: "The other person may read silence in different ways."),
                String(localized: "Waiting can turn into avoiding if there is no end point."),
            ],
            factors: ScoreFactors(
                goal: 64,
                values: 72,
                evidence: 58,
                risk: heated ? 84 : 70,
                emotion: heated ? 86 : 60,
                profile: 66
            )
        )

        let space = Scenario(
            action: .giveSpace,
            title: String(localized: "Give the other person space"),
            rationale: String(localized: "Leaving room for them to respond in their own time respects both sides."),
            pros: [
                String(localized: "There is no pressure on either of you."),
                String(localized: "It protects the boundaries you mentioned."),
            ],
            cons: [
                String(localized: "You may stay uncertain for longer."),
            ],
            factors: ScoreFactors(
                goal: 50,
                values: 74,
                evidence: 52,
                risk: 80,
                emotion: 62,
                profile: 58
            )
        )

        let scenarios = [writeNow, wait, space]
        let best = scenarios.max { $0.score < $1.score } ?? writeNow

        let missing = input.context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? [String(localized: "How often the two of you usually talk.")]
            : []

        let confidence: ConfidenceLevel
        switch (input.hasValidSituation, hasMessage, missing.isEmpty) {
        case (true, true, true): confidence = .good
        case (true, _, _) where input.trimmedSituation.count > 60: confidence = .moderate
        default: confidence = .low
        }

        return MomentAnalysis(
            summary: String(localized: "You're weighing whether to act now or take a moment first. Here are the options and what each one asks of you."),
            argumentsForActing: [
                String(localized: "You want clarity rather than guessing."),
                String(localized: "Waiting too long can make the situation feel bigger."),
            ],
            argumentsForPausing: [
                String(localized: "Strong emotions are easier to manage after a short break."),
                String(localized: "A calmer message is easier to stand behind later."),
            ],
            scenarios: scenarios,
            recommendedScenarioID: best.id,
            recommendationReason: String(localized: "This option fits your goal while leaving the most room for a choice you'll still agree with tomorrow."),
            confidence: confidence,
            missingInformation: missing,
            followUpQuestion: missing.isEmpty ? nil : String(localized: "Is this a usual pace of contact for you two, or has something changed?")
        )
    }

    static func makeReplyAnalysis(for input: ReplyInput) -> ReplyAnalysis {
        let message = input.receivedMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        let wordCount = message.split(whereSeparator: \.isWhitespace).count
        let hasQuestion = message.contains("?")

        var observations = [String(localized: "The message has about \(wordCount) words.")]
        observations.append(
            hasQuestion
                ? String(localized: "It contains a question, which invites an answer.")
                : String(localized: "It doesn't contain a direct question.")
        )

        return ReplyAnalysis(
            observations: observations,
            interpretations: [
                String(localized: "It could be a simple, friendly check-in."),
                String(localized: "It could also be an opening for a longer conversation."),
                String(localized: "Tone is hard to judge from text alone."),
            ],
            unknowns: [
                String(localized: "What the other person intended."),
                String(localized: "What mood they were in when they wrote it."),
            ],
            suggestions: [
                ReplySuggestion(
                    text: String(localized: "Thanks for writing! I'd love to hear more. How has your week been?"),
                    note: String(localized: "Warm and open. Keeps the conversation going.")
                ),
                ReplySuggestion(
                    text: String(localized: "Hey, good to hear from you. I'm a bit busy now, can I answer properly later today?"),
                    note: String(localized: "Honest about timing without closing the door.")
                ),
            ],
            fitExplanation: String(localized: "These options follow the intent and tone you chose, and none of them assumes what the other person feels.")
        )
    }
}
