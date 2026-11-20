import Foundation
import SwiftUI
import UIKit
import MomentCore

struct ReplyResultView: View {
    let analysis: ReplyAnalysis

    @State private var copiedID: UUID?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MomentSpacing.xl) {
                Label("These are possibilities, not facts about what the other person means.", systemImage: "info.circle")
                    .font(.momentCaption)
                    .foregroundStyle(MomentColor.secondary)

                section(number: 1, title: "What can be noticed", items: analysis.observations)
                section(number: 2, title: "Possible readings", items: analysis.interpretations)
                section(number: 3, title: "What can't be known from here", items: analysis.unknowns, tint: MomentColor.caution)
                suggestionsSection

                VStack(alignment: .leading, spacing: MomentSpacing.m) {
                    SectionHeader(title: "Why these fit")
                    Text(analysis.fitExplanation)
                        .font(.momentBody)
                        .foregroundStyle(MomentColor.primary)
                        .momentCard()
                }
            }
            .padding(.horizontal, MomentSpacing.l)
            .padding(.bottom, MomentSpacing.xxl)
        }
        .momentBackground()
        .navigationTitle("Reply ideas")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: copiedID)
    }

    private func section(number: Int, title: LocalizedStringKey, items: [String], tint: Color = MomentColor.accent) -> some View {
        VStack(alignment: .leading, spacing: MomentSpacing.m) {
            SectionHeader(title: title)
            BulletList(items: items, tint: tint)
                .momentCard()
        }
    }

    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.m) {
            SectionHeader(title: "Ways to reply", subtitle: "Edit freely. These are starting points, not scripts.")
            ForEach(analysis.suggestions) { suggestion in
                VStack(alignment: .leading, spacing: MomentSpacing.m) {
                    Text(suggestion.text)
                        .font(.momentBody)
                        .foregroundStyle(MomentColor.primary)
                        .textSelection(.enabled)
                    Text(suggestion.note)
                        .font(.momentCaption)
                        .foregroundStyle(MomentColor.secondary)
                    Button {
                        UIPasteboard.general.string = suggestion.text
                        copiedID = suggestion.id
                    } label: {
                        if copiedID == suggestion.id {
                            Label("Copied", systemImage: "checkmark")
                        } else {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                    }
                    .buttonStyle(.glass)
                }
                .momentCard()
            }
        }
    }
}
