import Foundation
import SwiftUI
import MomentCore

/// Create (person == nil) or edit a person. Owns its own dismissal.
struct PersonEditorView: View {
    let person: PersonEntry?

    @Environment(\.dismiss) private var dismiss
    @Environment(MomentStore.self) private var store

    @State private var nickname: String
    @State private var relationship: RelationshipType
    @State private var hasMetDate: Bool
    @State private var metOn: Date
    @State private var notes: String

    init(person: PersonEntry?) {
        self.person = person
        _nickname = State(initialValue: person?.nickname ?? "")
        _relationship = State(initialValue: person?.relationship ?? .dating)
        _hasMetDate = State(initialValue: person?.metOn != nil)
        _metOn = State(initialValue: person?.metOn ?? .now)
        _notes = State(initialValue: person?.notes ?? "")
    }

    private var trimmedName: String { nickname.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var canSave: Bool { !trimmedName.isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name or nickname", text: $nickname)
                        .textInputAutocapitalization(.words)
                    Picker("Relationship", selection: $relationship) {
                        ForEach(RelationshipType.allCases) { type in
                            Text(type.name).tag(type)
                        }
                    }
                }
                .listRowBackground(MomentColor.surface)

                Section {
                    Toggle("I remember when we met", isOn: $hasMetDate.animation())
                    if hasMetDate {
                        DatePicker("Date", selection: $metOn, in: ...Date.now, displayedComponents: .date)
                    }
                }
                .listRowBackground(MomentColor.surface)

                Section("Private notes") {
                    TextField("What matters to remember", text: $notes, axis: .vertical)
                        .lineLimit(3...8)
                        .writingToolsBehavior(.disabled)
                }
                .listRowBackground(MomentColor.surface)
            }
            .momentListStyle()
            .navigationTitle(person == nil ? "New person" : "Edit person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
        }
        .interactiveDismissDisabled(canSave && person == nil)
    }

    private func save() {
        var entry = person ?? PersonEntry(nickname: trimmedName, relationship: relationship)
        entry.nickname = trimmedName
        entry.relationship = relationship
        entry.metOn = hasMetDate ? metOn : nil
        entry.notes = notes
        store.savePerson(entry)
        dismiss()
    }
}
