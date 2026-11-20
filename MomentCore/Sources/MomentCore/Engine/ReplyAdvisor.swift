import Foundation

/// Reply Studio logic. Separates what can be observed in a message from what can only be guessed,
/// and offers wording that never assumes what the other person feels.
enum ReplyAdvisor {
    static func advise(_ input: ReplyInput, context: EngineContext) -> ReplyAnalysis {
        let received = LanguageAnalyzer.analyze(input.receivedMessage)
        let draft = LanguageAnalyzer.analyze(input.draft)

        return ReplyAnalysis(
            observations: observations(received),
            interpretations: interpretations(received),
            unknowns: unknowns(),
            suggestions: suggestions(input: input, received: received),
            fitExplanation: fit(received: received),
            draftNotes: draftNotes(draft, intent: input.intent)
        )
    }

    // MARK: Observations (measurable facts about the wording)

    static func observations(_ signals: LanguageSignals) -> [String] {
        var items: [String] = []
        items.append(Msg.t("The message has about \(signals.wordCount) words."))
        if signals.wordCount <= 3 {
            items.append(Msg.t("The message is very short."))
        }
        items.append(signals.questionCount > 0
            ? Msg.t("It contains a question, which invites an answer.")
            : Msg.t("It doesn't contain a direct question."))
        if signals.exclamationCount > 0 { items.append(Msg.t("It uses exclamation marks.")) }
        if signals.emojiCount > 0 { items.append(Msg.t("It includes emoji.")) }
        if signals.uppercaseWordCount > 0 { items.append(Msg.t("It contains words written in capital letters.")) }
        if signals.softenerCount > 0 { items.append(Msg.t("It uses softening words such as “maybe” or “perhaps”.")) }
        if signals.absoluteCount > 0 { items.append(Msg.t("It uses absolute words such as “always” or “never”.")) }
        if signals.warmCount > 0 { items.append(Msg.t("It contains friendly wording.")) }
        if signals.negativeCount > 0 { items.append(Msg.t("It contains wording that can sound tense.")) }
        return items
    }

    // MARK: Interpretations (always possibilities, never facts)

    static func interpretations(_ signals: LanguageSignals) -> [String] {
        var items: [String] = []
        if signals.hasRefusalCue {
            items.append(Msg.t("It may be a request for distance, and it deserves to be taken at face value."))
        }
        if signals.questionCount > 0 {
            items.append(Msg.t("It may be a genuine invitation to continue the conversation."))
        }
        if signals.wordCount <= 3 && signals.questionCount == 0 {
            items.append(Msg.t("A short message can mean the person is busy, relaxed, or simply brief by habit."))
        }
        if signals.warmCount > 0 && signals.negativeCount == 0 {
            items.append(Msg.t("It could be friendly or interested, though wording alone can't confirm that."))
        }
        if signals.negativeCount > 0 || signals.uppercaseWordCount > 0 {
            items.append(Msg.t("It might reflect frustration, or just a rushed moment."))
        }
        if signals.exclamationCount > 0 && signals.negativeCount == 0 {
            items.append(Msg.t("The energy may be enthusiasm, or simply style."))
        }
        if items.count < 2 {
            items.append(Msg.t("It could also simply be a neutral, practical message."))
        }
        items.append(Msg.t("Tone is hard to judge from text alone."))
        return items
    }

    static func unknowns() -> [String] {
        [
            Msg.t("What the other person intended."),
            Msg.t("What mood they were in when they wrote it."),
            Msg.t("How they usually write to you."),
        ]
    }

    static func fit(received: LanguageSignals) -> String {
        if received.hasRefusalCue {
            return Msg.t("Because the message may ask for distance, these options avoid pushing for contact.")
        }
        return Msg.t("These options follow the intent and tone you chose, and none of them assumes what the other person feels.")
    }

    // MARK: Suggestions

    static func suggestions(input: ReplyInput, received: LanguageSignals) -> [ReplySuggestion] {
        let language = replyLanguage(for: received)
        let pack = ReplyTemplates.pack(for: language)

        if received.hasRefusalCue {
            return [
                ReplySuggestion(
                    text: pack.acknowledgement,
                    note: Msg.t("Acknowledges the request without pushing.")
                ),
            ]
        }

        guard let body = pack.bodies[input.intent] else { return [] }

        var tone = input.tone
        var firstNote = Msg.t("Matches the intent and tone you chose.")
        if tone == .flirty && !flirtyFits(input.intent) {
            tone = .natural
            firstNote = Msg.t("A natural tone was used because a flirty tone doesn't fit this intent.")
        }

        let alternative: ReplyTone = tone == .neutral ? .gentle : .neutral
        let alternativeNote = alternative == .gentle
            ? Msg.t("A softer version.")
            : Msg.t("A more neutral version, in case the first feels too strong.")

        return [
            ReplySuggestion(text: compose(pack, tone: tone, body: body.full), note: firstNote),
            ReplySuggestion(text: body.short, note: Msg.t("A shorter version of the same idea.")),
            ReplySuggestion(text: compose(pack, tone: alternative, body: body.full), note: alternativeNote),
        ]
    }

    private static func compose(_ pack: ReplyTemplates.Pack, tone: ReplyTone, body: String) -> String {
        [pack.openers[tone] ?? "", body, pack.closers[tone] ?? ""]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private static func flirtyFits(_ intent: ReplyIntent) -> Bool {
        switch intent {
        case .reply, .askQuestion, .showInterest, .followUp: true
        case .setBoundary, .decline: false
        }
    }

    /// Replies are written in the language of the message; unknown falls back to the device language.
    static func replyLanguage(for signals: LanguageSignals) -> TextLanguage {
        resolve(signals.language)
    }

    static func resolve(_ language: TextLanguage) -> TextLanguage {
        if language != .unknown { return language }
        return Locale.current.language.languageCode?.identifier == "pl" ? .polish : .english
    }

    // MARK: Draft notes

    static func draftNotes(_ draft: LanguageSignals, intent: ReplyIntent) -> [String] {
        guard !draft.isEmpty else { return [] }
        var items: [String] = []
        items.append(Msg.t("Your draft has about \(draft.wordCount) words."))
        if draft.absoluteCount > 0 {
            items.append(Msg.t("Your draft uses absolute words like “always” or “never”. Softer wording often keeps the conversation open."))
        }
        if draft.uppercaseWordCount > 0 {
            items.append(Msg.t("Capital letters in a draft can read as a raised voice."))
        }
        if draft.exclamationCount >= 3 {
            items.append(Msg.t("Several exclamation marks can make a message feel more intense than you may intend."))
        }
        if draft.negativeCount > 0 {
            items.append(Msg.t("Some wording in your draft could sound tense. You may want to check it once more before sending."))
        }
        if intent == .askQuestion && draft.questionCount == 0 {
            items.append(Msg.t("You chose to ask a question, but your draft doesn't contain one."))
        }
        return items
    }
}
