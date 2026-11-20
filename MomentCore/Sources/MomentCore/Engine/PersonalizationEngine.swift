import Foundation

/// Adjusts scoring to declared preferences and to patterns that have enough observations.
/// One situation never creates a lasting conclusion.
public enum PersonalizationEngine {
    /// Outcomes needed for an action before its history may influence a score.
    public static let minimumObservations = 3
    /// Largest shift, in points, that learned history can apply to the profile factor.
    static let maximumLearnedShift = 15.0

    public static func category(for action: ActionKind) -> String {
        "outcome." + action.rawValue
    }

    /// How well an outcome matches what the person hoped for. Unknown outcomes are not counted.
    static func successValue(of outcome: DecisionOutcome) -> Double? {
        switch outcome {
        case .asExpected: 1.0
        case .different: 0.35
        case .noResult: 0.5
        case .notSureYet, .preferNotToSay: nil
        }
    }

    /// Recomputes every signal from saved decisions. Recomputing (instead of incrementing) keeps
    /// the result correct when an outcome is edited or a decision is deleted.
    public static func rebuild(from decisions: [DecisionEntry], now: Date = .now) -> [PreferenceSignal] {
        var signals: [PreferenceSignal] = []
        for action in ActionKind.allCases {
            var total = 0.0
            var count = 0
            for entry in decisions {
                guard entry.selectedScenario?.action == action,
                      let outcome = entry.outcome,
                      let value = successValue(of: outcome) else { continue }
                total += value
                count += 1
            }
            if count > 0 {
                signals.append(
                    PreferenceSignal(
                        category: category(for: action),
                        value: total / Double(count),
                        observationCount: count,
                        updatedAt: now
                    )
                )
            }
        }
        return signals
    }

    /// 0...100 fit between an action and how the person says they like to communicate,
    /// plus a bounded nudge from history. 50 means neutral.
    static func profileScore(for action: ActionKind, context: EngineContext) -> Int {
        let preferences = context.preferences
        var score = 50.0

        switch preferences.style {
        case .direct:
            score += shift(action, writeNow: 12, wait: -6, space: -6, speak: 12, close: 4)
        case .gentle:
            score += shift(action, writeNow: -4, wait: 8, space: 8, speak: -6, close: 0)
        case .balanced:
            break
        }

        switch preferences.pace {
        case .quick:
            score += shift(action, writeNow: 10, wait: -10, space: -8, speak: 6, close: 0)
        case .slow:
            score += shift(action, writeNow: -8, wait: 10, space: 8, speak: -4, close: 0)
        case .balanced:
            break
        }

        switch preferences.uncertainty {
        case .low:
            score += shift(action, writeNow: 6, wait: -4, space: -8, speak: 8, close: 4)
        case .high:
            score += shift(action, writeNow: 0, wait: 6, space: 8, speak: 0, close: 0)
        case .medium:
            break
        }

        switch preferences.conflict {
        case .avoid:
            score += shift(action, writeNow: 0, wait: 4, space: 6, speak: -10, close: 2)
        case .direct:
            score += shift(action, writeNow: 6, wait: 0, space: 0, speak: 10, close: 0)
        case .calmTalk:
            score += shift(action, writeNow: 0, wait: 2, space: 0, speak: 4, close: 0)
        }

        score += learnedShift(for: action, context: context)
        return Int(min(max(score, 0), 100).rounded())
    }

    private static func shift(_ action: ActionKind, writeNow: Double, wait: Double, space: Double, speak: Double, close: Double) -> Double {
        switch action {
        case .writeNow: writeNow
        case .waitUntilCalm: wait
        case .giveSpace: space
        case .speakInPerson: speak
        case .closeContact: close
        }
    }

    static func learnedShift(for action: ActionKind, context: EngineContext) -> Double {
        guard context.preferences.learningEnabled else { return 0 }
        guard let signal = context.signals.first(where: { $0.category == category(for: action) }),
              signal.observationCount >= minimumObservations else { return 0 }
        let centered = signal.value - 0.5
        return min(max(centered * 30, -maximumLearnedShift), maximumLearnedShift)
    }
}
