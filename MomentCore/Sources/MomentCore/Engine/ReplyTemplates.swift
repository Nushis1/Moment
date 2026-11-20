import Foundation

/// Hand-written reply building blocks in the language of the received message.
/// These are output text, not interface strings, so they are not part of the string catalog.
/// Polish wording avoids gendered verb forms so it fits any writer.
enum ReplyTemplates {
    struct Body {
        let full: String
        let short: String
    }

    struct Pack {
        let openers: [ReplyTone: String]
        let closers: [ReplyTone: String]
        let bodies: [ReplyIntent: Body]
        let acknowledgement: String
    }

    static func pack(for language: TextLanguage) -> Pack {
        language == .polish ? polish : english
    }

    static let english = Pack(
        openers: [
            .natural: "Hi,",
            .direct: "Hi, I'll be straightforward:",
            .gentle: "Hi, I hope you're doing well.",
            .confident: "Hey,",
            .light: "Hey there,",
            .flirty: "Hey you,",
            .neutral: "Hello,",
        ],
        closers: [
            .natural: "",
            .direct: "Let me know what you think.",
            .gentle: "Take whatever time you need.",
            .confident: "",
            .light: "",
            .flirty: "Looking forward to hearing from you.",
            .neutral: "",
        ],
        bodies: [
            .reply: Body(full: "Thanks for your message, I appreciate you writing.", short: "Thanks for writing."),
            .askQuestion: Body(full: "I'd like to understand better. Could you tell me a bit more about what you mean?", short: "Could you tell me more about that?"),
            .showInterest: Body(full: "I'd really like to keep talking and get to know you better.", short: "I'd like to talk more."),
            .setBoundary: Body(full: "I want to be honest that I need things to go at a slower pace for me.", short: "I need a bit more space right now."),
            .decline: Body(full: "Thank you for asking. I'm going to pass this time.", short: "Thanks, but I'll pass this time."),
            .followUp: Body(full: "I wanted to follow up on our last conversation. No pressure to answer right away.", short: "Just following up, no pressure."),
        ],
        acknowledgement: "Understood. I'll respect that."
    )

    static let polish = Pack(
        openers: [
            .natural: "Cześć,",
            .direct: "Cześć, powiem wprost:",
            .gentle: "Cześć, mam nadzieję, że u ciebie dobrze.",
            .confident: "Hej,",
            .light: "Hej, hej,",
            .flirty: "Hej ty,",
            .neutral: "Dzień dobry,",
        ],
        closers: [
            .natural: "",
            .direct: "Daj znać, co o tym myślisz.",
            .gentle: "Weź tyle czasu, ile potrzebujesz.",
            .confident: "",
            .light: "",
            .flirty: "Czekam na twoją odpowiedź.",
            .neutral: "",
        ],
        bodies: [
            .reply: Body(full: "Dzięki za wiadomość, miło, że piszesz.", short: "Dzięki, że piszesz."),
            .askQuestion: Body(full: "Chcę lepiej zrozumieć. Opowiesz mi trochę więcej, co masz na myśli?", short: "Opowiesz mi więcej o tym?"),
            .showInterest: Body(full: "Chcę dalej rozmawiać i lepiej cię poznać.", short: "Chcę pogadać więcej."),
            .setBoundary: Body(full: "Powiem szczerze: potrzebuję, żeby to szło wolniejszym tempem.", short: "Potrzebuję teraz trochę przestrzeni."),
            .decline: Body(full: "Dziękuję za propozycję. Tym razem odpuszczę.", short: "Dzięki, ale tym razem odpuszczę."),
            .followUp: Body(full: "Wracam do naszej ostatniej rozmowy. Bez presji na szybką odpowiedź.", short: "Daję tylko znać, że wracam do tematu, bez presji."),
        ],
        acknowledgement: "Rozumiem. Uszanuję to."
    )
}
