import Foundation
import SwiftUI

/// MOMENT design tokens. Colors live in the asset catalog so Light and Dark Mode are tuned
/// separately (not inverted). Never hard-code colors in screens: use these tokens.
enum MomentColor {
    static let background = Color("MomentBackground")
    static let surface = Color("MomentSurface")
    static let primary = Color("MomentPrimary")
    static let secondary = Color("MomentSecondary")
    static let separator = Color("MomentSeparator")
    /// Accent for text, icons and selection outlines (contrast-checked on the background).
    static let accent = Color("AccentColor")
    /// Accent for filled controls that carry white text.
    static let accentFill = Color("MomentAccentFill")
    static let positive = Color("MomentPositive")
    static let caution = Color("MomentCaution")
    static let onAccent = Color.white
}

nonisolated enum MomentSpacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

nonisolated enum MomentRadius {
    static let card: CGFloat = 22
    static let control: CGFloat = 16
}

/// All type uses Apple text styles, so Dynamic Type works everywhere.
extension Font {
    static let momentDisplay = Font.system(.largeTitle, weight: .semibold)
    static let momentTitle = Font.system(.title2, weight: .semibold)
    static let momentHeadline = Font.system(.headline, weight: .semibold)
    static let momentBody = Font.system(.body)
    static let momentCaption = Font.system(.footnote)
    static let momentMono = Font.system(.footnote, design: .monospaced)
}
