import Foundation
import SwiftUI
import MomentCore

struct HomeView: View {
    @Environment(MomentStore.self) private var store
    @Environment(Router.self) private var router

    private var greeting: LocalizedStringKey {
        switch Calendar.current.component(.hour, from: .now) {
        case 5..<12: "Good morning"
        case 12..<18: "Good afternoon"
        case 18..<22: "Good evening"
        default: "Good night"
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MomentSpacing.xl) {
                header
                PrimaryButton(title: "New Moment", systemImage: "plus") {
                    router.startNewMoment()
                }
                replyShortcut
                lastDecisionSection
                observationSection
            }
            .padding(.horizontal, MomentSpacing.l)
            .padding(.bottom, MomentSpacing.xxl)
        }
        .momentBackground()
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.openSettings()
                } label: {
                    Image(systemName: "person.crop.circle")
                }
                .accessibilityLabel("Profile and settings")
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.xs) {
            Text(greeting)
                .font(.momentDisplay)
                .foregroundStyle(MomentColor.primary)
            Text("What's on your mind?")
                .font(.momentTitle)
                .foregroundStyle(MomentColor.secondary)
        }
        .padding(.top, MomentSpacing.l)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    private var replyShortcut: some View {
        Button {
            router.selectedTab = .reply
        } label: {
            HStack(spacing: MomentSpacing.m) {
                Image(systemName: "text.bubble")
                    .font(.title3)
                    .foregroundStyle(MomentColor.accent)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Reply Studio")
                        .font(.momentHeadline)
                        .foregroundStyle(MomentColor.primary)
                    Text("Paste a message and think through your answer.")
                        .font(.momentCaption)
                        .foregroundStyle(MomentColor.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(MomentColor.secondary)
                    .accessibilityHidden(true)
            }
            .momentCard()
        }
        .buttonStyle(.plain)
    }

    private var lastDecisionSection: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.m) {
            SectionHeader(title: "Last decision")

            if let entry = store.lastDecision {
                NavigationLink(value: Route.decision(entry.id)) {
                    DecisionCard(entry: entry)
                }
                .buttonStyle(.plain)
            } else {
                Text("Decisions you save will show up here.")
                    .font(.momentBody)
                    .foregroundStyle(MomentColor.secondary)
                    .momentCard()
            }
        }
    }

    private var observationSection: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.m) {
            SectionHeader(title: "A personal observation")
            ObservationCard(summary: store.insights)
        }
    }
}

/// Compact summary of a saved decision, shared by Home and lists.
struct DecisionCard: View {
    let entry: DecisionEntry

    var body: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.s) {
            Text(entry.createdAt, format: .dateTime.day().month(.wide).year())
                .font(.momentCaption)
                .foregroundStyle(MomentColor.secondary)
            Text(entry.input.trimmedSituation)
                .font(.momentBody)
                .foregroundStyle(MomentColor.primary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            HStack(spacing: MomentSpacing.s) {
                if let selected = entry.selectedScenario {
                    Label(selected.title, systemImage: selected.action.symbol)
                        .font(.system(.footnote, weight: .medium))
                        .foregroundStyle(MomentColor.accent)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                OutcomeBadge(outcome: entry.outcome)
            }
        }
        .momentCard()
    }
}

/// One careful, descriptive sentence about the person's own history, or a hint about how to unlock it.
struct ObservationCard: View {
    let summary: InsightsSummary

    var body: some View {
        Group {
            if let goal = summary.topGoal {
                Text("Most of your saved moments are about: \(goal.name)")
            } else if let emotion = summary.topEmotion {
                Text("You most often come to MOMENT feeling \(emotion.name).")
            } else if summary.hasEnoughData {
                Text("Your saved moments are varied. No clear pattern stands out yet.")
            } else {
                Text("Observations appear after you've saved a few decisions. Nothing is concluded from a single situation.")
            }
        }
        .font(.momentBody)
        .foregroundStyle(MomentColor.primary)
        .momentCard()
    }
}

#Preview("Empty") {
    NavigationStack { HomeView() }
        .environment(MomentStore())
        .environment(Router())
}
