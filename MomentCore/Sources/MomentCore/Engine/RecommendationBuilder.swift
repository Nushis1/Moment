import Foundation

/// Turns a `Decision` into readable text using hand-written templates and variants.
enum RecommendationBuilder {
    static func build(input: MomentInput, profile: ContextProfile, decision: Decision, now: Date) -> MomentAnalysis {
        let seed = input.trimmedSituation
        let scenarios = decision.scenarios.map { evaluated in
            Scenario(
                action: evaluated.action,
                title: title(for: evaluated.action),
                rationale: rationale(for: evaluated.action, profile: profile, seed: seed),
                pros: pros(for: evaluated.action),
                cons: cons(for: evaluated.action, profile: profile),
                factors: evaluated.factors
            )
        }
        let recommendedID = scenarios[0].id

        return MomentAnalysis(
            createdAt: now,
            summary: summary(profile: profile, seed: seed),
            argumentsForActing: argumentsForActing(profile: profile),
            argumentsForPausing: argumentsForPausing(profile: profile, seed: seed),
            scenarios: scenarios,
            recommendedScenarioID: recommendedID,
            recommendationReason: reason(decision: decision, profile: profile),
            confidence: decision.confidence,
            missingInformation: decision.confidence == .good ? [] : profile.missing.map { missingText($0) },
            followUpQuestion: decision.confidence == .good ? nil : profile.missing.first.map { question($0) }
        )
    }

    // MARK: Summary

    static func summary(profile: ContextProfile, seed: String) -> String {
        var parts: [String] = []

        switch profile.goal {
        case .writeFirst: parts.append(Msg.t("You're deciding whether to reach out first."))
        case .reply: parts.append(Msg.t("You're deciding how to answer a message."))
        case .wait: parts.append(Msg.t("You're considering whether to wait."))
        case .takeFirstStep: parts.append(Msg.t("You're thinking about taking a first step."))
        case .continueAcquaintance: parts.append(Msg.t("You'd like to keep getting to know someone."))
        case .shareFeelings: parts.append(Msg.t("You want to share how you feel."))
        case .endContact: parts.append(Msg.t("You're thinking about ending contact."))
        case .other: parts.append(Msg.t("You're working through a situation that matters to you."))
        }

        let variant = StableHash.pick(2, seed: seed)
        if profile.emotionalIntensity >= 60 {
            parts.append(variant == 0
                ? Msg.t("Strong feelings are present, which makes a short pause worth considering.")
                : Msg.t("Your feelings are running high, so it helps to check how they shape your choices."))
        } else if profile.emotionalIntensity < 35 {
            parts.append(variant == 0
                ? Msg.t("You feel fairly steady, which makes clear communication easier.")
                : Msg.t("You're in a calm place to think this through."))
        } else {
            parts.append(Msg.t("Your feelings are mixed, which is completely normal here."))
        }

        if profile.respectsDistance {
            parts.append(Msg.t("You mentioned that the other person asked for distance, so every option below respects that."))
        }
        return parts.joined(separator: " ")
    }

    // MARK: Scenarios

    static func title(for action: ActionKind) -> String {
        switch action {
        case .writeNow: Msg.t("Write now")
        case .waitUntilCalm: Msg.t("Wait until you feel steadier")
        case .giveSpace: Msg.t("Give the other person space")
        case .speakInPerson: Msg.t("Talk in person or on a call")
        case .closeContact: Msg.t("Close the contact calmly")
        }
    }

    static func rationale(for action: ActionKind, profile: ContextProfile, seed: String) -> String {
        let heated = profile.emotionalIntensity >= 60
        switch action {
        case .writeNow:
            return heated
                ? Msg.t("Writing now is possible, but strong feelings may shape the wording more than you intend.")
                : Msg.t("You feel steady enough to write clearly, and reaching out soon keeps things simple.")
        case .waitUntilCalm:
            if profile.goal == .wait {
                return Msg.t("You already lean towards waiting. A defined pause of hours, not days, keeps it from turning into avoidance.")
            }
            return heated
                ? Msg.t("A short pause lets the intensity settle so your message reflects what you actually want.")
                : Msg.t("A brief pause costs little and lets you check that you really want to send this.")
        case .giveSpace:
            return profile.respectsDistance
                ? Msg.t("They have indicated they want distance. Honouring that is the clearest way to respect them.")
                : Msg.t("Leaving room for the other person to respond in their own time respects both sides.")
        case .speakInPerson:
            return Msg.t("Some things land better in a voice or in person, where tone is clear and misunderstandings can be fixed on the spot.")
        case .closeContact:
            return Msg.t("A short, calm closing message or a quiet step back can end contact without leaving things hostile.")
        }
    }

    static func pros(for action: ActionKind) -> [String] {
        switch action {
        case .writeNow:
            [Msg.t("You get clarity sooner."), Msg.t("It matches your wish to move things forward.")]
        case .waitUntilCalm:
            [Msg.t("Your words are more likely to reflect your goal."), Msg.t("You keep the option to write later.")]
        case .giveSpace:
            [Msg.t("There is no pressure on either of you."), Msg.t("It protects the other person's boundaries.")]
        case .speakInPerson:
            [Msg.t("Tone and intent are easier to read."), Msg.t("Misunderstandings can be cleared up straight away.")]
        case .closeContact:
            [Msg.t("It gives both of you a clear ending."), Msg.t("It lets you step away with dignity.")]
        }
    }

    static func cons(for action: ActionKind, profile: ContextProfile) -> [String] {
        switch action {
        case .writeNow:
            var items = [Msg.t("A sent message can't be taken back.")]
            if profile.emotionalIntensity >= 60 {
                items.append(Msg.t("Strong feelings may colour the wording."))
            }
            return items
        case .waitUntilCalm:
            return [Msg.t("The other person may read silence in different ways."), Msg.t("Waiting can turn into avoiding if there is no end point.")]
        case .giveSpace:
            return [Msg.t("You may stay uncertain for longer.")]
        case .speakInPerson:
            return [Msg.t("It takes more time and courage."), Msg.t("It's harder to find the right words on the spot.")]
        case .closeContact:
            return [Msg.t("It may feel final before you are ready."), Msg.t("The other person might respond with strong feelings.")]
        }
    }

    // MARK: Arguments

    static func argumentsForActing(profile: ContextProfile) -> [String] {
        var items: [String] = []
        if profile.goal != .wait && profile.goal != .endContact {
            items.append(Msg.t("You want clarity rather than guessing."))
        }
        if profile.urgency != .low {
            items.append(Msg.t("Waiting too long can make the situation feel bigger."))
        }
        if profile.emotionalIntensity < 35 {
            items.append(Msg.t("You feel steady enough to say it well."))
        }
        if items.isEmpty {
            items.append(Msg.t("Acting lets you learn how the other person responds."))
        }
        return items
    }

    static func argumentsForPausing(profile: ContextProfile, seed: String) -> [String] {
        var items: [String] = []
        if profile.respectsDistance {
            items.append(Msg.t("The other person asked for distance."))
        }
        if profile.emotionalIntensity >= 60 {
            items.append(Msg.t("Strong emotions are easier to manage after a short break."))
        }
        items.append(StableHash.pick(2, seed: seed) == 0
            ? Msg.t("A calmer message is easier to stand behind later.")
            : Msg.t("A pause lets you check what you really want to say."))
        if profile.evidenceScore < 45 {
            items.append(Msg.t("You don't have much information yet, and a pause lets you gather it."))
        }
        return items
    }

    // MARK: Reason, gaps, question

    private enum Factor { case goal, values, evidence, risk, emotion, profile }

    static func reason(decision: Decision, profile: ContextProfile) -> String {
        if profile.respectsDistance {
            return Msg.t("Because the other person asked for distance, this is the option that respects that.")
        }
        let top = decision.recommended.factors
        let next = decision.runnerUp.factors
        let deltas: [(Factor, Double)] = [
            (.goal, Double(top.goal - next.goal) * ScoreFactors.Weight.goal),
            (.values, Double(top.values - next.values) * ScoreFactors.Weight.values),
            (.evidence, Double(top.evidence - next.evidence) * ScoreFactors.Weight.evidence),
            (.risk, Double(top.risk - next.risk) * ScoreFactors.Weight.risk),
            (.emotion, Double(top.emotion - next.emotion) * ScoreFactors.Weight.emotion),
            (.profile, Double(top.profile - next.profile) * ScoreFactors.Weight.profile),
        ]
        guard let best = deltas.max(by: { $0.1 < $1.1 }), best.1 > 0 else {
            return Msg.t("It comes out slightly ahead across the factors that matter to you.")
        }
        switch best.0 {
        case .goal: return Msg.t("It fits what you want to achieve best.")
        case .values: return Msg.t("It fits how you would like to treat the other person best.")
        case .evidence: return Msg.t("It fits the information available best.")
        case .risk: return Msg.t("It carries the lowest risk of an outcome you would regret.")
        case .emotion: return Msg.t("It suits how you feel right now best.")
        case .profile: return Msg.t("It matches the way you prefer to communicate.")
        }
    }

    static func missingText(_ item: MissingInformation) -> String {
        switch item {
        case .theMessage: Msg.t("The message itself, so the wording can be considered.")
        case .timing: Msg.t("How long it has been since the last contact.")
        case .desiredOutcome: Msg.t("What you hope will happen afterwards.")
        case .background: Msg.t("A little more background on how the two of you usually communicate.")
        }
    }

    static func question(_ item: MissingInformation) -> String {
        switch item {
        case .theMessage: Msg.t("Could you paste the message you received?")
        case .timing: Msg.t("How long has it been since you last talked?")
        case .desiredOutcome: Msg.t("What would a good outcome look like for you?")
        case .background: Msg.t("Is this how the two of you usually communicate, or has something changed?")
        }
    }
}
