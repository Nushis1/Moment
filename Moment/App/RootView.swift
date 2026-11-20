import Foundation
import SwiftUI

struct RootView: View {
    @Environment(Router.self) private var router
    @Environment(AppLock.self) private var lock
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(SettingsKey.hasCompletedOnboarding) private var hasCompletedOnboarding = false

    private var showsLock: Bool {
        lock.isLocked || (lock.isEnabled && scenePhase != .active)
    }

    var body: some View {
        @Bindable var router = router

        ZStack {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView {
                    withAnimation(.smooth) { hasCompletedOnboarding = true }
                }
            }

            if showsLock {
                LockView()
                    .transition(.opacity)
            }
        }
        .animation(.smooth, value: showsLock)
        .sheet(item: $router.sheet) { destination in
            switch destination {
            case .newMoment: NewMomentFlow()
            case .settings: SettingsView()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            lock.handle(scenePhase: newPhase)
        }
    }
}

struct MainTabView: View {
    @Environment(Router.self) private var router

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            Tab(AppTab.home.title, systemImage: AppTab.home.symbol, value: AppTab.home) {
                NavigationStack(path: $router.homePath) {
                    HomeView()
                        .routeDestinations()
                }
            }

            Tab(AppTab.reply.title, systemImage: AppTab.reply.symbol, value: AppTab.reply) {
                NavigationStack(path: $router.replyPath) {
                    ReplyStudioView()
                        .routeDestinations()
                }
            }

            Tab(AppTab.history.title, systemImage: AppTab.history.symbol, value: AppTab.history) {
                NavigationStack(path: $router.historyPath) {
                    HistoryView()
                        .routeDestinations()
                }
            }

            Tab(AppTab.people.title, systemImage: AppTab.people.symbol, value: AppTab.people) {
                NavigationStack(path: $router.peoplePath) {
                    PeopleView()
                        .routeDestinations()
                }
            }

            Tab(AppTab.insights.title, systemImage: AppTab.insights.symbol, value: AppTab.insights) {
                NavigationStack(path: $router.insightsPath) {
                    InsightsView()
                        .routeDestinations()
                }
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}
