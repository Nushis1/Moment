import Foundation
import SwiftUI
import MomentCore

/// Runs the analysis, then shows the recommendation. Pushed from the New Moment flow.
struct AnalysisView: View {
    let input: MomentInput
    let onFinish: () -> Void

    @Environment(MomentStore.self) private var store
    @State private var phase: Phase = .loading

    private enum Phase {
        case loading
        case failed(String)
        case done(MomentAnalysis)
    }

    var body: some View {
        Group {
            switch phase {
            case .loading:
                MomentLoadingState(messages: [
                    "Organizing what you shared",
                    "Looking at the wording",
                    "Comparing your options",
                    "Preparing your recommendation",
                ])
            case .failed(let message):
                MomentErrorState(message: message) {
                    phase = .loading
                    Task { await run() }
                }
            case .done(let analysis):
                RecommendationView(input: input, analysis: analysis, onFinish: onFinish)
            }
        }
        .momentBackground()
        .navigationTitle("Recommendation")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isLoading)
        .task {
            guard case .loading = phase else { return }
            await run()
        }
    }

    private var isLoading: Bool {
        if case .loading = phase { return true }
        return false
    }

    private func run() async {
        do {
            let analysis = try await store.analyze(input)
            phase = .done(analysis)
        } catch is CancellationError {
            return
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }
}
