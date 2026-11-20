import Foundation
import SwiftUI
import MomentCore

private struct OnboardingPage: Identifiable {
    let id: Int
    let symbol: String
    let title: LocalizedStringKey
    let message: LocalizedStringKey
}

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var page = 0
    @AppStorage(SettingsKey.communicationStyle) private var style: CommunicationStyle = .balanced

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            symbol: "arrow.triangle.branch",
            title: "Understand first, then act",
            message: "MOMENT helps you slow down, see your options and choose your next step yourself."
        ),
        OnboardingPage(
            id: 1,
            symbol: "text.bubble",
            title: "Clarity, not mind reading",
            message: "It organizes what you share and shows possible readings. It never claims to know what someone feels or how a relationship will go."
        ),
        OnboardingPage(
            id: 2,
            symbol: "lock.shield",
            title: "Private by design",
            message: "Everything is analyzed on your iPhone. No account, no servers, no AI services. It works offline."
        ),
        OnboardingPage(
            id: 3,
            symbol: "slider.horizontal.3",
            title: "Make it yours",
            message: "How do you usually like to communicate? You can change this any time in Settings."
        ),
    ]

    private var isLastPage: Bool { page == pages.count - 1 }

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                ForEach(pages) { item in
                    pageView(item)
                        .tag(item.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            footer
        }
        .momentBackground()
    }

    private func pageView(_ item: OnboardingPage) -> some View {
        ScrollView {
            VStack(spacing: MomentSpacing.xl) {
                Spacer(minLength: MomentSpacing.xxl)

                Image(systemName: item.symbol)
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(MomentColor.accent)
                    .frame(width: 120, height: 120)
                    .background(MomentColor.surface, in: .circle)
                    .overlay { Circle().strokeBorder(MomentColor.separator, lineWidth: 0.5) }
                    .accessibilityHidden(true)

                VStack(spacing: MomentSpacing.m) {
                    Text(item.title)
                        .font(.momentDisplay)
                        .foregroundStyle(MomentColor.primary)
                        .multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isHeader)
                    Text(item.message)
                        .font(.momentBody)
                        .foregroundStyle(MomentColor.secondary)
                        .multilineTextAlignment(.center)
                }

                if item.id == 3 {
                    ChoiceGroup(
                        items: CommunicationStyle.allCases,
                        selection: $style,
                        name: { $0.name }
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(.horizontal, MomentSpacing.xl)
            .padding(.bottom, MomentSpacing.xl)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private var footer: some View {
        VStack(spacing: MomentSpacing.l) {
            HStack(spacing: MomentSpacing.s) {
                ForEach(pages) { item in
                    Capsule()
                        .fill(item.id == page ? MomentColor.accent : MomentColor.separator)
                        .frame(width: item.id == page ? 22 : 7, height: 7)
                }
            }
            .animation(.smooth, value: page)
            .accessibilityHidden(true)

            PrimaryButton(title: isLastPage ? "Get started" : "Continue") {
                if isLastPage {
                    onFinish()
                } else {
                    withAnimation(.smooth) { page += 1 }
                }
            }

            Button("Skip") { onFinish() }
                .font(.momentBody)
                .foregroundStyle(MomentColor.secondary)
                .opacity(isLastPage ? 0 : 1)
                .disabled(isLastPage)
        }
        .padding(.horizontal, MomentSpacing.xl)
        .padding(.bottom, MomentSpacing.l)
        .sensoryFeedback(.selection, trigger: page)
    }
}

#Preview {
    OnboardingView {}
}
