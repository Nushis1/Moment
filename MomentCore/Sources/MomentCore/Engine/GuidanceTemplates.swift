import Foundation

/// Example messages in the language of the situation. Output text, not interface strings.
/// They open a conversation or close it kindly; none pressures anyone, and Polish wording
/// avoids gendered verb forms.
enum GuidanceTemplates {
    struct Pack {
        let reachOut: String
        let invite: String
        let openUp: String
        let holding: String
        let talkOpener: String
        let closing: String
    }

    static func pack(for language: TextLanguage) -> Pack {
        language == .polish ? polish : english
    }

    static let english = Pack(
        reachOut: "Hi, I wanted to say hello and see how you are. How has your week been?",
        invite: "Hi, I'd like to see you. Are you free for a coffee this week?",
        openUp: "There's something I'd like to share with you honestly. Do you have a few minutes to talk?",
        holding: "Hey, I got your message. I'd like to answer properly, so I'll get back to you later today.",
        talkOpener: "Can we talk when you have a few minutes? There's something I'd like to say in person.",
        closing: "I've been thinking about this a lot, and I'd like to step back from contact. I wish you well."
    )

    static let polish = Pack(
        reachOut: "Cześć, przyszło mi do głowy, żeby się odezwać. Jak ci mija tydzień?",
        invite: "Cześć, chcę się z tobą spotkać. Masz w tym tygodniu czas na kawę?",
        openUp: "Jest coś, o czym chcę z tobą szczerze porozmawiać. Masz chwilę?",
        holding: "Hej, widzę twoją wiadomość. Chcę odpowiedzieć porządnie, więc odezwę się później.",
        talkOpener: "Możemy porozmawiać, gdy będziesz mieć chwilę? Chcę coś powiedzieć na żywo.",
        closing: "Dużo o tym myślę i chcę się wycofać z kontaktu. Życzę ci wszystkiego dobrego."
    )
}
