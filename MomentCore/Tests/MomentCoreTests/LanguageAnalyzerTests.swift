import Testing
@testable import MomentCore

@Suite("Language analysis")
struct LanguageAnalyzerTests {
    @Test("Empty text produces empty signals")
    func emptyText() {
        #expect(LanguageAnalyzer.analyze("   ").isEmpty)
    }

    @Test("Polish letters identify Polish, and questions are counted")
    func polishQuestion() {
        let signals = LanguageAnalyzer.analyze("Cześć, co u ciebie słychać?")
        #expect(signals.language == .polish)
        #expect(signals.questionCount == 1)
        #expect(signals.wordCount >= 4)
    }

    @Test("Folding removes diacritics including Polish ł")
    func folding() {
        #expect(LanguageAnalyzer.fold("ŁÓDŹ Zażółć") == "lodz zazolc")
    }

    @Test("Capital letters, exclamations and tense wording are counted, not judged")
    func shoutedText() {
        let signals = LanguageAnalyzer.analyze("I AM SO ANGRY!!")
        #expect(signals.uppercaseWordCount == 1)
        #expect(signals.exclamationCount == 2)
        #expect(signals.negativeCount >= 1)
    }

    @Test("Softeners and absolutes are detected in both languages")
    func softenersAndAbsolutes() {
        let english = LanguageAnalyzer.analyze("Maybe you always do this")
        #expect(english.softenerCount == 1)
        #expect(english.absoluteCount == 1)
        let polish = LanguageAnalyzer.analyze("Może ty zawsze tak robisz")
        #expect(polish.softenerCount == 1)
        #expect(polish.absoluteCount == 1)
    }

    @Test("Requests for distance are recognized in Polish and English")
    func refusalCues() {
        #expect(LanguageAnalyzer.analyze("Powiedziała mi: nie pisz do mnie więcej.").hasRefusalCue)
        #expect(LanguageAnalyzer.analyze("Please don't text me again.").hasRefusalCue)
        #expect(LanguageAnalyzer.analyze("She told me to leave me alone.").hasRefusalCue)
    }

    @Test("Similar wording that is not a refusal is not flagged")
    func refusalFalsePositives() {
        #expect(LanguageAnalyzer.analyze("Nie piszę do ciebie, bo jestem zajęty.").hasRefusalCue == false)
        #expect(LanguageAnalyzer.analyze("She said she does not want pizza.").hasRefusalCue == false)
    }

    @Test("Time references are found")
    func timeReferences() {
        #expect(LanguageAnalyzer.analyze("Nie odpisuje od poniedziałku").timeReferenceCount == 1)
        #expect(LanguageAnalyzer.analyze("No reply since yesterday").timeReferenceCount >= 2)
    }
}
