import Foundation
import SwiftUI
import MomentCore

struct HistoryView: View {
    @Environment(MomentStore.self) private var store
    @Environment(Router.self) private var router
    @State private var searchText = ""

    private var filtered: [DecisionEntry] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return store.sortedDecisions }
        return store.sortedDecisions.filter { $0.input.situation.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        Group {
            if store.decisions.isEmpty {
                MomentEmptyState(
                    title: "Nothing saved yet",
                    systemImage: "clock.arrow.circlepath",
                    message: "Decisions you save are kept here so you can look back at how things went.",
                    actionTitle: "New Moment",
                    action: { router.startNewMoment() }
                )
            } else {
                List {
                    ForEach(filtered) { entry in
                        NavigationLink(value: Route.decision(entry.id)) {
                            HistoryRow(entry: entry)
                        }
                        .listRowBackground(MomentColor.surface)
                    }
                    .onDelete(perform: delete)
                }
                .momentListStyle()
                .searchable(text: $searchText, prompt: "Search your moments")
            }
        }
        .momentBackground()
        .navigationTitle("History")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.startNewMoment()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New Moment")
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        let ids = offsets.map { filtered[$0].id }
        for id in ids { store.deleteDecision(id: id) }
    }
}

struct HistoryRow: View {
    let entry: DecisionEntry

    var body: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.s) {
            Text(entry.createdAt, format: .dateTime.day().month(.abbreviated).year())
                .font(.momentCaption)
                .foregroundStyle(MomentColor.secondary)
            Text(entry.input.trimmedSituation)
                .font(.momentBody)
                .foregroundStyle(MomentColor.primary)
                .lineLimit(2)
            OutcomeBadge(outcome: entry.outcome)
        }
        .padding(.vertical, MomentSpacing.xs)
    }
}
