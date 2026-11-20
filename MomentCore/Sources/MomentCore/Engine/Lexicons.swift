import Foundation

/// Small hand-written Polish and English word lists. Entries are stored folded: lowercase,
/// without diacritics. No single word is ever treated as proof of what someone means.
enum Lexicon {
    static let softeners: Set<String> = [
        "moze", "chyba", "raczej", "ewentualnie", "troche", "troszke",
        "perhaps", "maybe", "probably", "possibly", "somewhat", "slightly", "kinda",
    ]

    static let absolutes: Set<String> = [
        "zawsze", "nigdy", "wszyscy", "nikt", "wcale", "wszystko",
        "always", "never", "everyone", "nobody", "everything", "nothing",
    ]

    static let negativeStems: [String] = [
        "wkurz", "zdenerw", "zlosc", "smutn", "przykro", "nienawid", "irytuj", "wscieka",
        "rozczarow", "zawiod", "angry", "upset", "annoy", "disappoint", "hate", "hurt",
        "furious", "frustrat",
    ]
    static let negativeExact: Set<String> = ["zly", "zla", "sad"]

    static let warmStems: [String] = [
        "dziek", "tesknie", "teskni", "kocham", "lubie", "ciesz", "swietn", "wspanial",
        "thank", "miss", "love", "glad", "great", "wonderful", "happy", "nice", "milo",
    ]

    static let urgency: Set<String> = [
        "pilne", "pilnie", "natychmiast", "asap", "urgent", "immediately", "szybko", "quickly",
        "teraz", "now",
    ]

    static let apologyStems: [String] = ["przepras", "sorry", "apolog", "wybacz", "forgive"]

    static let timeWords: Set<String> = [
        "dzis", "wczoraj", "dni", "dzien", "tydzien", "tygodnie", "tygodni", "miesiac", "miesiace",
        "rano", "wieczorem", "poniedzialku", "wtorku", "sroda", "srode", "czwartku", "piatku",
        "sobote", "niedziele",
        "today", "yesterday", "week", "weeks", "days", "day", "month", "monday", "tuesday",
        "wednesday", "thursday", "friday", "saturday", "sunday", "ago", "since", "last",
    ]

    /// Phrases that mean the other person asked for distance. Matched on whole words,
    /// after folding and with apostrophes removed.
    static let refusalPhrases: [String] = [
        "nie pisz do mnie", "nie pisz juz do mnie", "nie dzwon do mnie", "zostaw mnie w spokoju",
        "zostaw mnie", "daj mi spokoj", "nie chce z toba rozmawiac", "nie chce miec z toba kontaktu",
        "nie kontaktuj sie ze mna", "przestan do mnie pisac", "zablokowal mnie", "zablokowala mnie",
        "dont text me", "do not text me", "dont contact me", "do not contact me", "leave me alone",
        "stop texting me", "stop messaging me", "stop contacting me", "blocked me",
        "i dont want to talk to you", "i do not want to talk to you", "asked me not to contact",
        "asked me to stop",
    ]
}
