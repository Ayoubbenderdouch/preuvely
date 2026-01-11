import SwiftUI
import Combine

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var animateGradient = false
    @EnvironmentObject private var localizationManager: LocalizationManager

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "magnifyingglass.circle.fill",
            titleKey: "onboarding_page1_title",
            subtitleKey: "onboarding_page1_subtitle",
            color: .primaryGreen
        ),
        OnboardingPage(
            icon: "star.circle.fill",
            titleKey: "onboarding_page2_title",
            subtitleKey: "onboarding_page2_subtitle",
            color: .starYellow
        ),
        OnboardingPage(
            icon: "checkmark.seal.fill",
            titleKey: "onboarding_page3_title",
            subtitleKey: "onboarding_page3_subtitle",
            color: .primaryGreen
        )
    ]

    var body: some View {
        ZStack {
            // Background image - changes with page (crossfade effect)
            ForEach(0..<pages.count, id: \.self) { index in
                Image(imageForPage(index))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                    .opacity(currentPage == index ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5), value: currentPage)
            }

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button {
                        completeOnboarding()
                    } label: {
                        Text(L10n.Onboarding.skip.localized)
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.primaryGreen : Color.primaryGreen.opacity(0.3))
                            .frame(width: 10, height: 10)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, Spacing.lg)

                // Continue / Get Started button with animated border
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? L10n.Onboarding.continueButton.localized : L10n.Onboarding.getStarted.localized)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.primaryGreen)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(lineWidth: 3)
                                .foregroundStyle(
                                    .angularGradient(
                                        stops: [
                                            .init(color: .clear, location: 0.0),
                                            .init(color: .clear, location: 0.35),
                                            .init(color: .white, location: 0.40),
                                            .init(color: .white, location: 0.45),
                                            .init(color: .clear, location: 0.50),
                                            .init(color: .clear, location: 1.0)
                                        ],
                                        center: .center,
                                        startAngle: .degrees(animateGradient ? 360 : 0),
                                        endAngle: .degrees(animateGradient ? 720 : 360)
                                    )
                                )
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
                .onAppear {
                    withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                        animateGradient = true
                    }
                }
            }
        }
    }

    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    private func imageForPage(_ index: Int) -> String {
        switch index {
        case 0: return "onboringimg"
        case 1: return "onboringimgzwei"
        case 2: return "onboringimgdrei"
        default: return "onboringimg"
        }
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let icon: String
    let titleKey: String
    let subtitleKey: String
    let color: Color
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: Spacing.md) {
            Spacer()

            // Text content - clean and simple
            VStack(spacing: 10) {
                Text(page.titleKey.localized)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primaryGreen)
                    .multilineTextAlignment(.center)

                Text(page.subtitleKey.localized)
                    .font(.system(size: 15))
                    .foregroundColor(.primaryGreen.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 16)
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .environmentObject(LocalizationManager.shared)
}
