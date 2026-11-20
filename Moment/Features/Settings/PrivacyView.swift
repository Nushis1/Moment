import Foundation
import SwiftUI

struct PrivacyView: View {
    private struct Point: Identifiable {
        let id: Int
        let symbol: String
        let title: LocalizedStringKey
        let message: LocalizedStringKey
    }

    private let points: [Point] = [
        Point(id: 0, symbol: "iphone", title: "On your device", message: "Everything you write is analyzed on this iPhone."),
        Point(id: 1, symbol: "person.crop.circle.badge.xmark", title: "No account", message: "There is nothing to sign up for and no profile to create."),
        Point(id: 2, symbol: "cloud.slash", title: "No servers, no AI services", message: "MOMENT doesn't send your messages to any server or generative AI service."),
        Point(id: 3, symbol: "faceid", title: "Optional lock", message: "Protect the app with Face ID, Touch ID or your passcode."),
        Point(id: 4, symbol: "square.and.arrow.up", title: "Yours to keep or erase", message: "Export everything as a file, or delete it all, from Settings."),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MomentSpacing.l) {
                ScreenHeading(
                    title: "Your moments stay yours",
                    subtitle: "Relationship questions are personal. MOMENT is built so nobody else has to see them."
                )
                ForEach(points) { point in
                    HStack(alignment: .top, spacing: MomentSpacing.m) {
                        Image(systemName: point.symbol)
                            .font(.title3)
                            .foregroundStyle(MomentColor.accent)
                            .frame(width: 32)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(point.title)
                                .font(.momentHeadline)
                                .foregroundStyle(MomentColor.primary)
                            Text(point.message)
                                .font(.momentBody)
                                .foregroundStyle(MomentColor.secondary)
                        }
                    }
                    .momentCard()
                }
            }
            .padding(.horizontal, MomentSpacing.l)
            .padding(.bottom, MomentSpacing.xxl)
        }
        .momentBackground()
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}
