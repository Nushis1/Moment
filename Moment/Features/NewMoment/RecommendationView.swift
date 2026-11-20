import Foundation
import SwiftUI
import UIKit
import MomentCore

struct RecommendationView: View {
    let input: MomentInput
    let analysis: MomentAnalysis
    let onFinish: () -> Void

    @Environment(MomentStore.self) private var store
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var selectedID: UUID
    @State private var saved = false

    init(input: MomentInput, analysis: MomentAnalysis, onFinish: @escaping () -> Void) {
        self.input = input
        self.analysis = analysis
        self.onFinish = onFinish
        _selectedID = State(initialValue: analysis.recommendedScenarioID)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MomentSpacing.xl) {
                summarySection
                recommendedSection
                argumentsSection
                scenariosSection
                gapsSection
                disclaimer
            }
            .padding(.horizontal, MomentSpacing.l)
            .padding(.bottom, MomentSpacing.xl)
        }
        .momentBackground()
        .safeAreaInset(edge: .bottom) {
            PrimaryButton(title: "Save my decision", systemImage: "checkmark") { save() }
                .padding(.horizontal, MomentSpacing.l)
                .padding(.vertical, MomentSpacing.s)
        }
        .sensoryFeedback(.success, trigger: saved)
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.m) {
            SectionHeader(title: "What I understood")
            Text(analysis.summary)
                .font(.momentBody)
                .foregroundStyle(MomentColor.primary)
                .momentCard()
        }
    }

    @ViewBuilder
    private var recommendedSection: some View {
        if let scenario = analysis.recommendedScenario {
            VStack(alignment: .leading, spacing: MomentSpacing.m) {
                SectionHeader(title: "Suggested next step")
                VStack(alignment: .leading, spacing: MomentSpacing.m) {
                    Label(scenario.title, systemImage: scenario.action.symbol)
                        .font(.momentTitle)
                        .foregroundStyle(MomentColor.primary)
                    Text(analysis.recommendationReason)
                        .font(.momentBody)
                        .foregroundStyle(MomentColor.secondary)
                    ConfidenceBadge(level: analysis.confidence)
                    Text("Confidence shows how complete your input was. It is not a chance of success.")
                        .font(.momentCaption)
                        .foregroundStyle(MomentColor.secondary)

                    Divider()
                    ScenarioGuidanceView(scenario: scenario)

                    if input.goal == .reply && !input.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        SecondaryButton(title: "Write the reply in Reply Studio", systemImage: "text.bubble") {
                            router.openReplyStudio(with: ReplyInput(receivedMessage: input.message))
                        }
                    }
                }
                .momentCard()
            }
        }
    }

    private var argumentsSection: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.m) {
            SectionHeader(title: "Two ways to look at it")
            VStack(alignment: .leading, spacing: MomentSpacing.l) {
                VStack(alignment: .leading, spacing: MomentSpacing.s) {
                    Text("For acting now")
                        .font(.system(.subheadline, weight: .semibold))
                        .foregroundStyle(MomentColor.accent)
                    BulletList(items: analysis.argumentsForActing)
                }
                Divider()
                VStack(alignment: .leading, spacing: MomentSpacing.s) {
                    Text("For pausing")
                        .font(.system(.subheadline, weight: .semibold))
                        .foregroundStyle(MomentColor.accent)
                    BulletList(items: analysis.argumentsForPausing)
                }
            }
            .momentCard()
        }
    }

    private var scenariosSection: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.m) {
            SectionHeader(
                title: "Your options",
                subtitle: "Choose the one you plan to follow. It doesn't have to be the suggested one."
            )
            ForEach(analysis.scenarios) { scenario in
                ScenarioCard(
                    scenario: scenario,
                    isRecommended: scenario.id == analysis.recommendedScenarioID,
                    isSelected: scenario.id == selectedID
                ) {
                    selectedID = scenario.id
                }
            }
            Text("Scores only compare these options for you. They don't predict how anyone will react.")
                .font(.momentCaption)
                .foregroundStyle(MomentColor.secondary)
        }
    }

    @ViewBuilder
    private var gapsSection: some View {
        if !analysis.missingInformation.isEmpty || analysis.followUpQuestion != nil {
            VStack(alignment: .leading, spacing: MomentSpacing.m) {
                SectionHeader(title: "What would sharpen this")
                VStack(alignment: .leading, spacing: MomentSpacing.m) {
                    if !analysis.missingInformation.isEmpty {
                        BulletList(items: analysis.missingInformation, tint: MomentColor.caution)
                    }
                    if let question = analysis.followUpQuestion {
                        Text(question)
                            .font(.system(.body, weight: .medium))
                            .foregroundStyle(MomentColor.primary)
                    }
                    SecondaryButton(title: "Add more detail", systemImage: "plus.bubble") {
                        dismiss()
                    }
                }
                .momentCard()
            }
        }
    }

    private var disclaimer: some View {
        Text("MOMENT helps you think. It can't know what another person feels, and the decision is always yours.")
            .font(.momentCaption)
            .foregroundStyle(MomentColor.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func save() {
        guard !saved else { return }
        saved = true
        store.saveDecision(input: input, analysis: analysis, selectedScenarioID: selectedID)
        onFinish()
    }
}

struct ScenarioCard: View {
    let scenario: Scenario
    let isRecommended: Bool
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.m) {
            Button(action: onSelect) {
                HStack(alignment: .top, spacing: MomentSpacing.m) {
                    Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                        .foregroundStyle(isSelected ? MomentColor.accent : MomentColor.secondary)
                        .padding(.top, 2)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: MomentSpacing.s) {
                        HStack(spacing: MomentSpacing.s) {
                            Text(scenario.title)
                                .font(.momentHeadline)
                                .foregroundStyle(MomentColor.primary)
                                .multilineTextAlignment(.leading)
                            if isRecommended {
                                TagLabel(text: "Suggested")
                            }
                        }
                        Text(scenario.rationale)
                            .font(.momentCaption)
                            .foregroundStyle(MomentColor.secondary)
                            .multilineTextAlignment(.leading)
                        ScoreBar(value: scenario.score)
                    }
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isSelected ? [.isSelected] : [])

            DisclosureGroup("Details") {
                VStack(alignment: .leading, spacing: MomentSpacing.m) {
                    ScenarioGuidanceView(scenario: scenario)
                    if !scenario.pros.isEmpty {
                        BulletList(items: scenario.pros, tint: MomentColor.positive)
                    }
                    if !scenario.cons.isEmpty {
                        BulletList(items: scenario.cons, tint: MomentColor.caution)
                    }
                }
                .padding(.top, MomentSpacing.s)
            }
            .font(.momentCaption)
            .tint(MomentColor.accent)
        }
        .momentCard()
        .overlay {
            RoundedRectangle(cornerRadius: MomentRadius.card, style: .continuous)
                .strokeBorder(isSelected ? MomentColor.accent : Color.clear, lineWidth: 1.5)
        }
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}


/// How long, what to do and what to say for one option. Durations are rules of thumb.
struct ScenarioGuidanceView: View {
    let scenario: Scenario

    var body: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.m) {
            if let timeframe = scenario.timeframe {
                Label {
                    Text(timeframe)
                        .font(.system(.subheadline, weight: .medium))
                        .foregroundStyle(MomentColor.primary)
                        .fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Image(systemName: "clock")
                        .foregroundStyle(MomentColor.accent)
                }
            }

            if !scenario.steps.isEmpty {
                VStack(alignment: .leading, spacing: MomentSpacing.s) {
                    Text("How to do it")
                        .font(.system(.subheadline, weight: .semibold))
                        .foregroundStyle(MomentColor.accent)
                    ForEach(Array(scenario.steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .firstTextBaseline, spacing: MomentSpacing.s) {
                            Text(verbatim: "\(index + 1).")
                                .font(.system(.footnote, weight: .semibold).monospacedDigit())
                                .foregroundStyle(MomentColor.secondary)
                                .frame(width: 20, alignment: .leading)
                                .accessibilityHidden(true)
                            Text(step)
                                .font(.momentBody)
                                .foregroundStyle(MomentColor.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }

            if let message = scenario.sampleMessage {
                SampleMessageView(action: scenario.action, message: message)
            }

            if scenario.timeframe != nil {
                Text("Timeframes are rules of thumb, not predictions.")
                    .font(.momentCaption)
                    .foregroundStyle(MomentColor.secondary)
            }
        }
    }
}

/// An example of what to say, with a copy button. Meant to be edited, never sent blindly.
struct SampleMessageView: View {
    let action: ActionKind
    let message: String

    @State private var copied = false

    private var label: LocalizedStringKey {
        switch action {
        case .waitUntilCalm: "Optional holding message"
        case .closeContact: "Example closing message"
        default: "Example opener"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.s) {
            Text(label)
                .font(.system(.subheadline, weight: .semibold))
                .foregroundStyle(MomentColor.accent)
            Text(message)
                .font(.momentBody)
                .foregroundStyle(MomentColor.primary)
                .textSelection(.enabled)
                .padding(MomentSpacing.m)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(MomentColor.background, in: .rect(cornerRadius: MomentRadius.control, style: .continuous))
            Text("Change it so it sounds like you.")
                .font(.momentCaption)
                .foregroundStyle(MomentColor.secondary)
            Button {
                UIPasteboard.general.string = message
                copied = true
            } label: {
                if copied {
                    Label("Copied", systemImage: "checkmark")
                } else {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            }
            .buttonStyle(.glass)
            .sensoryFeedback(.success, trigger: copied)
        }
    }
}
