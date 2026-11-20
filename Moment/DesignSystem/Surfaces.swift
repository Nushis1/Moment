import Foundation
import SwiftUI

/// Calm page background: flat tone plus a very faint accent glow. Opaque on purpose,
/// so content (not glass) carries the page and glass stays on navigation and controls.
struct MomentBackground: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack {
            MomentColor.background
            RadialGradient(
                colors: [MomentColor.accent.opacity(scheme == .dark ? 0.14 : 0.09), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 460
            )
        }
        .ignoresSafeArea()
    }
}

struct MomentCardModifier: ViewModifier {
    let padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(MomentColor.surface, in: .rect(cornerRadius: MomentRadius.card, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: MomentRadius.card, style: .continuous)
                    .strokeBorder(MomentColor.separator, lineWidth: 0.5)
            }
    }
}

extension View {
    func momentBackground() -> some View {
        background { MomentBackground() }
    }

    /// Content card: opaque surface, hairline border. Not glass.
    func momentCard(padding: CGFloat = MomentSpacing.l) -> some View {
        modifier(MomentCardModifier(padding: padding))
    }

    /// For List/Form screens: hides the system grouped background and applies ours.
    func momentListStyle() -> some View {
        scrollContentBackground(.hidden).momentBackground()
    }
}

struct SectionHeader: View {
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey?

    var body: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.xs) {
            Text(title)
                .font(.momentHeadline)
                .foregroundStyle(MomentColor.primary)
                .accessibilityAddTraits(.isHeader)
            if let subtitle {
                Text(subtitle)
                    .font(.momentCaption)
                    .foregroundStyle(MomentColor.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Title + optional helper text used at the top of a step or screen section.
struct ScreenHeading: View {
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey?

    var body: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.s) {
            Text(title)
                .font(.momentTitle)
                .foregroundStyle(MomentColor.primary)
                .accessibilityAddTraits(.isHeader)
            if let subtitle {
                Text(subtitle)
                    .font(.momentBody)
                    .foregroundStyle(MomentColor.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A bulleted list of short statements inside a card (arguments, observations, unknowns).
struct BulletList: View {
    let items: [String]
    var symbol: String = "circle.fill"
    var tint: Color = MomentColor.accent

    var body: some View {
        VStack(alignment: .leading, spacing: MomentSpacing.s) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .firstTextBaseline, spacing: MomentSpacing.s) {
                    Image(systemName: symbol)
                        .font(.system(size: 6))
                        .foregroundStyle(tint)
                        .accessibilityHidden(true)
                    Text(item)
                        .font(.momentBody)
                        .foregroundStyle(MomentColor.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
