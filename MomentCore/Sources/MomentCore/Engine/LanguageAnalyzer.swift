import Foundation
import NaturalLanguage

public enum TextLanguage: String, Codable, Sendable {
    case polish, english, unknown
}

/// Measurable features of a text. These describe wording, never the writer's intent.
public struct LanguageSignals: Hashable, Sendable {
    public var language: TextLanguage = .unknown
    public var wordCount = 0
    public var sentenceCount = 0
    public var questionCount = 0
    public var exclamationCount = 0
    public var emojiCount = 0
    public var uppercaseWordCount = 0
    public var softenerCount = 0
    public var absoluteCount = 0
    public var negativeCount = 0
    public var warmCount = 0
    public var urgencyCount = 0
    public var apologyCount = 0
    public var timeReferenceCount = 0
    public var hasRefusalCue = false

    public init() {}

    public static let empty = LanguageSignals()
    public var isEmpty: Bool { wordCount == 0 }
}

/// Uses Apple NaturalLanguage for language detection and tokenization, plus the word lists in `Lexicon`.
public enum LanguageAnalyzer {
    public static func analyze(_ text: String) -> LanguageSignals {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .empty }

        var signals = LanguageSignals()
        signals.language = detectLanguage(trimmed)

        let words = tokenize(trimmed, unit: .word)
        let folded = words.map { fold($0) }

        signals.wordCount = words.count
        signals.sentenceCount = max(1, tokenize(trimmed, unit: .sentence).count)
        signals.questionCount = trimmed.filter { $0 == "?" }.count
        signals.exclamationCount = trimmed.filter { $0 == "!" }.count
        signals.emojiCount = trimmed.unicodeScalars.filter { $0.properties.isEmojiPresentation }.count
        signals.uppercaseWordCount = words.filter { isShouted($0) }.count

        signals.softenerCount = folded.filter { Lexicon.softeners.contains($0) }.count
        signals.absoluteCount = folded.filter { Lexicon.absolutes.contains($0) }.count
        signals.negativeCount = folded.filter {
            Lexicon.negativeExact.contains($0) || hasStem($0, in: Lexicon.negativeStems)
        }.count
        signals.warmCount = folded.filter { hasStem($0, in: Lexicon.warmStems) }.count
        signals.urgencyCount = folded.filter { Lexicon.urgency.contains($0) }.count
        signals.apologyCount = folded.filter { hasStem($0, in: Lexicon.apologyStems) }.count
        signals.timeReferenceCount = folded.filter { Lexicon.timeWords.contains($0) }.count

        let padded = " " + normalizedPhrase(trimmed) + " "
        signals.hasRefusalCue = Lexicon.refusalPhrases.contains { padded.contains(" " + $0 + " ") }

        return signals
    }

    // MARK: Helpers

    /// Lowercase and without diacritics, including Polish "ł" which Foundation does not fold.
    static func fold(_ text: String) -> String {
        text.lowercased()
            .folding(options: .diacriticInsensitive, locale: nil)
            .replacingOccurrences(of: "ł", with: "l")
    }

    private static func hasStem(_ word: String, in stems: [String]) -> Bool {
        stems.contains { word.hasPrefix($0) }
    }

    private static func isShouted(_ word: String) -> Bool {
        word.count >= 3 && word == word.uppercased() && word.contains { $0.isLetter }
    }

    private static func tokenize(_ text: String, unit: NLTokenUnit) -> [String] {
        let tokenizer = NLTokenizer(unit: unit)
        tokenizer.string = text
        var result: [String] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            result.append(String(text[range]))
            return true
        }
        return result
    }

    private static func detectLanguage(_ text: String) -> TextLanguage {
        // Polish letters are decisive; otherwise let NaturalLanguage choose between Polish and English.
        let polishLetters = "ąćęłńóśźżĄĆĘŁŃÓŚŹŻ"
        if text.contains(where: { polishLetters.contains($0) }) { return .polish }
        let recognizer = NLLanguageRecognizer()
        recognizer.languageConstraints = [.polish, .english]
        recognizer.processString(text)
        let detected = recognizer.dominantLanguage
        if detected == .polish { return .polish }
        if detected == .english { return .english }
        return .unknown
    }

    /// Words only, folded, apostrophes removed, single spaces.
    private static func normalizedPhrase(_ text: String) -> String {
        var result = ""
        for character in fold(text) {
            if character.isLetter || character.isNumber {
                result.append(character)
            } else if character == "'" || character == "\u{2019}" {
                continue
            } else {
                result.append(" ")
            }
        }
        return result.split(separator: " ").joined(separator: " ")
    }
}
