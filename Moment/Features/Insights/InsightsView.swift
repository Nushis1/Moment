import Foundation
import SwiftUI
import Charts
import MomentCore

struct InsightsView: View {
    @Environment(MomentStore.self) private var store
    @Environment(Router.self) private var router
    @AppStorage(SettingsKey.communicationStyle) private var style: CommunicationStyle = .balanced

    private var summary: InsightsSummary { store.insights }

    var body: some View {
        Group {
            if summary.totalDecisions == 0 {
                MomentEmptyState(
                    title: "Nothing to reflect on yet",
                    systemImage: "chart.bar",
                    message: "Save a few decisions and record how they went. Insights are built only from your own history.",
                    actionTitle: "New Moment",
                    action: { router.startNewMoment() }
                )
            } else {
                content
            }
        }
        .momentBackground()
        .navigationTitle("Insights")
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MomentSpacing.xl) {
                Text("Observations, not conclusions. Nothing here rates other people.")
                    .font(.momentCaption)
                    .foregroundStyle(MomentColor.secondary)

                HStack(spacing: MomentSpacing.m) {
                    StatTile(value: "\(summary.totalDecisions)", label: "Saved decisions")
                    StatTile(value: followedText, label: "Chose the suggestion")
                }

                outcomesSection
                patternsSection

                VStack(alignment: .leading, spacing: MomentSpacing.m) {
                    SectionHeader(title: "Your declared style")
                    Text(style.name)
                        .font(.momentBody)
                        .foregroundStyle(MomentColor.primary)
                        .momentCard()
                }
            }
            .padding(.horizontal, MomentSpacing.l)
            .padding(.bottom, MomentSpacing.xxl)
        }
    }

    private var followedText: String {
        guard summary.decisionsWithChoiceCount > 0 else { return "–" }
        return "\(summary.followedRecommendationCount)/\(summary.decisionsWithChoiceCount)"
    }

    private var outcomesSection: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.m) {
            SectionHeader(title: "How things turned out")
            Group {
                if summary.outcomeCounts.isEmpty {
                    Text("Record how a decision went to see this chart.")
                        .font(.momentBody)
                        .foregroundStyle(MomentColor.secondary)
                } else {
                    Chart(summary.outcomeCounts) { item in
                        BarMark(
                            x: .value("Decisions", item.count),
                            y: .value("Outcome", item.outcome.name)
                        )
                        .foregroundStyle(MomentColor.accent)
                        .cornerRadius(6)
                        .annotation(position: .trailing) {
                            Text(item.count, format: .number)
                                .font(.momentCaption)
                                .foregroundStyle(MomentColor.secondary)
                        }
                    }
                    .chartXAxis(.hidden)
                    .frame(height: CGFloat(summary.outcomeCounts.count) * 44 + 8)
                }
            }
            .momentCard()
        }
    }

    private var patternsSection: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.m) {
            SectionHeader(title: "Patterns")
            VStack(alignment: .leading, spacing: MomentSpacing.m) {
                if summary.hasEnoughData {
                    if let goal = summary.topGoal {
                        patternRow(label: "Most common goal", value: goal.name)
                    }
                    if let emotion = summary.topEmotion {
                        patternRow(label: "Most common feeling", value: emotion.name)
                    }
                    if let relationship = summary.topRelationship {
                        patternRow(label: "Most common relationship", value: relationship.name)
                    }
                    if summary.topGoal == nil && summary.topEmotion == nil && summary.topRelationship == nil {
                        Text("No clear pattern stands out yet.")
                            .font(.momentBody)
                            .foregroundStyle(MomentColor.secondary)
                    }
                } else {
                    Text("Patterns appear once you have saved \(InsightsSummary.minimumForPatterns) decisions. You have \(summary.totalDecisions) so far.")
                        .font(.momentBody)
                        .foregroundStyle(MomentColor.secondary)
                }
            }
            .momentCard()
        }
    }

    private func patternRow(label: LocalizedStringKey, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.momentCaption)
                .foregroundStyle(MomentColor.secondary)
            Text(value)
                .font(.momentBody)
                .foregroundStyle(MomentColor.primary)
        }
    }
}
