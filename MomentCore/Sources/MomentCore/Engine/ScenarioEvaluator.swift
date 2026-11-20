import Foundation

public struct EvaluatedScenario: Hashable, Sendable {
    public var action: ActionKind
    public var factors: ScoreFactors
    public var score: Int { factors.weightedScore }
}

/// Builds the realistic options for a situation and rates each on the six factors.
/// Every number comes from an explicit rule below; there is no hidden model.
public enum ScenarioEvaluator {
    public static func candidates(for profile: ContextProfile) -> [ActionKind] {
        if profile.respectsDistance {
            return [.giveSpace, .waitUntilCalm, .closeContact]
        }
        switch profile.goal {
        case .writeFirst, .reply, .other: return [.writeNow, .waitUntilCalm, .giveSpace]
        case .wait: return [.waitUntilCalm, .writeNow, .giveSpace]
        case .takeFirstStep: return [.writeNow, .speakInPerson, .waitUntilCalm]
        case .continueAcquaintance: return [.writeNow, .speakInPerson, .giveSpace]
        case .shareFeelings: return [.speakInPerson, .writeNow, .waitUntilCalm]
        case .endContact: return [.closeContact, .waitUntilCalm, .giveSpace]
        }
    }

    public static func evaluate(_ profile: ContextProfile, context: EngineContext) -> [EvaluatedScenario] {
        candidates(for: profile).map { action in
            EvaluatedScenario(
                action: action,
                factors: ScoreFactors(
                    goal: goalFit(profile.goal, action),
                    values: valuesFit(action, profile: profile),
                    evidence: evidenceFit(action, profile: profile),
                    risk: riskFit(action, profile: profile),
                    emotion: emotionFit(action, profile: profile),
                    profile: PersonalizationEngine.profileScore(for: action, context: context)
                )
            )
        }
    }

    // MARK: Factors

    private static let goalTable: [UserGoal: [ActionKind: Int]] = [
        .writeFirst: [.writeNow: 75, .waitUntilCalm: 60, .giveSpace: 45, .speakInPerson: 55, .closeContact: 15],
        .reply: [.writeNow: 80, .waitUntilCalm: 60, .giveSpace: 40, .speakInPerson: 55, .closeContact: 15],
        .wait: [.writeNow: 35, .waitUntilCalm: 85, .giveSpace: 70, .speakInPerson: 30, .closeContact: 25],
        .takeFirstStep: [.writeNow: 70, .waitUntilCalm: 40, .giveSpace: 25, .speakInPerson: 80, .closeContact: 10],
        .continueAcquaintance: [.writeNow: 72, .waitUntilCalm: 50, .giveSpace: 55, .speakInPerson: 68, .closeContact: 10],
        .shareFeelings: [.writeNow: 60, .waitUntilCalm: 65, .giveSpace: 35, .speakInPerson: 82, .closeContact: 20],
        .endContact: [.writeNow: 45, .waitUntilCalm: 50, .giveSpace: 60, .speakInPerson: 40, .closeContact: 85],
        .other: [.writeNow: 60, .waitUntilCalm: 60, .giveSpace: 50, .speakInPerson: 55, .closeContact: 30],
    ]

    /// How well the action serves what the person said they want.
    static func goalFit(_ goal: UserGoal, _ action: ActionKind) -> Int {
        goalTable[goal]?[action] ?? 50
    }

    /// Consideration for the other person and for how the person wants to treat them.
    static func valuesFit(_ action: ActionKind, profile: ContextProfile) -> Int {
        var value: Int
        switch action {
        case .writeNow: value = 62
        case .waitUntilCalm: value = 74
        case .giveSpace: value = 72
        case .speakInPerson: value = 66
        case .closeContact: value = 58
        }
        if profile.relationship == .ex && action == .giveSpace { value += 8 }
        if (profile.relationship == .partner || profile.relationship == .family) && action == .speakInPerson { value += 8 }
        if profile.relationship == .work && action == .writeNow { value += 6 }
        return value
    }

    /// Quality of the information behind the action. Acting on thin information scores lower;
    /// waiting, which allows gathering more, scores higher.
    static func evidenceFit(_ action: ActionKind, profile: ContextProfile) -> Int {
        var value = profile.evidenceScore
        if profile.evidenceScore < 45 {
            switch action {
            case .writeNow, .speakInPerson, .closeContact: value -= 12
            case .waitUntilCalm, .giveSpace: value += 10
            }
        }
        return value
    }

    /// Higher means a lower chance of an outcome the person would regret.
    static func riskFit(_ action: ActionKind, profile: ContextProfile) -> Int {
        var value: Int
        switch action {
        case .writeNow: value = 55
        case .waitUntilCalm: value = 80
        case .giveSpace: value = 78
        case .speakInPerson: value = 58
        case .closeContact: value = 66
        }
        let heat = max(0, profile.emotionalIntensity - 40)
        switch action {
        case .writeNow, .speakInPerson: value -= heat / 2
        case .waitUntilCalm, .giveSpace: value += heat / 4
        case .closeContact: value -= heat / 3
        }
        if profile.relationship == .ex && (action == .writeNow || action == .speakInPerson) {
            value -= 10
        }
        return value
    }

    /// How well the action suits the person's current emotional state and time pressure.
    static func emotionFit(_ action: ActionKind, profile: ContextProfile) -> Int {
        let intensity = profile.emotionalIntensity
        var value: Int
        switch action {
        case .writeNow: value = 100 - intensity
        case .speakInPerson: value = 95 - intensity
        case .waitUntilCalm: value = 45 + intensity / 2
        case .giveSpace: value = 40 + intensity / 2
        case .closeContact: value = 50 + intensity / 5
        }
        switch profile.urgency {
        case .high:
            switch action {
            case .waitUntilCalm, .giveSpace: value -= 12
            case .writeNow, .speakInPerson: value += 8
            case .closeContact: break
            }
        case .low:
            if action == .waitUntilCalm || action == .giveSpace { value += 6 }
        case .medium:
            break
        }
        return value
    }
}
