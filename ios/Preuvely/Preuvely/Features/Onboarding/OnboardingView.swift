import SwiftUI
import Combine

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var animateGradient = false
    @EnvironmentObject private var localizationManager: LocalizationManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// Check if we're on iPad
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }

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
        GeometryReader { geometry in
            ZStack {
                // Background image - changes with page (crossfade effect)
                ForEach(0..<pages.count, id: \.self) { index in
                    Image(imageForPage(index))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .opacity(currentPage == index ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5), value: currentPage)
                }

                // Content overlay
                VStack(spacing: 0) {
                    // Skip button
                    HStack {
                        Spacer()
                        Button {
                            completeOnboarding()
                        } label: {
                            Text(L10n.Onboarding.skip.localized)
                                .font(isIPad ? .body : .subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal, isIPad ? 20 : 12)
                                .padding(.vertical, isIPad ? 10 : 6)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(isIPad ? 12 : 8)
                        }
                    }
                    .padding(.horizontal, isIPad ? 40 : Spacing.lg)
                    .padding(.top, isIPad ? 30 : Spacing.md)

                    Spacer()

                    // Bottom content container - constrained width on iPad
                    VStack(spacing: isIPad ? 24 : 16) {
                        // Page content
                        TabView(selection: $currentPage) {
                            ForEach(0..<pages.count, id: \.self) { index in
                                OnboardingPageView(page: pages[index], isIPad: isIPad)
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: isIPad ? 200 : 150)
                        .animation(.easeInOut, value: currentPage)

                        // Page indicator
                        HStack(spacing: isIPad ? 12 : 8) {
                            ForEach(0..<pages.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentPage ? Color.primaryGreen : Color.primaryGreen.opacity(0.3))
                                    .frame(width: isIPad ? 14 : 10, height: isIPad ? 14 : 10)
                                    .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3), value: currentPage)
                            }
                        }

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
                                .font(.system(size: isIPad ? 22 : 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: isIPad ? 400 : .infinity)
                                .padding(.vertical, isIPad ? 20 : 16)
                                .background(
                                    RoundedRectangle(cornerRadius: isIPad ? 18 : 14)
                                        .fill(Color.primaryGreen)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: isIPad ? 18 : 14)
                                        .stroke(lineWidth: isIPad ? 4 : 3)
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
                        .onAppear {
                            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                                animateGradient = true
                            }
                        }
                    }
                    .padding(.horizontal, isIPad ? 60 : 24)
                    .padding(.bottom, isIPad ? 80 : 50)
                    .frame(maxWidth: isIPad ? 600 : .infinity)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .ignoresSafeArea()
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
    var isIPad: Bool = false

    var body: some View {
        VStack(spacing: isIPad ? Spacing.lg : Spacing.md) {
            // Text content - clean and simple
            VStack(spacing: isIPad ? 16 : 10) {
                Text(page.titleKey.localized)
                    .font(.system(size: isIPad ? 32 : 24, weight: .bold))
                    .foregroundColor(.primaryGreen)
                    .multilineTextAlignment(.center)

                Text(page.subtitleKey.localized)
                    .font(.system(size: isIPad ? 20 : 15))
                    .foregroundColor(.primaryGreen.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, isIPad ? 50 : 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .environmentObject(LocalizationManager.shared)
}
