import Foundation
import SwiftUI
import MomentCore

struct PersonalizationView: View {
    @AppStorage(SettingsKey.communicationStyle) private var style: CommunicationStyle = .balanced
    @AppStorage(SettingsKey.communicationPace) private var pace: CommunicationPace = .balanced
    @AppStorage(SettingsKey.uncertaintyTolerance) private var uncertainty: UncertaintyTolerance = .medium
    @AppStorage(SettingsKey.conflictApproach) private var conflict: ConflictApproach = .calmTalk
    @AppStorage(SettingsKey.learningEnabled) private var learningEnabled = true

    var body: some View {
        List {
            Section {
                Picker("Communication style", selection: $style) {
                    ForEach(CommunicationStyle.allCases) { Text($0.name).tag($0) }
                }
                Picker("Pace", selection: $pace) {
                    ForEach(CommunicationPace.allCases) { Text($0.name).tag($0) }
                }
                Picker("Uncertainty", selection: $uncertainty) {
                    ForEach(UncertaintyTolerance.allCases) { Text($0.name).tag($0) }
                }
                Picker("Conflict", selection: $conflict) {
                    ForEach(ConflictApproach.allCases) { Text($0.name).tag($0) }
                }
            } header: {
                Text("How you prefer to communicate")
            } footer: {
                Text("These shape the options and wording you see. You can change them any time.")
            }
            .listRowBackground(MomentColor.surface)

            Section {
                Toggle("Learn from my history", isOn: $learningEnabled)
            } footer: {
                Text("When on, MOMENT can adjust suggestions using how your past decisions turned out. Learning stays on this device.")
            }
            .listRowBackground(MomentColor.surface)
        }
        .momentListStyle()
        .navigationTitle("Personalization")
        .navigationBarTitleDisplayMode(.inline)
    }
}
