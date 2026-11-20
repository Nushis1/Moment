import Foundation
import MomentCore

/// Single source of truth the screens read from.
///
/// Analysis runs on the local MOMENT CORE engine.
/// Data still lives in memory and is lost when the app quits. The next step replaces the
/// internals with SwiftData repositories; the public API below is the contract screens rely on.
@Observable
final class MomentStore {
    private(set) var decisions: [DecisionEntry]
    private(set) var people: [PersonEntry]

    init(
        decisions: [DecisionEntry] = [],
        people: [PersonEntry] = []
    ) {
        self.decisions = decisions
        self.people = people
    }

    // MARK: Analysis

    /// Preferences from Settings plus what the person's own history has taught the engine.
    private var engineContext: EngineContext {
        let preferences = EnginePreferences.current()
        let signals = preferences.learningEnabled ? PersonalizationEngine.rebuild(from: decisions) : []
        return EngineContext(preferences: preferences, signals: signals)
    }

    func analyze(_ input: MomentInput) async throws -> MomentAnalysis {
        MomentEngine.analyze(input, context: engineContext)
    }

    func analyzeReply(_ input: ReplyInput) async throws -> ReplyAnalysis {
        MomentEngine.analyzeReply(input, context: engineContext)
    }

    // MARK: Decisions

    var sortedDecisions: [DecisionEntry] {
        decisions.sorted { $0.createdAt > $1.createdAt }
    }

    var lastDecision: DecisionEntry? {
        sortedDecisions.first
    }

    var insights: InsightsSummary {
        InsightsSummary.make(from: decisions)
    }

    func decision(id: UUID) -> DecisionEntry? {
        decisions.first { $0.id == id }
    }

    func decisions(forPerson personID: UUID) -> [DecisionEntry] {
        sortedDecisions.filter { $0.personID == personID }
    }

    @discardableResult
    func saveDecision(input: MomentInput, analysis: MomentAnalysis, selectedScenarioID: UUID) -> DecisionEntry {
        let entry = DecisionEntry(
            input: input,
            analysis: analysis,
            selectedScenarioID: selectedScenarioID
        )
        decisions.append(entry)
        return entry
    }

    /// Saves what happened after the person acted, through the Feedback Engine's validation.
    func recordFeedback(decisionID: UUID, outcome: DecisionOutcome?, rating: Int?, reflection: String) {
        guard let entry = decision(id: decisionID) else { return }
        updateDecision(FeedbackEngine.record(outcome: outcome, rating: rating, reflection: reflection, on: entry))
    }

    func updateDecision(_ entry: DecisionEntry) {
        guard let index = decisions.firstIndex(where: { $0.id == entry.id }) else { return }
        decisions[index] = entry
    }

    func deleteDecision(id: UUID) {
        decisions.removeAll { $0.id == id }
    }

    // MARK: People

    var sortedPeople: [PersonEntry] {
        people.sorted { $0.nickname.localizedCaseInsensitiveCompare($1.nickname) == .orderedAscending }
    }

    func person(id: UUID) -> PersonEntry? {
        people.first { $0.id == id }
    }

    /// Inserts a new person or updates an existing one.
    func savePerson(_ person: PersonEntry) {
        var updated = person
        updated.updatedAt = .now
        if let index = people.firstIndex(where: { $0.id == person.id }) {
            people[index] = updated
        } else {
            people.append(updated)
        }
    }

    /// Removes the person and detaches them from saved decisions (the decisions are kept).
    func deletePerson(id: UUID) {
        people.removeAll { $0.id == id }
        for index in decisions.indices where decisions[index].input.personID == id {
            decisions[index].input.personID = nil
        }
    }

    // MARK: Data ownership

    func deleteAllData() {
        decisions = []
        people = []
    }

    /// Writes everything the app holds to a JSON file the person can share or keep.
    func makeExportFile() throws -> URL {
        nonisolated struct Payload: Encodable {
            let exportedAt: Date
            let decisions: [DecisionEntry]
            let people: [PersonEntry]
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(Payload(exportedAt: .now, decisions: sortedDecisions, people: sortedPeople))

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        let name = "MOMENT-export-\(formatter.string(from: .now)).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        try data.write(to: url, options: [.atomic, .completeFileProtection])
        return url
    }

    // MARK: Phase-1 helper (removed in phase 2)

    func loadDemoData() {
        let demoPeople = DemoData.people
        people = demoPeople
        decisions = DemoData.decisions(people: demoPeople)
    }
}
