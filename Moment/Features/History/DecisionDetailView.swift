import Foundation
import SwiftUI
import MomentCore

struct DecisionDetailView: View {
    let id: UUID
    @Environment(MomentStore.self) private var store

    var body: some View {
        Group {
            if let entry = store.decision(id: id) {
                DecisionDetailContent(entry: entry)
            } else {
                MomentEmptyState(
                    title: "Decision not found",
                    systemImage: "questionmark.folder",
                    message: "It may have been deleted."
                )
            }
        }
        .momentBackground()
    }
}

private struct DecisionDetailContent: View {
    let entry: DecisionEntry

    @Environment(MomentStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var outcome: DecisionOutcome?
    @State private var rating: Int
    @State private var reflection: String
    @State private var confirmDelete = false
    @State private var savedTick = 0

    init(entry: DecisionEntry) {
        self.entry = entry
        _outcome = State(initialValue: entry.outcome)
        _rating = State(initialValue: entry.rating ?? 0)
        _reflection = State(initialValue: entry.reflection)
    }

    private var hasChanges: Bool {
        outcome != entry.outcome || rating != (entry.rating ?? 0) || reflection != entry.reflection
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MomentSpacing.xl) {
                situationSection
                recommendationSection
                outcomeSection
                reflectionSection

                PrimaryButton(title: "Save changes", systemImage: "checkmark") { save() }
                    .disabled(!hasChanges)
            }
            .padding(.horizontal, MomentSpacing.l)
            .padding(.top, MomentSpacing.s)
            .padding(.bottom, MomentSpacing.xxl)
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(Text(entry.createdAt, format: .dateTime.day().month(.abbreviated).year()))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Delete decision", systemImage: "trash", role: .destructive) {
                        confirmDelete = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel("More")
            }
        }
        .confirmationDialog("Delete this decision?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                store.deleteDecision(id: entry.id)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
        .sensoryFeedback(.success, trigger: savedTick)
    }

    private var situationSection: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.m) {
            SectionHeader(title: "The situation")
            VStack(alignment: .leading, spacing: MomentSpacing.m) {
                Text(entry.input.trimmedSituation)
                    .font(.momentBody)
                    .foregroundStyle(MomentColor.primary)
                FlowLayout {
                    DetailPill(text: entry.input.relationship.name, symbol: entry.input.relationship.symbol)
                    DetailPill(text: entry.input.goal.name, symbol: entry.input.goal.symbol)
                    DetailPill(text: entry.input.emotion.name, symbol: entry.input.emotion.symbol)
                }
            }
            .momentCard()
        }
    }

    private var recommendationSection: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.m) {
            SectionHeader(title: "What MOMENT showed")
            VStack(alignment: .leading, spacing: MomentSpacing.m) {
                if let recommended = entry.analysis.recommendedScenario {
                    row(label: "Suggested", value: recommended.title)
                }
                if let selected = entry.selectedScenario {
                    row(label: "You chose", value: selected.title)
                }
                ConfidenceBadge(level: entry.analysis.confidence)
            }
            .momentCard()
        }
    }

    private func row(label: LocalizedStringKey, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.momentCaption)
                .foregroundStyle(MomentColor.secondary)
            Text(value)
                .font(.momentBody)
                .foregroundStyle(MomentColor.primary)
        }
    }

    private var outcomeSection: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.m) {
            SectionHeader(title: "How did it go?", subtitle: "Only you can say. This stays on your device.")
            FlowLayout {
                ForEach(DecisionOutcome.allCases) { item in
                    ChoiceChip(
                        title: item.name,
                        systemImage: item.symbol,
                        isSelected: outcome == item
                    ) {
                        outcome = (outcome == item) ? nil : item
                    }
                }
            }

            VStack(alignment: .leading, spacing: MomentSpacing.s) {
                Text("Was the suggestion helpful?")
                    .font(.momentCaption)
                    .foregroundStyle(MomentColor.secondary)
                HStack(spacing: MomentSpacing.s) {
                    ForEach(1...5, id: \.self) { star in
                        Button {
                            rating = (rating == star) ? 0 : star
                        } label: {
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(.title3)
                                .foregroundStyle(star <= rating ? MomentColor.accent : MomentColor.secondary)
                                .frame(minWidth: 44, minHeight: 44)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text("\(star) out of 5"))
                    }
                }
            }
        }
    }

    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.m) {
            SectionHeader(title: "What did you learn?")
            MomentTextEditor(placeholder: "A few words for your future self", text: $reflection, minHeight: 100)
        }
    }

    private func save() {
        var updated = entry
        updated.outcome = outcome
        updated.rating = rating == 0 ? nil : rating
        updated.reflection = reflection
        store.updateDecision(updated)
        savedTick += 1
    }
}

private struct DetailPill: View {
    let text: String
    let symbol: String

    var body: some View {
        Label(text, systemImage: symbol)
            .font(.system(.footnote, weight: .medium))
            .foregroundStyle(MomentColor.primary)
            .padding(.horizontal, MomentSpacing.m)
            .padding(.vertical, 6)
            .background(MomentColor.background, in: .capsule)
            .overlay { Capsule().strokeBorder(MomentColor.separator, lineWidth: 0.5) }
    }
}
