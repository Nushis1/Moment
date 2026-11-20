import Foundation
import MomentCore

// TEMPORARY (phase 1). Sample content so History, People and Insights can be reviewed.
// Loaded only when the person taps "Load demo data" in Settings. Removed in phase 2.

enum DemoData {
    static var people: [PersonEntry] {
        let calendar = Calendar.current
        return [
            PersonEntry(
                nickname: "Alex",
                relationship: .dating,
                metOn: calendar.date(byAdding: .month, value: -3, to: .now),
                notes: "Met at a friend's birthday. Likes hiking and long messages."
            ),
            PersonEntry(
                nickname: "Sam",
                relationship: .friend,
                metOn: calendar.date(byAdding: .year, value: -6, to: .now),
                notes: "Old friend. We talk in bursts, then not for weeks."
            ),
        ]
    }

    static func decisions(people: [PersonEntry]) -> [DecisionEntry] {
        let calendar = Calendar.current
        let situations: [(String, RelationshipType, UserGoal, EmotionalState, DecisionOutcome?, Int)] = [
            ("They haven't answered since Monday and I keep checking my phone.", .dating, .wait, .anxious, .asExpected, 2),
            ("Sam suggested meeting, but I'm unsure I have the energy.", .friend, .reply, .confused, .different, 5),
            ("I want to say how much our last conversation meant to me.", .dating, .shareFeelings, .hopeful, .asExpected, 9),
            ("A message came in late at night and it felt cold.", .dating, .reply, .hurt, nil, 14),
            ("I'm thinking about reaching out first after a quiet month.", .friend, .writeFirst, .calm, .noResult, 21),
            ("Should I wait before answering after the argument?", .dating, .wait, .angry, .asExpected, 30),
        ]

        return situations.enumerated().map { index, item in
            let person = people.first { $0.relationship == item.1 }
            let input = MomentInput(
                situation: item.0,
                relationship: item.1,
                goal: item.2,
                emotion: item.3,
                urgency: .medium,
                personID: person?.id
            )
            let analysis = DemoAnalyzer.makeAnalysis(for: input)
            let followed = index % 3 != 2
            let selected = followed
                ? analysis.recommendedScenarioID
                : (analysis.scenarios.first { $0.id != analysis.recommendedScenarioID }?.id ?? analysis.recommendedScenarioID)
            return DecisionEntry(
                createdAt: calendar.date(byAdding: .day, value: -item.5, to: .now) ?? .now,
                input: input,
                analysis: analysis,
                selectedScenarioID: selected,
                outcome: item.4,
                rating: item.4 == nil ? nil : 4,
                reflection: item.4 == nil ? "" : "Worth pausing before I acted."
            )
        }
    }
}
