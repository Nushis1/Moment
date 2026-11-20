import Foundation
import SwiftUI

/// High-emphasis action. Uses native Liquid Glass (prominent) tinted with the accent fill.
struct PrimaryButton: View {
    let title: LocalizedStringKey
    var systemImage: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if let systemImage {
                    Label(title, systemImage: systemImage)
                } else {
                    Text(title)
                }
            }
            .font(.momentHeadline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, MomentSpacing.xs)
        }
        .buttonStyle(.glassProminent)
        .tint(MomentColor.accentFill)
        .controlSize(.large)
    }
}

/// Secondary action on native Liquid Glass.
struct SecondaryButton: View {
    let title: LocalizedStringKey
    var systemImage: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if let systemImage {
                    Label(title, systemImage: systemImage)
                } else {
                    Text(title)
                }
            }
            .font(.momentHeadline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, MomentSpacing.xs)
        }
        .buttonStyle(.glass)
        .controlSize(.large)
    }
}
