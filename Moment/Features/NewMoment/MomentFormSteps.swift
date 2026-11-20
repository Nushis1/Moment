import Foundation
import SwiftUI
import MomentCore

struct SituationStep: View {
    @Binding var input: MomentInput

    private var showsHint: Bool {
        !input.trimmedSituation.isEmpty && !input.hasValidSituation
    }

    var body: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.l) {
            ScreenHeading(
                title: "What happened?",
                subtitle: "Describe the situation in your own words. Stick to facts where you can."
            )
            MomentTextEditor(
                placeholder: "For example: They haven't replied since Monday and I don't know whether to write.",
                text: $input.situation,
                minHeight: 180
            )
            if showsHint {
                Label("Add a little more so the analysis has something to work with.", systemImage: "info.circle")
                    .font(.momentCaption)
                    .foregroundStyle(MomentColor.caution)
            }
        }
    }
}

struct RelationshipStep: View {
    @Binding var input: MomentInput

    var body: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.l) {
            ScreenHeading(
                title: "Who is this about?",
                subtitle: "The kind of relationship changes what a good next step looks like."
            )
            ChoiceGroup(
                items: RelationshipType.allCases,
                selection: $input.relationship,
                name: { $0.name },
                symbol: { $0.symbol }
            )
        }
    }
}

struct GoalStep: View {
    @Binding var input: MomentInput

    var body: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.l) {
            ScreenHeading(
                title: "What do you want to figure out?",
                subtitle: "Pick the closest one. You decide what happens next."
            )
            VStack(spacing: MomentSpacing.s) {
                ForEach(UserGoal.allCases) { goal in
                    OptionRow(
                        title: goal.name,
                        subtitle: goal.detail,
                        systemImage: goal.symbol,
                        isSelected: input.goal == goal
                    ) {
                        input.goal = goal
                    }
                }
            }
        }
    }
}

struct EmotionStep: View {
    @Binding var input: MomentInput

    var body: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.xl) {
            VStack(alignment: .leading, spacing: MomentSpacing.l) {
                ScreenHeading(
                    title: "How are you feeling right now?",
                    subtitle: "There's no wrong answer. This helps weigh how quickly to act."
                )
                ChoiceGroup(
                    items: EmotionalState.allCases,
                    selection: $input.emotion,
                    name: { $0.name },
                    symbol: { $0.symbol }
                )
            }

            VStack(alignment: .leading, spacing: MomentSpacing.m) {
                SectionHeader(title: "How soon do you need to decide?")
                Picker("How soon do you need to decide?", selection: $input.urgency) {
                    ForEach(Urgency.allCases) { urgency in
                        Text(urgency.name).tag(urgency)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

struct ContextStep: View {
    @Environment(MomentStore.self) private var store
    @Binding var input: MomentInput

    var body: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.xl) {
            ScreenHeading(
                title: "Anything else worth adding?",
                subtitle: "All optional. More detail means a more complete analysis."
            )

            VStack(alignment: .leading, spacing: MomentSpacing.s) {
                SectionHeader(title: "A message you received or want to send")
                MomentTextEditor(placeholder: "Paste it here", text: $input.message, minHeight: 110)
            }

            VStack(alignment: .leading, spacing: MomentSpacing.s) {
                SectionHeader(title: "Other context")
                MomentTextEditor(placeholder: "History, plans, what you already tried", text: $input.context, minHeight: 110)
            }

            if !store.people.isEmpty {
                VStack(alignment: .leading, spacing: MomentSpacing.s) {
                    SectionHeader(title: "Link to a person")
                    Picker("Person", selection: $input.personID) {
                        Text("No one in particular").tag(UUID?.none)
                        ForEach(store.sortedPeople) { person in
                            Text(person.nickname).tag(Optional(person.id))
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(MomentColor.accent)
                }
            }
        }
    }
}
