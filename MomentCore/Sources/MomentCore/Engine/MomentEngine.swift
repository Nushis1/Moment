import Foundation

/// MOMENT CORE entry point. Fully local and deterministic: the same input, preferences and history
/// always give the same scores and recommendation. No network, no generative AI.
public enum MomentEngine {
    public static func analyze(_ input: MomentInput, context: EngineContext = EngineContext(), now: Date = .now) -> MomentAnalysis {
        let profile = ContextAnalyzer.analyze(input)
        let decision = DecisionEngine.decide(profile: profile, context: context)
        return RecommendationBuilder.build(input: input, profile: profile, decision: decision, now: now)
    }

    public static func analyzeReply(_ input: ReplyInput, context: EngineContext = EngineContext()) -> ReplyAnalysis {
        ReplyAdvisor.advise(input, context: context)
    }
}
