import Foundation
import SwiftUI

enum SettingsKey {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let appearance = "appearance"
    static let biometricLock = "biometricLockEnabled"
    static let communicationStyle = "pref.communicationStyle"
    static let communicationPace = "pref.communicationPace"
    static let uncertaintyTolerance = "pref.uncertaintyTolerance"
    static let conflictApproach = "pref.conflictApproach"
    static let learningEnabled = "pref.learningEnabled"
}

nonisolated enum AppearanceMode: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    var name: String {
        switch self {
        case .system: String(localized: "Match system")
        case .light: String(localized: "Always light")
        case .dark: String(localized: "Always dark")
        }
    }
}
