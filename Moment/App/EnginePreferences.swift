import Foundation
import MomentCore

/// Reads the preferences the person set in Settings and hands them to MOMENT CORE.
enum EnginePreferences {
    static func current(defaults: UserDefaults = .standard) -> UserPreferences {
        UserPreferences(
            style: CommunicationStyle(rawValue: defaults.string(forKey: SettingsKey.communicationStyle) ?? "") ?? .balanced,
            pace: CommunicationPace(rawValue: defaults.string(forKey: SettingsKey.communicationPace) ?? "") ?? .balanced,
            uncertainty: UncertaintyTolerance(rawValue: defaults.string(forKey: SettingsKey.uncertaintyTolerance) ?? "") ?? .medium,
            conflict: ConflictApproach(rawValue: defaults.string(forKey: SettingsKey.conflictApproach) ?? "") ?? .calmTalk,
            learningEnabled: (defaults.object(forKey: SettingsKey.learningEnabled) as? Bool) ?? true
        )
    }
}
