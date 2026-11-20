import Foundation

public struct Decision: Sendable {
    /// Best first. Always at least two entries.
    public var scenarios: [EvaluatedScenario]
    public var confidence: ConfidenceLevel
    /// Score gap between the best and second-best option.
    public var margin: Int

    public var recommended: EvaluatedScenario { scenarios[0] }
    public var runnerUp: EvaluatedScenario { scenarios[1] }
}

/// Ranks the evaluated options and states how complete the underlying information was.
public enum DecisionEngine {
    public static func decide(profile: ContextProfile, context: EngineContext) -> Decision {
        let evaluated = ScenarioEvaluator.evaluate(profile, context: context)
        let sorted = evaluated.sorted { first, second in
            if first.score != second.score { return first.score > second.score }
            if first.factors.risk != second.factors.risk { return first.factors.risk > second.factors.risk }
            return order(first.action) < order(second.action)
        }
        let margin = sorted[0].score - sorted[1].score
        return Decision(
            scenarios: sorted,
            confidence: confidence(profile: profile, margin: margin),
            margin: margin
        )
    }

    /// Confidence describes the input, not the outcome: how much was provided, how many gaps
    /// remain and how clearly one option stands out.
    static func confidence(profile: ContextProfile, margin: Int) -> ConfidenceLevel {
        var level: ConfidenceLevel
        if profile.evidenceScore >= 65 {
            level = .good
        } else if profile.evidenceScore >= 40 {
            level = .moderate
        } else {
            level = .low
        }
        if profile.missing.count >= 3 && level == .good {
            level = .moderate
        }
        if margin < 4 {
            level = lowered(level)
        }
        return level
    }

    private static func lowered(_ level: ConfidenceLevel) -> ConfidenceLevel {
        switch level {
        case .good: .moderate
        case .moderate, .low: .low
        }
    }

    private static func order(_ action: ActionKind) -> Int {
        ActionKind.allCases.firstIndex(of: action) ?? 0
    }
}
