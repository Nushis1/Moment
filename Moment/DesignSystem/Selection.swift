import Foundation
import SwiftUI

/// Wrapping layout for chips: fills a row, then flows to the next.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var usedWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0 && x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            usedWidth = max(usedWidth, x - spacing)
            rowHeight = max(rowHeight, size.height)
        }
        let width = maxWidth.isFinite ? maxWidth : usedWidth
        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX && x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

/// Single-choice pill. Title is already localized text.
struct ChoiceChip: View {
    let title: String
    var systemImage: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: MomentSpacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .imageScale(.small)
                        .accessibilityHidden(true)
                }
                Text(title)
                    .font(.system(.subheadline, weight: .medium))
            }
            .padding(.horizontal, MomentSpacing.m)
            .padding(.vertical, MomentSpacing.s)
            .foregroundStyle(isSelected ? MomentColor.onAccent : MomentColor.primary)
            .background(isSelected ? MomentColor.accentFill : MomentColor.surface, in: .capsule)
            .overlay {
                Capsule().strokeBorder(isSelected ? Color.clear : MomentColor.separator, lineWidth: 1)
            }
            .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

/// A wrapping group of chips bound to one selection.
struct ChoiceGroup<Item: Hashable & Identifiable>: View {
    let items: [Item]
    @Binding var selection: Item
    let name: (Item) -> String
    var symbol: ((Item) -> String)?

    var body: some View {
        FlowLayout {
            ForEach(items) { item in
                ChoiceChip(
                    title: name(item),
                    systemImage: symbol?(item),
                    isSelected: selection == item
                ) {
                    selection = item
                }
            }
        }
    }
}

/// Full-width single-choice row with an optional supporting line.
struct OptionRow: View {
    let title: String
    var subtitle: String?
    var systemImage: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: MomentSpacing.m) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.title3)
                        .foregroundStyle(isSelected ? MomentColor.accent : MomentColor.secondary)
                        .frame(width: 28)
                        .accessibilityHidden(true)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.momentBody)
                        .foregroundStyle(MomentColor.primary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.momentCaption)
                            .foregroundStyle(MomentColor.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(isSelected ? MomentColor.accent : MomentColor.secondary)
                    .accessibilityHidden(true)
            }
            .padding(MomentSpacing.l)
            .background(MomentColor.surface, in: .rect(cornerRadius: MomentRadius.control, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: MomentRadius.control, style: .continuous)
                    .strokeBorder(isSelected ? MomentColor.accent : MomentColor.separator, lineWidth: isSelected ? 1.5 : 0.5)
            }
            .contentShape(.rect(cornerRadius: MomentRadius.control, style: .continuous))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
