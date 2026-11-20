import Foundation
import SwiftUI
import MomentCore

struct PeopleView: View {
    @Environment(MomentStore.self) private var store
    @State private var showNewPerson = false
    @State private var searchText = ""

    private var filtered: [PersonEntry] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return store.sortedPeople }
        return store.sortedPeople.filter { $0.nickname.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        Group {
            if store.people.isEmpty {
                MomentEmptyState(
                    title: "No one added yet",
                    systemImage: "person.2",
                    message: "Adding people is optional. Add someone only if you want to keep private context for them.",
                    actionTitle: "Add a person",
                    action: { showNewPerson = true }
                )
            } else {
                List {
                    ForEach(filtered) { person in
                        NavigationLink(value: Route.person(person.id)) {
                            PersonRow(person: person)
                        }
                        .listRowBackground(MomentColor.surface)
                    }
                    .onDelete(perform: delete)
                }
                .momentListStyle()
                .searchable(text: $searchText, prompt: "Search people")
            }
        }
        .momentBackground()
        .navigationTitle("People")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showNewPerson = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add a person")
            }
        }
        .sheet(isPresented: $showNewPerson) {
            PersonEditorView(person: nil)
        }
    }

    private func delete(at offsets: IndexSet) {
        let ids = offsets.map { filtered[$0].id }
        for id in ids { store.deletePerson(id: id) }
    }
}

struct PersonRow: View {
    let person: PersonEntry

    var body: some View {
        HStack(spacing: MomentSpacing.m) {
            Image(systemName: person.relationship.symbol)
                .foregroundStyle(MomentColor.accent)
                .frame(width: 32, height: 32)
                .background(MomentColor.accent.opacity(0.12), in: .circle)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(person.nickname)
                    .font(.momentBody)
                    .foregroundStyle(MomentColor.primary)
                Text(person.relationship.name)
                    .font(.momentCaption)
                    .foregroundStyle(MomentColor.secondary)
            }
        }
        .padding(.vertical, MomentSpacing.xs)
    }
}
