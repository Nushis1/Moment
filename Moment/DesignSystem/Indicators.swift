import Foundation
import SwiftUI
import MomentCore

/// Three dots + label. Describes how complete the input was, never a chance of success.
struct ConfidenceBadge: View {
    let level: ConfidenceLevel

    var body: some View {
        HStack(spacing: MomentSpacing.s) {
            HStack(spacing: 3) {
                ForEach(1...3, id: \.self) { index in
                    Circle()
                        .fill(index <= level.rank ? MomentColor.accent : MomentColor.separator)
                        .frame(width: 7, height: 7)
                }
            }
            .accessibilityHidden(true)
            Text(level.name)
                .font(.system(.footnote, weight: .medium))
                .foregroundStyle(MomentColor.primary)
        }
        .padding(.horizontal, MomentSpacing.m)
        .padding(.vertical, 6)
        .background(MomentColor.background, in: .capsule)
        .overlay { Capsule().strokeBorder(MomentColor.separator, lineWidth: 0.5) }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Confidence: \(level.name)"))
    }
}

/// Horizontal bar for a 0...100 comparison score.
struct ScoreBar: View {
    let value: Int
    var tint: Color = MomentColor.accent

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(MomentColor.separator)
                Capsule()
                    .fill(tint)
                    .frame(width: max(6, proxy.size.width * CGFloat(min(max(value, 0), 100)) / 100))
            }
        }
        .frame(height: 6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Comparison score"))
        .accessibilityValue(Text("\(value) out of 100"))
    }
}

/// Small capsule showing how a saved decision turned out.
struct OutcomeBadge: View {
    let outcome: DecisionOutcome?

    var body: some View {
        Label {
            Text(outcome?.name ?? String(localized: "Outcome not recorded"))
        } icon: {
            Image(systemName: outcome?.symbol ?? "circle.dashed")
        }
        .font(.system(.caption, weight: .medium))
        .foregroundStyle(outcome == nil ? MomentColor.secondary : MomentColor.primary)
        .padding(.horizontal, MomentSpacing.s)
        .padding(.vertical, 4)
        .background(MomentColor.background, in: .capsule)
        .overlay { Capsule().strokeBorder(MomentColor.separator, lineWidth: 0.5) }
    }
}

/// Small label chip: "Recommended", "Optional" and similar.
struct TagLabel: View {
    let text: LocalizedStringKey
    var tint: Color = MomentColor.accent

    var body: some View {
        Text(text)
            .font(.system(.caption, weight: .semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, MomentSpacing.s)
            .padding(.vertical, 3)
            .background(tint.opacity(0.12), in: .capsule)
    }
}

/// One-glance numeric tile for Insights.
struct StatTile: View {
    let value: String
    let label: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.xs) {
            Text(value)
                .font(.system(.largeTitle, weight: .semibold).monospacedDigit())
                .foregroundStyle(MomentColor.primary)
            Text(label)
                .font(.momentCaption)
                .foregroundStyle(MomentColor.secondary)
        }
        .momentCard()
        .accessibilityElement(children: .combine)
    }
}
