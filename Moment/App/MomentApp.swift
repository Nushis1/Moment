import Foundation
import SwiftUI

@main
struct MomentApp: App {
    @State private var store = MomentStore()
    @State private var router = Router()
    @State private var lock = AppLock()
    @AppStorage(SettingsKey.appearance) private var appearanceRaw = AppearanceMode.system.rawValue

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .environment(router)
                .environment(lock)
                .preferredColorScheme(AppearanceMode(rawValue: appearanceRaw)?.colorScheme)
        }
    }
}
