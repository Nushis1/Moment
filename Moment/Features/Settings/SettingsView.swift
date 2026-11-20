import Foundation
import UIKit
import SwiftUI
import MomentCore

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(MomentStore.self) private var store
    @Environment(AppLock.self) private var lock

    @AppStorage(SettingsKey.appearance) private var appearanceRaw = AppearanceMode.system.rawValue
    @State private var lockOn = false
    @State private var exportFile: ExportFile?
    @State private var exportFailed = false
    @State private var confirmDeleteAll = false

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1"
    }

    var body: some View {
        NavigationStack {
            List {
                appearanceSection
                securitySection
                personalizationSection
                dataSection
                temporarySection
                aboutSection
            }
            .momentListStyle()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(item: $exportFile) { file in
                ShareSheet(url: file.url)
            }
            .alert("Couldn't create the export", isPresented: $exportFailed) {
                Button("OK", role: .cancel) {}
            }
            .confirmationDialog("Delete all data?", isPresented: $confirmDeleteAll, titleVisibility: .visible) {
                Button("Delete everything", role: .destructive) { store.deleteAllData() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("All saved decisions and people will be removed from this iPhone. This can't be undone.")
            }
            .onAppear { lockOn = lock.isEnabled }
            .onChange(of: lockOn) { _, newValue in
                guard newValue != lock.isEnabled else { return }
                Task {
                    await lock.setEnabled(newValue)
                    lockOn = lock.isEnabled
                }
            }
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Theme", selection: $appearanceRaw) {
                ForEach(AppearanceMode.allCases) { mode in
                    Text(mode.name).tag(mode.rawValue)
                }
            }
            Button("Language") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
        }
        .listRowBackground(MomentColor.surface)
    }

    private var securitySection: some View {
        Section {
            Toggle("Lock MOMENT", isOn: $lockOn)
                .disabled(!lock.isAvailable)
        } header: {
            Text("Security")
        } footer: {
            if lock.isAvailable {
                Text("Uses Face ID, Touch ID or your passcode whenever the app returns from the background.")
            } else {
                Text("Set a passcode on this iPhone to use the app lock.")
            }
        }
        .listRowBackground(MomentColor.surface)
    }

    private var personalizationSection: some View {
        Section {
            NavigationLink("Personalization") { PersonalizationView() }
            NavigationLink("Privacy") { PrivacyView() }
        }
        .listRowBackground(MomentColor.surface)
    }

    private var dataSection: some View {
        Section {
            Button("Export my data", systemImage: "square.and.arrow.up") { export() }
            Button("Delete all data", systemImage: "trash", role: .destructive) { confirmDeleteAll = true }
        } header: {
            Text("Your data")
        } footer: {
            Text("The export is a JSON file you control. MOMENT never uploads it anywhere.")
        }
        .listRowBackground(MomentColor.surface)
    }

    private var temporarySection: some View {
        Section {
            Button("Load demo data", systemImage: "wand.and.stars") { store.loadDemoData() }
        } header: {
            Text("Temporary (design phase)")
        } footer: {
            Text("Fills History, People and Insights with sample content so you can review every screen. This row will be removed.")
        }
        .listRowBackground(MomentColor.surface)
    }

    private var aboutSection: some View {
        Section("About") {
            LabeledContent("Version", value: version)
            Text("MOMENT works entirely on your device, with no account and no AI service.")
                .font(.momentCaption)
                .foregroundStyle(MomentColor.secondary)
        }
        .listRowBackground(MomentColor.surface)
    }

    private func export() {
        do {
            exportFile = ExportFile(url: try store.makeExportFile())
        } catch {
            exportFailed = true
        }
    }
}
