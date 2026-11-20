import Foundation
import SwiftUI
import LocalAuthentication

/// Optional app lock backed by Face ID / Touch ID with device passcode fallback.
@Observable
final class AppLock {
    private(set) var isEnabled: Bool
    private(set) var isLocked: Bool

    init() {
        let enabled = UserDefaults.standard.bool(forKey: SettingsKey.biometricLock)
        isEnabled = enabled
        isLocked = enabled   // a cold start with the lock on always starts locked
    }

    /// False when the device has no passcode or biometrics set up.
    var isAvailable: Bool {
        var error: NSError?
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }

    /// Turning the lock on requires a successful authentication first.
    func setEnabled(_ newValue: Bool) async {
        if newValue {
            let confirmed = await authenticate(reason: String(localized: "Confirm to turn on the app lock."))
            guard confirmed else { return }
        }
        isEnabled = newValue
        UserDefaults.standard.set(newValue, forKey: SettingsKey.biometricLock)
        if !newValue { isLocked = false }
    }

    func unlock() async {
        guard isLocked else { return }
        let confirmed = await authenticate(reason: String(localized: "Unlock MOMENT."))
        if confirmed { isLocked = false }
    }

    func handle(scenePhase: ScenePhase) {
        if scenePhase == .background && isEnabled {
            isLocked = true
        }
    }

    private func authenticate(reason: String) async -> Bool {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else { return false }
        do {
            return try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
        } catch {
            return false
        }
    }
}

/// Full-screen cover shown while locked, and as a privacy shield in the app switcher.
struct LockView: View {
    @Environment(AppLock.self) private var lock

    var body: some View {
        ZStack {
            MomentBackground()
            VStack(spacing: MomentSpacing.xl) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(MomentColor.accent)
                    .accessibilityHidden(true)
                Text("MOMENT is locked")
                    .font(.momentTitle)
                    .foregroundStyle(MomentColor.primary)
                if lock.isLocked {
                    Button("Unlock") {
                        Task { await lock.unlock() }
                    }
                    .buttonStyle(.glassProminent)
                    .tint(MomentColor.accentFill)
                    .controlSize(.large)
                }
            }
        }
        .task { await lock.unlock() }
    }
}
