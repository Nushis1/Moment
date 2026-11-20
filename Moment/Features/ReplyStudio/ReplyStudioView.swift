import Foundation
import SwiftUI
import MomentCore

struct ReplyStudioView: View {
    @Environment(MomentStore.self) private var store
    @Environment(Router.self) private var router

    @State private var input = ReplyInput()
    @State private var isAnalyzing = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MomentSpacing.xl) {
                ScreenHeading(
                    title: "Think before you send",
                    subtitle: "Paste a message you received. MOMENT separates what is visible from what is only a guess."
                )

                VStack(alignment: .leading, spacing: MomentSpacing.s) {
                    SectionHeader(title: "Message you received")
                    MomentTextEditor(placeholder: "Paste the message here", text: $input.receivedMessage, minHeight: 130)
                }

                VStack(alignment: .leading, spacing: MomentSpacing.s) {
                    HStack {
                        SectionHeader(title: "Your draft")
                        TagLabel(text: "Optional", tint: MomentColor.secondary)
                    }
                    MomentTextEditor(placeholder: "Something you already wrote", text: $input.draft, minHeight: 100)
                }

                VStack(alignment: .leading, spacing: MomentSpacing.m) {
                    SectionHeader(title: "What do you want to do?")
                    ChoiceGroup(
                        items: ReplyIntent.allCases,
                        selection: $input.intent,
                        name: { $0.name },
                        symbol: { $0.symbol }
                    )
                }

                VStack(alignment: .leading, spacing: MomentSpacing.m) {
                    SectionHeader(title: "Tone")
                    ChoiceGroup(
                        items: ReplyTone.allCases,
                        selection: $input.tone,
                        name: { $0.name }
                    )
                }

                if let errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle")
                        .font(.momentCaption)
                        .foregroundStyle(MomentColor.caution)
                }

                analyzeButton
            }
            .padding(.horizontal, MomentSpacing.l)
            .padding(.bottom, MomentSpacing.xxl)
        }
        .scrollDismissesKeyboard(.interactively)
        .momentBackground()
        .navigationTitle("Reply Studio")
    }

    private var analyzeButton: some View {
        VStack(spacing: MomentSpacing.s) {
            if isAnalyzing {
                ProgressView()
                    .controlSize(.large)
                    .tint(MomentColor.accent)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .accessibilityLabel(Text("Analyzing on your device"))
            } else {
                PrimaryButton(title: "Analyze message", systemImage: "sparkles") {
                    Task { await analyze() }
                }
                .disabled(!input.hasValidMessage)
            }
            if !input.hasValidMessage {
                Text("Paste a message to get started.")
                    .font(.momentCaption)
                    .foregroundStyle(MomentColor.secondary)
            }
        }
    }

    private func analyze() async {
        isAnalyzing = true
        errorMessage = nil
        defer { isAnalyzing = false }
        do {
            let analysis = try await store.analyzeReply(input)
            router.replyPath.append(.replyResult(analysis))
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack { ReplyStudioView() }
        .environment(MomentStore())
        .environment(Router())
}
