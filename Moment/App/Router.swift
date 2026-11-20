import Foundation
import SwiftUI
import MomentCore

nonisolated enum AppTab: String, Hashable, CaseIterable, Identifiable {
    case home, reply, history, people, insights
    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .home: "Home"
        case .reply: "Reply Studio"
        case .history: "History"
        case .people: "People"
        case .insights: "Insights"
        }
    }

    var symbol: String {
        switch self {
        case .home: "house"
        case .reply: "text.bubble"
        case .history: "clock.arrow.circlepath"
        case .people: "person.2"
        case .insights: "chart.bar"
        }
    }
}

/// Destinations pushed on a tab's NavigationStack. Only lightweight, hashable data.
nonisolated enum Route: Hashable {
    case decision(UUID)
    case person(UUID)
    case replyResult(ReplyAnalysis)
}

nonisolated enum SheetDestination: String, Identifiable {
    case newMoment, settings
    var id: String { rawValue }
}

/// Owns tab selection, one navigation path per tab, and app-level sheets.
@Observable
final class Router {
    var selectedTab: AppTab = .home
    var homePath: [Route] = []
    var replyPath: [Route] = []
    var historyPath: [Route] = []
    var peoplePath: [Route] = []
    var insightsPath: [Route] = []
    var sheet: SheetDestination?

    func startNewMoment() {
        sheet = .newMoment
    }

    func openSettings() {
        sheet = .settings
    }

    func closeSheet() {
        sheet = nil
    }

    func show(_ route: Route, in tab: AppTab) {
        selectedTab = tab
        switch tab {
        case .home: homePath.append(route)
        case .reply: replyPath.append(route)
        case .history: historyPath.append(route)
        case .people: peoplePath.append(route)
        case .insights: insightsPath.append(route)
        }
    }
}

/// One shared mapping from route to screen, applied to every tab's stack.
struct RouteDestinations: ViewModifier {
    func body(content: Content) -> some View {
        content.navigationDestination(for: Route.self) { route in
            switch route {
            case .decision(let id): DecisionDetailView(id: id)
            case .person(let id): PersonDetailView(id: id)
            case .replyResult(let analysis): ReplyResultView(analysis: analysis)
            }
        }
    }
}

extension View {
    func routeDestinations() -> some View {
        modifier(RouteDestinations())
    }
}
