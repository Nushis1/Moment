import Foundation
import SwiftUI
import MomentCore

struct PersonDetailView: View {
    let id: UUID
    @Environment(MomentStore.self) private var store

    var body: some View {
        Group {
            if let person = store.person(id: id) {
                PersonDetailContent(person: person)
            } else {
                MomentEmptyState(
                    title: "Person not found",
                    systemImage: "person.crop.circle.badge.questionmark",
                    message: "This person may have been removed."
                )
            }
        }
        .momentBackground()
    }
}

private struct PersonDetailContent: View {
    let person: PersonEntry

    @Environment(MomentStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var editing: PersonEntry?
    @State private var confirmDelete = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MomentSpacing.xl) {
                header

                if !person.notes.isEmpty {
                    VStack(alignment: .leading, spacing: MomentSpacing.m) {
                        SectionHeader(title: "Your notes")
                        Text(person.notes)
                            .font(.momentBody)
                            .foregroundStyle(MomentColor.primary)
                            .momentCard()
                    }
                }

                relatedDecisions

                Button("Remove this person", role: .destructive) {
                    confirmDelete = true
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, MomentSpacing.l)
            .padding(.bottom, MomentSpacing.xxl)
        }
        .navigationTitle(person.nickname)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { editing = person }
            }
        }
        .sheet(item: $editing) { entry in
            PersonEditorView(person: entry)
        }
        .confirmationDialog("Remove this person?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Remove", role: .destructive) {
                store.deletePerson(id: person.id)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your saved decisions stay in History. They just won't be linked to this person.")
        }
    }

    private var header: some View {
        HStack(spacing: MomentSpacing.l) {
            Image(systemName: person.relationship.symbol)
                .font(.title)
                .foregroundStyle(MomentColor.accent)
                .frame(width: 64, height: 64)
                .background(MomentColor.accent.opacity(0.12), in: .circle)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: MomentSpacing.xs) {
                Text(person.relationship.name)
                    .font(.momentHeadline)
                    .foregroundStyle(MomentColor.primary)
                if let metOn = person.metOn {
                    Text("Met \(metOn.formatted(.dateTime.month(.wide).year()))")
                        .font(.momentCaption)
                        .foregroundStyle(MomentColor.secondary)
                }
            }
        }
        .padding(.top, MomentSpacing.l)
    }

    private var relatedDecisions: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.m) {
            SectionHeader(title: "Recent situations")
            let related = store.decisions(forPerson: person.id)
            if related.isEmpty {
                Text("Moments you link to this person will appear here.")
                    .font(.momentBody)
                    .foregroundStyle(MomentColor.secondary)
                    .momentCard()
            } else {
                ForEach(related) { entry in
                    NavigationLink(value: Route.decision(entry.id)) {
                        DecisionCard(entry: entry)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
