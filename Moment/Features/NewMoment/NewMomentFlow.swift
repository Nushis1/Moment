import Foundation
import SwiftUI
import MomentCore

nonisolated enum MomentStep: Int, CaseIterable, Identifiable {
    case situation, relationship, goal, emotion, context
    var id: Int { rawValue }
}

nonisolated enum FlowRoute: Hashable {
    case analysis(MomentInput)
}

/// The guided "New Moment" flow, presented as a sheet with its own navigation stack:
/// situation, relationship, goal, emotion, context, then analysis and recommendation.
struct NewMomentFlow: View {
    @Environment(Router.self) private var router
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var input = MomentInput()
    @State private var step: MomentStep = .situation
    @State private var path: [FlowRoute] = []
    @State private var confirmDiscard = false

    private var isLastStep: Bool { step == MomentStep.allCases.last }
    private var canContinue: Bool { step != .situation || input.hasValidSituation }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: MomentSpacing.xl) {
                    StepProgress(current: step.rawValue, total: MomentStep.allCases.count)
                    stepContent
                        .id(step)
                        .transition(.opacity)
                }
                .padding(.horizontal, MomentSpacing.l)
                .padding(.bottom, MomentSpacing.xl)
            }
            .scrollDismissesKeyboard(.interactively)
            .momentBackground()
            .safeAreaInset(edge: .bottom) { controls }
            .navigationTitle("New Moment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { cancel() }
                }
            }
            .navigationDestination(for: FlowRoute.self) { route in
                switch route {
                case .analysis(let analysisInput):
                    AnalysisView(input: analysisInput) {
                        router.closeSheet()
                    }
                }
            }
        }
        .interactiveDismissDisabled(input.hasDraftContent)
        .confirmationDialog("Discard this moment?", isPresented: $confirmDiscard, titleVisibility: .visible) {
            Button("Discard", role: .destructive) { router.closeSheet() }
            Button("Keep editing", role: .cancel) {}
        } message: {
            Text("What you wrote won't be saved.")
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .situation: SituationStep(input: $input)
        case .relationship: RelationshipStep(input: $input)
        case .goal: GoalStep(input: $input)
        case .emotion: EmotionStep(input: $input)
        case .context: ContextStep(input: $input)
        }
    }

    private var controls: some View {
        HStack(spacing: MomentSpacing.m) {
            if step != .situation {
                SecondaryButton(title: "Back") { move(by: -1) }
                    .frame(maxWidth: 140)
            }
            PrimaryButton(title: isLastStep ? "Analyze" : "Continue", systemImage: isLastStep ? "sparkles" : nil) {
                if isLastStep {
                    path.append(.analysis(input))
                } else {
                    move(by: 1)
                }
            }
            .disabled(!canContinue)
        }
        .padding(.horizontal, MomentSpacing.l)
        .padding(.vertical, MomentSpacing.s)
    }

    private func move(by delta: Int) {
        guard let next = MomentStep(rawValue: step.rawValue + delta) else { return }
        if reduceMotion {
            step = next
        } else {
            withAnimation(.smooth) { step = next }
        }
    }

    private func cancel() {
        if input.hasDraftContent {
            confirmDiscard = true
        } else {
            router.closeSheet()
        }
    }
}

/// Thin progress indicator with a spoken position.
struct StepProgress: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: MomentSpacing.xs) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index <= current ? MomentColor.accent : MomentColor.separator)
                    .frame(height: 4)
            }
        }
        .padding(.top, MomentSpacing.s)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Step \(current + 1) of \(total)"))
    }
}

#Preview {
    NewMomentFlow()
        .environment(MomentStore())
        .environment(Router())
}
