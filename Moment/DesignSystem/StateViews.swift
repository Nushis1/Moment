import Foundation
import SwiftUI

/// Empty state with an optional call to action.
struct MomentEmptyState: View {
    let title: LocalizedStringKey
    let systemImage: String
    let message: LocalizedStringKey
    var actionTitle: LocalizedStringKey?
    var action: (() -> Void)?

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(message)
        } actions: {
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.glassProminent)
                    .tint(MomentColor.accentFill)
            }
        }
    }
}

/// Error state with a retry.
struct MomentErrorState: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Something went wrong", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Try again", action: retry)
                .buttonStyle(.glass)
        }
    }
}

/// Loading state that cycles through short, honest status lines.
struct MomentLoadingState: View {
    let messages: [LocalizedStringKey]
    @State private var index = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: MomentSpacing.l) {
            ProgressView()
                .controlSize(.large)
                .tint(MomentColor.accent)
            Text(messages[min(index, messages.count - 1)])
                .font(.momentBody)
                .foregroundStyle(MomentColor.secondary)
                .multilineTextAlignment(.center)
                .contentTransition(.opacity)
                .accessibilityLabel(Text("Analyzing on your device"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(MomentSpacing.xl)
        .task {
            while !Task.isCancelled && index < messages.count - 1 {
                try? await Task.sleep(for: .milliseconds(900))
                if Task.isCancelled { break }
                if reduceMotion {
                    index += 1
                } else {
                    withAnimation(.smooth) { index += 1 }
                }
            }
        }
    }
}
