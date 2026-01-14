import SwiftUI
import Combine

/// Authentication sheet shown when a user attempts to submit a review without being logged in.
/// Features a modern design with gradients, animations, and store context.
struct ReviewAuthSheet: View {
    let store: Store
    let onGoogleSignIn: () -> Void
    let onAppleSignIn: () -> Void
    let onEmailSignIn: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // MARK: - Animation States
    @State private var headerAppeared = false
    @State private var storeCardAppeared = false
    @State private var buttonsAppeared = false
    @State private var floatingIconsVisible = false
    @State private var pulseAnimation = false

    /// Maximum content width for iPad sheets
    private var maxContentWidth: CGFloat {
        horizontalSizeClass == .regular ? 500 : .infinity
    }

    var body: some View {
        ZStack {
            // Animated gradient background
            backgroundGradient

            // Floating decorative elements
            floatingDecorations

            // Main content
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.xxl) {
                    // Close button
                    closeButton

                    // Header section with icon and text
                    headerSection
                        .offset(y: headerAppeared ? 0 : -30)
                        .opacity(headerAppeared ? 1 : 0)

                    // Store info card
                    storeInfoCard
                        .offset(y: storeCardAppeared ? 0 : 30)
                        .opacity(storeCardAppeared ? 1 : 0)

                    // Sign in options
                    signInOptions
                        .offset(y: buttonsAppeared ? 0 : 30)
                        .opacity(buttonsAppeared ? 1 : 0)

                    // Terms text
                    termsText
                        .opacity(buttonsAppeared ? 1 : 0)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, Spacing.screenPadding)
                .padding(.top, Spacing.md)
                .frame(maxWidth: maxContentWidth)
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            startEntranceAnimations()
        }
    }

    // MARK: - Background Gradient

    private var backgroundGradient: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color.primaryGreen.opacity(0.05),
                    Color(.systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Animated gradient orbs
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.primaryGreen.opacity(0.15), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: -100, y: -200)
                .blur(radius: 40)
                .scaleEffect(pulseAnimation ? 1.1 : 1.0)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.primaryGreen.opacity(0.1), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .offset(x: 120, y: 400)
                .blur(radius: 30)
                .scaleEffect(pulseAnimation ? 1.0 : 1.15)
        }
        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: pulseAnimation)
    }

    // MARK: - Floating Decorations

    private var floatingDecorations: some View {
        ZStack {
            // Star icon
            Image(systemName: "star.fill")
                .font(.system(size: 16))
                .foregroundColor(.starYellow.opacity(0.6))
                .offset(x: -120, y: -80)
                .opacity(floatingIconsVisible ? 1 : 0)
                .rotationEffect(.degrees(floatingIconsVisible ? 15 : -15))

            // Review bubble icon
            Image(systemName: "text.bubble.fill")
                .font(.system(size: 14))
                .foregroundColor(.primaryGreen.opacity(0.5))
                .offset(x: 130, y: -120)
                .opacity(floatingIconsVisible ? 1 : 0)
                .rotationEffect(.degrees(floatingIconsVisible ? -10 : 10))

            // Checkmark icon
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 12))
                .foregroundColor(.primaryGreen.opacity(0.4))
                .offset(x: 100, y: 50)
                .opacity(floatingIconsVisible ? 1 : 0)
                .rotationEffect(.degrees(floatingIconsVisible ? 20 : -20))
        }
        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: floatingIconsVisible)
    }

    // MARK: - Close Button

    private var closeButton: some View {
        HStack {
            Spacer()
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 36, height: 36)

                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: Spacing.lg) {
            // Animated lock icon with gradient background
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.primaryGreen.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulseAnimation ? 1.1 : 1.0)

                // Main circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.primaryGreen.opacity(0.4), radius: 15, x: 0, y: 8)

                // Icon
                Image(systemName: "person.badge.shield.checkmark.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }

            VStack(spacing: Spacing.sm) {
                Text("auth_sign_in_to_review".localized)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                Text("auth_sign_in_to_review_subtitle".localized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
            }
        }
        .padding(.top, Spacing.md)
    }

    // MARK: - Store Info Card

    private var storeInfoCard: some View {
        VStack(spacing: 0) {
            // Card header with gradient
            HStack {
                Text("auth_reviewing".localized)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.9))

                Spacer()

                Image(systemName: "storefront.fill")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(
                LinearGradient(
                    colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.85)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )

            // Store content
            HStack(spacing: Spacing.md) {
                // Store logo or avatar
                if let logoURL = store.logo, let url = URL(string: logoURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 52, height: 52)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        case .failure, .empty:
                            storeAvatarFallback
                        @unknown default:
                            storeAvatarFallback
                        }
                    }
                } else {
                    storeAvatarFallback
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(store.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)

                        if store.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.primaryGreen)
                        }
                    }

                    HStack(spacing: Spacing.sm) {
                        // Rating
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.starYellow)

                            Text(store.formattedRating)
                                .font(.caption.weight(.medium))
                                .foregroundColor(.primary)
                        }

                        Text("*")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        // Reviews count
                        Text(L10n.Home.reviewsCount.localized(with: store.reviewsCount))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if let city = store.city {
                            Text("*")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            HStack(spacing: 2) {
                                Image(systemName: "mappin")
                                    .font(.system(size: 9))
                                Text(city)
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()
            }
            .padding(Spacing.lg)
            .background(Color(.systemBackground))
        }
        .cornerRadius(Spacing.radiusLarge)
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    /// Fallback avatar showing store initial
    private var storeAvatarFallback: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.primaryGreen.opacity(0.15), Color.primaryGreen.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 52, height: 52)

            Text(store.name.prefix(1).uppercased())
                .font(.title3.weight(.bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }

    // MARK: - Sign In Options

    private var signInOptions: some View {
        VStack(spacing: Spacing.lg) {
            // Google Sign In Button
            Button(action: onGoogleSignIn) {
                HStack(spacing: Spacing.md) {
                    // Google icon
                    Image("google")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22)

                    Text(L10n.Auth.signInWithGoogle.localized)
                        .font(.body.weight(.semibold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md + 2)
                .background(
                    RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                        .stroke(Color(.separator), lineWidth: 1)
                )
            }
            .buttonStyle(ScaleButtonStyle())

            // Apple Sign In Button
            Button(action: onAppleSignIn) {
                HStack(spacing: Spacing.md) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 20))

                    Text(L10n.Auth.signInWithApple.localized)
                        .font(.body.weight(.semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md + 2)
                .background(
                    RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                        .fill(Color.primary)
                )
            }
            .buttonStyle(ScaleButtonStyle())

            // Divider with "or"
            HStack(spacing: Spacing.md) {
                Rectangle()
                    .fill(Color(.separator))
                    .frame(height: 1)

                Text(L10n.Auth.orContinueWith.localized)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Rectangle()
                    .fill(Color(.separator))
                    .frame(height: 1)
            }
            .padding(.vertical, Spacing.sm)

            // Email Sign In Button
            Button(action: onEmailSignIn) {
                HStack(spacing: Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(Color.primaryGreen.opacity(0.12))
                            .frame(width: 32, height: 32)

                        Image(systemName: "envelope.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.primaryGreen)
                    }

                    Text("auth_sign_in_with_email".localized)
                        .font(.body.weight(.medium))
                        .foregroundColor(.primaryGreen)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                        .stroke(Color.primaryGreen, lineWidth: 1.5)
                )
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }

    // MARK: - Terms Text

    private var termsText: some View {
        Text("auth_terms_agreement".localized)
            .font(.caption2)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.md)
    }

    // MARK: - Entrance Animations

    private func startEntranceAnimations() {
        // Start pulse animation
        pulseAnimation = true

        // Staggered entrance animations
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
            headerAppeared = true
        }

        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
            storeCardAppeared = true
        }

        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) {
            buttonsAppeared = true
        }

        withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
            floatingIconsVisible = true
        }
    }
}

// MARK: - Preview

#Preview {
    ReviewAuthSheet(
        store: Store.sample,
        onGoogleSignIn: { print("Google sign in tapped") },
        onAppleSignIn: { print("Apple sign in tapped") },
        onEmailSignIn: { print("Email sign in tapped") }
    )
    .environmentObject(LocalizationManager.shared)
}

#Preview("Dark Mode") {
    ReviewAuthSheet(
        store: Store.sample,
        onGoogleSignIn: { print("Google sign in tapped") },
        onAppleSignIn: { print("Apple sign in tapped") },
        onEmailSignIn: { print("Email sign in tapped") }
    )
    .preferredColorScheme(.dark)
    .environmentObject(LocalizationManager.shared)
}
