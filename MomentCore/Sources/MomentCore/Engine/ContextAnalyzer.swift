import Foundation

/// Organizes raw input into a `ContextProfile`: intensity, evidence, gaps and safety limits.
public enum ContextAnalyzer {
    public static func analyze(_ input: MomentInput) -> ContextProfile {
        let situation = LanguageAnalyzer.analyze(input.situation)
        let message = LanguageAnalyzer.analyze(input.message)
        let everything = [input.situation, input.context, input.message].joined(separator: ". ")
        let combined = LanguageAnalyzer.analyze(everything)

        let contextLength = input.context.trimmingCharacters(in: .whitespacesAndNewlines).count
        let hasMessage = !message.isEmpty
        let hasContext = contextLength >= 20
        let hasTiming = combined.timeReferenceCount > 0

        return ContextProfile(
            relationship: input.relationship,
            goal: input.goal,
            emotion: input.emotion,
            urgency: input.urgency,
            intent: intent(for: input.goal),
            emotionalIntensity: intensity(for: input.emotion, situation: situation),
            evidenceScore: evidence(input: input, hasMessage: hasMessage, hasContext: hasContext, hasTiming: hasTiming),
            missing: missing(for: input.goal, hasMessage: hasMessage, hasContext: hasContext, hasTiming: hasTiming),
            constraints: combined.hasRefusalCue ? [.respectDistance] : [],
            messageSignals: message
        )
    }

    // MARK: Rules

    static func intent(for goal: UserGoal) -> CommunicationIntent {
        switch goal {
        case .writeFirst, .takeFirstStep: .takeInitiative
        case .reply: .respondToMessage
        case .wait: .pause
        case .continueAcquaintance: .keepConnection
        case .shareFeelings: .expressFeelings
        case .endContact: .stepBack
        case .other: .seekClarity
        }
    }

    static func intensity(for emotion: EmotionalState, situation: LanguageSignals) -> Int {
        var value: Int
        switch emotion {
        case .calm: value = 10
        case .hopeful: value = 25
        case .excited: value = 40
        case .confused: value = 45
        case .sad: value = 60
        case .anxious: value = 70
        case .hurt: value = 75
        case .angry: value = 85
        }
        value += min(10, situation.exclamationCount * 3)
        if situation.uppercaseWordCount > 0 { value += 5 }
        if situation.negativeCount > 0 { value += 5 }
        return min(value, 100)
    }

    static func evidence(input: MomentInput, hasMessage: Bool, hasContext: Bool, hasTiming: Bool) -> Int {
        var score = 15
        let length = input.trimmedSituation.count
        if length >= 160 {
            score += 35
        } else if length >= 80 {
            score += 25
        } else if length >= 30 {
            score += 15
        }
        if hasMessage { score += 20 }
        if hasContext { score += 20 }
        if input.personID != nil { score += 5 }
        if hasTiming { score += 10 }
        return min(score, 100)
    }

    static func missing(for goal: UserGoal, hasMessage: Bool, hasContext: Bool, hasTiming: Bool) -> [MissingInformation] {
        var result: [MissingInformation] = []
        if !hasMessage && goal == .reply {
            result.append(.theMessage)
        }
        let timingMatters: [UserGoal] = [.writeFirst, .wait, .reply, .continueAcquaintance]
        if !hasTiming && timingMatters.contains(goal) {
            result.append(.timing)
        }
        let outcomeMatters: [UserGoal] = [.shareFeelings, .takeFirstStep, .endContact, .other]
        if !hasContext && outcomeMatters.contains(goal) {
            result.append(.desiredOutcome)
        }
        if !hasContext {
            result.append(.background)
        }
        return result
    }
}
