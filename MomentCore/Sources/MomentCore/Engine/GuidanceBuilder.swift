import Foundation

struct Guidance {
    var timeframe: String?
    var steps: [String]
    var sampleMessage: String?
}

/// Rule-based, concrete advice for each option: how long, what to do, what to say.
/// Durations are rules of thumb, not predictions about anyone's behavior.
enum GuidanceBuilder {
    static func guidance(for action: ActionKind, profile: ContextProfile) -> Guidance {
        Guidance(
            timeframe: timeframe(for: action, profile: profile),
            steps: steps(for: action, profile: profile),
            sampleMessage: sampleMessage(for: action, profile: profile)
        )
    }

    // MARK: Timeframe

    static func timeframe(for action: ActionKind, profile: ContextProfile) -> String? {
        switch action {
        case .waitUntilCalm:
            if profile.respectsDistance {
                return Msg.t("For as long as they ask. Don't start contact.")
            }
            if profile.urgency == .high {
                return Msg.t("A short pause: about 30 to 60 minutes.")
            }
            if profile.emotionalIntensity >= 75 {
                return Msg.t("Until you feel steadier: usually a few hours, or after a night's sleep.")
            }
            if profile.emotionalIntensity >= 60 {
                return Msg.t("A few hours, ideally within the same day.")
            }
            if profile.relationship == .work {
                return Msg.t("Within today's working hours.")
            }
            return Msg.t("An hour or two.")
        case .giveSpace:
            if profile.respectsDistance {
                return Msg.t("For as long as they ask. Don't start contact.")
            }
            if profile.relationship == .ex {
                return Msg.t("At least a few weeks, then ask yourself whether contact still serves you.")
            }
            return Msg.t("A few days, then check in with yourself about what you want.")
        case .speakInPerson:
            switch profile.urgency {
            case .high: return Msg.t("As soon as you both have a calm moment, ideally today.")
            case .medium: return Msg.t("Within the next day or two, at a calm moment.")
            case .low: return Msg.t("Whenever it suits both of you this week.")
            }
        case .writeNow, .closeContact:
            return nil
        }
    }

    // MARK: Steps

    static func steps(for action: ActionKind, profile: ContextProfile) -> [String] {
        switch action {
        case .writeNow:
            var items = [
                Msg.t("Make one clear point in a sentence or two."),
                Msg.t("Stick to what you know, and ask rather than assume how they feel."),
                Msg.t("Leave room for them to answer in their own time."),
            ]
            if profile.emotionalIntensity >= 60 {
                items.append(Msg.t("Read it aloud once before you send it."))
            }
            if profile.goal == .reply && !profile.messageSignals.isEmpty {
                items.append(Msg.t("For wording ideas, paste their message into Reply Studio."))
            }
            return items

        case .waitUntilCalm:
            if profile.respectsDistance {
                return [
                    Msg.t("Don't contact them, including through friends or other accounts."),
                    Msg.t("Meanwhile, write down what you actually want from this."),
                    Msg.t("After some time, notice whether it still feels important to say."),
                ]
            }
            var items = [
                Msg.t("Decide when you will come back to this, and keep to it."),
                Msg.t("Meanwhile, write down what you actually want from this conversation."),
                Msg.t("When the time is up, re-read what you wrote and ask: would I stand behind this tomorrow?"),
            ]
            if profile.goal == .reply || profile.urgency != .low {
                items.append(Msg.t("If you usually talk often, a short holding message is fine. You don't have to explain everything."))
            }
            return items

        case .giveSpace:
            if profile.respectsDistance {
                return [
                    Msg.t("Don't contact them, including through friends or other accounts."),
                    Msg.t("If they reach out later, you can answer calmly."),
                    Msg.t("Use the time for something that steadies you."),
                ]
            }
            return [
                Msg.t("Don't send follow-ups or check whether they've read your last message."),
                Msg.t("Use the time for something that steadies you."),
                Msg.t("Decide now what would make you reach out again, such as a date or a sign from them."),
            ]

        case .speakInPerson:
            return [
                Msg.t("Choose a calm moment, not right after a conflict."),
                Msg.t("Open with what you want to say, not with what they did."),
                Msg.t("Agree on a time first if it's a call."),
            ]

        case .closeContact:
            if profile.respectsDistance {
                return [
                    Msg.t("Write down what you'd like to say, but don't send it."),
                    Msg.t("Let their request stand."),
                    Msg.t("If closure matters, a trusted friend or a counselor can help you process it."),
                ]
            }
            return [
                Msg.t("Say it once, briefly and kindly. You don't have to justify everything."),
                Msg.t("Don't ask for agreement or a reply."),
                Msg.t("After sending, give yourself time before checking for a response."),
            ]
        }
    }

    // MARK: Example message

    static func sampleMessage(for action: ActionKind, profile: ContextProfile) -> String? {
        // Never offer wording that starts or continues contact when distance was requested.
        guard !profile.respectsDistance else { return nil }
        let pack = GuidanceTemplates.pack(for: ReplyAdvisor.resolve(profile.language))

        switch action {
        case .writeNow:
            switch profile.goal {
            case .takeFirstStep: return pack.invite
            case .shareFeelings: return pack.openUp
            case .reply: return nil   // wording depends on their message: Reply Studio handles it
            default: return pack.reachOut
            }
        case .speakInPerson:
            return pack.talkOpener
        case .closeContact:
            return pack.closing
        case .waitUntilCalm:
            return (profile.goal == .reply || profile.urgency != .low) ? pack.holding : nil
        case .giveSpace:
            return nil
        }
    }
}
