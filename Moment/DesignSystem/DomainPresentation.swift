import Foundation
import SwiftUI
import MomentCore

// Localized names and SF Symbols for domain values. The domain stays free of UI concerns.

extension RelationshipType {
    var name: String {
        switch self {
        case .partner: String(localized: "Partner")
        case .dating: String(localized: "Dating or getting to know")
        case .friend: String(localized: "Friend")
        case .family: String(localized: "Family")
        case .work: String(localized: "Work")
        case .ex: String(localized: "Ex")
        case .other: String(localized: "Someone else")
        }
    }

    var symbol: String {
        switch self {
        case .partner: "heart"
        case .dating: "sparkles"
        case .friend: "person.2"
        case .family: "house"
        case .work: "briefcase"
        case .ex: "arrow.uturn.backward"
        case .other: "person"
        }
    }
}

extension UserGoal {
    var name: String {
        switch self {
        case .writeFirst: String(localized: "Decide whether to write")
        case .reply: String(localized: "Decide how to reply")
        case .wait: String(localized: "Decide whether to wait")
        case .takeFirstStep: String(localized: "Take the first step")
        case .continueAcquaintance: String(localized: "Continue getting to know someone")
        case .shareFeelings: String(localized: "Share how I feel")
        case .endContact: String(localized: "End contact")
        case .other: String(localized: "Something else")
        }
    }

    var detail: String {
        switch self {
        case .writeFirst: String(localized: "Should I be the one to reach out?")
        case .reply: String(localized: "I received something and I'm not sure how to answer.")
        case .wait: String(localized: "Maybe it's better to give it some time.")
        case .takeFirstStep: String(localized: "Suggest a meeting, a call or a change.")
        case .continueAcquaintance: String(localized: "Keep the connection going at a good pace.")
        case .shareFeelings: String(localized: "Say something honest and personal.")
        case .endContact: String(localized: "Step back or close a chapter calmly.")
        case .other: String(localized: "A situation that doesn't fit the options above.")
        }
    }

    var symbol: String {
        switch self {
        case .writeFirst: "square.and.pencil"
        case .reply: "arrowshape.turn.up.left"
        case .wait: "clock"
        case .takeFirstStep: "figure.walk"
        case .continueAcquaintance: "arrow.triangle.branch"
        case .shareFeelings: "text.bubble"
        case .endContact: "hand.raised"
        case .other: "ellipsis.circle"
        }
    }
}

extension EmotionalState {
    var name: String {
        switch self {
        case .calm: String(localized: "Calm")
        case .hopeful: String(localized: "Hopeful")
        case .excited: String(localized: "Excited")
        case .anxious: String(localized: "Anxious")
        case .confused: String(localized: "Confused")
        case .hurt: String(localized: "Hurt")
        case .angry: String(localized: "Angry")
        case .sad: String(localized: "Sad")
        }
    }

    var symbol: String {
        switch self {
        case .calm: "leaf"
        case .hopeful: "sun.max"
        case .excited: "sparkles"
        case .anxious: "waveform.path.ecg"
        case .confused: "questionmark.circle"
        case .hurt: "heart.slash"
        case .angry: "flame"
        case .sad: "cloud.rain"
        }
    }
}

extension Urgency {
    var name: String {
        switch self {
        case .low: String(localized: "No rush")
        case .medium: String(localized: "Today")
        case .high: String(localized: "Right now")
        }
    }
}

extension ActionKind {
    var symbol: String {
        switch self {
        case .writeNow: "paperplane"
        case .waitUntilCalm: "hourglass"
        case .giveSpace: "moon.zzz"
        case .speakInPerson: "person.wave.2"
        case .closeContact: "door.left.hand.closed"
        }
    }
}

extension ConfidenceLevel {
    var name: String {
        switch self {
        case .low: String(localized: "Low")
        case .moderate: String(localized: "Moderate")
        case .good: String(localized: "Good")
        }
    }
}

extension DecisionOutcome {
    var name: String {
        switch self {
        case .asExpected: String(localized: "As expected")
        case .different: String(localized: "Different than expected")
        case .noResult: String(localized: "No result")
        case .notSureYet: String(localized: "Not sure yet")
        case .preferNotToSay: String(localized: "Prefer not to say")
        }
    }

    var symbol: String {
        switch self {
        case .asExpected: "checkmark.circle"
        case .different: "arrow.triangle.swap"
        case .noResult: "minus.circle"
        case .notSureYet: "questionmark.circle"
        case .preferNotToSay: "eye.slash"
        }
    }
}

extension ReplyIntent {
    var name: String {
        switch self {
        case .reply: String(localized: "Reply")
        case .askQuestion: String(localized: "Ask a question")
        case .showInterest: String(localized: "Show interest")
        case .setBoundary: String(localized: "Set a boundary")
        case .decline: String(localized: "Decline politely")
        case .followUp: String(localized: "Follow up")
        }
    }

    var symbol: String {
        switch self {
        case .reply: "arrowshape.turn.up.left"
        case .askQuestion: "questionmark.bubble"
        case .showInterest: "heart.text.square"
        case .setBoundary: "hand.raised"
        case .decline: "xmark.circle"
        case .followUp: "arrow.clockwise"
        }
    }
}

extension ReplyTone {
    var name: String {
        switch self {
        case .natural: String(localized: "Natural")
        case .direct: String(localized: "Direct")
        case .gentle: String(localized: "Gentle")
        case .confident: String(localized: "Confident")
        case .light: String(localized: "Light")
        case .flirty: String(localized: "Flirty")
        case .neutral: String(localized: "Neutral")
        }
    }
}

extension CommunicationStyle {
    var name: String {
        switch self {
        case .direct: String(localized: "Direct")
        case .balanced: String(localized: "Balanced")
        case .gentle: String(localized: "Gentle")
        }
    }
}

extension CommunicationPace {
    var name: String {
        switch self {
        case .quick: String(localized: "Quick")
        case .balanced: String(localized: "Balanced")
        case .slow: String(localized: "Slow")
        }
    }
}

extension UncertaintyTolerance {
    var name: String {
        switch self {
        case .low: String(localized: "I prefer clarity")
        case .medium: String(localized: "It depends")
        case .high: String(localized: "I'm fine with open questions")
        }
    }
}

extension ConflictApproach {
    var name: String {
        switch self {
        case .avoid: String(localized: "Avoid if possible")
        case .calmTalk: String(localized: "Talk it through calmly")
        case .direct: String(localized: "Address it directly")
        }
    }
}
