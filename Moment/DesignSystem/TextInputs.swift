import Foundation
import SwiftUI

/// Multi-line private text input with a placeholder.
/// Writing Tools are disabled: nothing typed here should be handed to any rewriting service.
struct MomentTextEditor: View {
    let placeholder: LocalizedStringKey
    @Binding var text: String
    var minHeight: CGFloat = 140

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .font(.momentBody)
                .scrollContentBackground(.hidden)
                .writingToolsBehavior(.disabled)
                .padding(MomentSpacing.s)
                .frame(minHeight: minHeight)
                .accessibilityLabel(placeholder)

            if text.isEmpty {
                Text(placeholder)
                    .font(.momentBody)
                    .foregroundStyle(MomentColor.secondary)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 16)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
        .background(MomentColor.surface, in: .rect(cornerRadius: MomentRadius.control, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: MomentRadius.control, style: .continuous)
                .strokeBorder(MomentColor.separator, lineWidth: 0.5)
        }
    }
}
