import SwiftUI
import Combine

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var showAuth = false
    @State private var showLanguagePicker = false
    @State private var showEditProfile = false
    @State private var appearAnimation = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if viewModel.isAuthenticated {
                        authenticatedContent
                    } else {
                        guestContent
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 120)
            }
            .refreshable {
                await viewModel.loadData()
            }
            .background(
                LinearGradient(
                    colors: [Color(.systemGray6), Color(.systemGray5).opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationTitle(L10n.Tabs.profile.localized)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAuth) {
                AuthView()
            }
            .sheet(isPresented: $showLanguagePicker) {
                LanguagePickerSheet()
            }
            .sheet(isPresented: $showEditProfile) {
                if let user = viewModel.user {
                    EditProfileView(user: user)
                        .onDisappear {
                            // Refresh user data after editing
                            Task {
                                await viewModel.loadData()
                            }
                        }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "An unexpected error occurred")
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    appearAnimation = true
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
    }

    // MARK: - Guest Content

    private var guestContent: some View {
        VStack(spacing: 20) {
            // Guest Header Card
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.primaryGreen.opacity(0.2), Color.primaryGreen.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 90, height: 90)

                    Image(systemName: "person.fill")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }

                VStack(spacing: 6) {
                    Text(L10n.Profile.guest.localized)
                        .font(.title3.weight(.bold))
                        .foregroundColor(.primary)

                    Text(L10n.Profile.signInToAccess.localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button {
                    showAuth = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 18))
                        Text(L10n.Auth.signIn.localized)
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .padding(.vertical, 28)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 5)
            .offset(y: appearAnimation ? 0 : 20)
            .opacity(appearAnimation ? 1 : 0)

            // Settings
            settingsSection
                .offset(y: appearAnimation ? 0 : 20)
                .opacity(appearAnimation ? 1 : 0)

            // Social Media
            socialMediaSection
                .offset(y: appearAnimation ? 0 : 20)
                .opacity(appearAnimation ? 1 : 0)
        }
    }

    // MARK: - Authenticated Content

    private var authenticatedContent: some View {
        VStack(spacing: 20) {
            // User card
            userCard
                .offset(y: appearAnimation ? 0 : 20)
                .opacity(appearAnimation ? 1 : 0)

            // Email verification banner
            if viewModel.needsEmailVerification {
                emailVerificationBanner
                    .offset(y: appearAnimation ? 0 : 20)
                    .opacity(appearAnimation ? 1 : 0)
            }

            // My Reviews
            myReviewsSection
                .offset(y: appearAnimation ? 0 : 20)
                .opacity(appearAnimation ? 1 : 0)

            // My Claims
            myClaimsSection
                .offset(y: appearAnimation ? 0 : 20)
                .opacity(appearAnimation ? 1 : 0)

            // Settings
            settingsSection
                .offset(y: appearAnimation ? 0 : 20)
                .opacity(appearAnimation ? 1 : 0)

            // Social Media
            socialMediaSection
                .offset(y: appearAnimation ? 0 : 20)
                .opacity(appearAnimation ? 1 : 0)

            // Logout
            logoutButton
                .offset(y: appearAnimation ? 0 : 20)
                .opacity(appearAnimation ? 1 : 0)
        }
    }

    // MARK: - User Card

    private var userCard: some View {
        Button {
            showEditProfile = true
        } label: {
            HStack(spacing: 14) {
                // Avatar with image or fallback to initials
                userAvatarView

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(viewModel.user?.name ?? "User")
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text("profile_edit_hint".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text(viewModel.user?.displayEmail ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 32, height: 32)

                    Image(systemName: "chevron.forward")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primaryGreen)
                }
            }
            .padding(18)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - User Avatar View

    @ViewBuilder
    private var userAvatarView: some View {
        if let avatarURL = viewModel.user?.avatar, !avatarURL.isEmpty {
            CachedAvatarImage(urlString: avatarURL, size: 56)
        } else {
            avatarFallback
        }
    }

    private var avatarFallback: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.primaryGreen.opacity(0.2), Color.primaryGreen.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 56, height: 56)

            Text(viewModel.user?.initials ?? "?")
                .font(.title3.weight(.bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }

    // MARK: - Email Verification Banner

    private var emailVerificationBanner: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 36, height: 36)

                    Image(systemName: "envelope.badge.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.orange)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.Auth.verifyEmail.localized)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)

                    Text(L10n.Auth.verifyEmailMessage.localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }

            Button {
                Task {
                    await viewModel.resendVerificationEmail()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 12, weight: .semibold))
                    Text(L10n.Auth.resendEmail.localized)
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.orange)
                .cornerRadius(10)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - My Reviews Section

    private var myReviewsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "star.bubble.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primaryGreen)

                    Text(L10n.Profile.myReviews.localized)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                }

                Spacer()

                Text("\(viewModel.myReviews.count)")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.primaryGreen)
                    .cornerRadius(10)
            }

            if viewModel.myReviews.isEmpty {
                emptySection(
                    icon: "star.bubble",
                    message: L10n.Profile.noReviewsYet.localized
                )
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.myReviews.prefix(3)) { review in
                        MyReviewRow(review: review)
                    }
                }

                if viewModel.myReviews.count > 3 {
                    Button {
                        // Navigate to all reviews
                    } label: {
                        HStack(spacing: 4) {
                            Text(L10n.Profile.seeAllReviews.localized)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 10))
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.primaryGreen)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 4)
                }
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }

    // MARK: - My Claims Section

    private var myClaimsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primaryGreen)

                    Text(L10n.Profile.myClaims.localized)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                }

                Spacer()

                Text("\(viewModel.myClaims.count)")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.primaryGreen)
                    .cornerRadius(10)
            }

            if viewModel.myClaims.isEmpty {
                emptySection(
                    icon: "hand.raised",
                    message: L10n.Profile.noClaimsYet.localized
                )
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.myClaims) { claim in
                        MyClaimRow(claim: claim)
                    }
                }
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }

    private func emptySection(icon: String, message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(.systemGray3))

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(spacing: 0) {
            ModernSettingsRow(
                icon: "globe",
                iconColor: .blue,
                title: L10n.Profile.language.localized,
                value: localizationManager.currentLanguage.displayName
            ) {
                showLanguagePicker = true
            }

            ModernSettingsRow(
                icon: "questionmark.circle",
                iconColor: .purple,
                title: L10n.Profile.support.localized
            ) {
                openSupport()
            }

            ModernSettingsRow(
                icon: "doc.text",
                iconColor: .orange,
                title: L10n.Profile.terms.localized
            ) {
                // Open terms
            }

            ModernSettingsRow(
                icon: "hand.raised",
                iconColor: .pink,
                title: L10n.Profile.privacy.localized,
                showDivider: false
            ) {
                // Open privacy
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }

    // MARK: - Social Media Section

    private var socialMediaSection: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.primaryGreen)

                Text(L10n.Profile.followUs.localized)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 16) {
                ModernSocialButton(iconName: "Instagram", url: "https://instagram.com/preuvely")
                ModernSocialButton(iconName: "facebook", url: "https://facebook.com/preuvely")
                ModernSocialButton(iconName: "Tiktok", url: "https://tiktok.com/@preuvely")
                ModernSocialButton(iconName: "Whatsapp", url: "https://wa.me/213555123456")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }

    // MARK: - Logout Button

    private var logoutButton: some View {
        Button {
            Task {
                await viewModel.logout()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16))
                Text(L10n.Auth.logout.localized)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.red.opacity(0.08))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.red.opacity(0.2), lineWidth: 1)
            )
        }
    }

    private func openSupport() {
        guard let url = URL(string: "https://wa.me/213555123456") else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - My Review Row

struct MyReviewRow: View {
    let review: Review

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.starYellow.opacity(0.15))
                    .frame(width: 40, height: 40)

                Text("\(review.stars)")
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.starYellow)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(review.store?.name ?? "Store")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= review.stars ? "star.fill" : "star")
                            .font(.system(size: 10))
                            .foregroundColor(star <= review.stars ? .starYellow : Color(.systemGray4))
                    }
                }
            }

            Spacer()

            StatusBadge(status: review.status.rawValue.capitalized, color: review.status == .approved ? .green : .orange)
        }
        .padding(12)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }
}

// MARK: - My Claim Row

struct MyClaimRow: View {
    let claim: Claim

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.primaryGreen.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: "storefront")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primaryGreen)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(claim.displayStoreName)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)

                Text(claim.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let rejectReason = claim.rejectReason, claim.status == .rejected {
                    Text(rejectReason)
                        .font(.caption2)
                        .foregroundColor(.red)
                        .lineLimit(1)
                }
            }

            Spacer()

            StatusBadge(claimStatus: claim.status)
        }
        .padding(12)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }
}

// MARK: - Modern Settings Row

struct ModernSettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var value: String? = nil
    var showDivider: Bool = true
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(iconColor.opacity(0.12))
                            .frame(width: 36, height: 36)

                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(iconColor)
                    }

                    Text(title)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.primary)

                    Spacer()

                    if let value = value {
                        Text(value)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Image(systemName: "chevron.forward")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(.systemGray3))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            if showDivider {
                Divider()
                    .padding(.leading, 66)
            }
        }
    }
}

// MARK: - Modern Social Button

struct ModernSocialButton: View {
    let iconName: String
    let url: String

    @State private var isPressed = false

    var body: some View {
        Button {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(.systemGray6), Color(.systemGray5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 52, height: 52)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)

                Image(iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 26, height: 26)
            }
            .scaleEffect(isPressed ? 0.92 : 1.0)
        }
        .buttonStyle(.plain)
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isPressed = false
            }
        }
    }
}

// MARK: - Settings Row (Legacy - keeping for compatibility)

struct SettingsRow: View {
    let icon: String
    let title: String
    var value: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.primaryGreen)
                    .frame(width: 24, height: 24)

                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Spacer()

                if let value = value {
                    Text(value)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Image(systemName: "chevron.forward")
                    .font(.system(size: 12))
                    .foregroundColor(Color(.systemGray3))
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Social Media Button (Legacy - keeping for compatibility)

struct SocialMediaButton: View {
    let iconName: String
    let url: String

    @State private var isPressed = false

    var body: some View {
        Button {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        } label: {
            Image(iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(.plain)
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isPressed = false
            }
        }
    }
}

// MARK: - Language Picker Sheet

struct LanguagePickerSheet: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLanguage: AppLanguage?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.primaryGreen.opacity(0.15), Color.primaryGreen.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)

                        Image(systemName: "globe")
                            .font(.system(size: 26, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }

                    Text(L10n.Profile.language.localized)
                        .font(.title3.weight(.bold))
                        .foregroundColor(.primary)
                }
                .padding(.top, 24)
                .padding(.bottom, 20)

                // Language Options
                VStack(spacing: 12) {
                    ForEach(AppLanguage.allCases) { language in
                        LanguageOptionCard(
                            language: language,
                            isSelected: localizationManager.currentLanguage == language
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                localizationManager.setLanguage(language)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                dismiss()
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Common.done.localized) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryGreen)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Language Option Card

struct LanguageOptionCard: View {
    let language: AppLanguage
    let isSelected: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Flag Image
                Image(language.flagImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                isSelected ? Color.primaryGreen : Color(.systemGray4),
                                lineWidth: isSelected ? 3 : 1
                            )
                    )
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

                // Language Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.nativeName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(language.countryName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Selection Indicator
                ZStack {
                    Circle()
                        .stroke(
                            isSelected ? Color.primaryGreen : Color(.systemGray4),
                            lineWidth: 2
                        )
                        .frame(width: 26, height: 26)

                    if isSelected {
                        Circle()
                            .fill(Color.primaryGreen)
                            .frame(width: 26, height: 26)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: isSelected ? Color.primaryGreen.opacity(0.15) : Color.black.opacity(0.04),
                        radius: isSelected ? 8 : 4,
                        x: 0,
                        y: 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.primaryGreen.opacity(0.5) : Color.clear,
                        lineWidth: 2
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(.plain)
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = false
            }
        }
    }
}

// MARK: - Profile ViewModel

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var myReviews: [Review] = []
    @Published var myClaims: [Claim] = []

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false

    private let apiClient: APIClient

    var isAuthenticated: Bool {
        apiClient.isAuthenticated
    }

    var needsEmailVerification: Bool {
        user?.isEmailVerified == false
    }

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
        self.user = apiClient.currentUser
    }

    func loadData() async {
        guard isAuthenticated else {
            user = nil
            return
        }

        isLoading = true

        do {
            // Fetch current user from API to get fresh data
            if let fetchedUser = try await apiClient.getCurrentUser() {
                user = fetchedUser
            } else {
                user = apiClient.currentUser
            }

            myClaims = try await apiClient.getMyClaims()
            // Fetch user's reviews from API
            let reviewsResponse = try await apiClient.getMyReviews()
            myReviews = reviewsResponse.data
        } catch {
            // Fallback to cached user on error
            user = apiClient.currentUser
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    func resendVerificationEmail() async {
        do {
            try await apiClient.resendVerificationEmail()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func logout() async {
        do {
            try await apiClient.logout()
            user = nil
            myReviews = []
            myClaims = []
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - Cached Avatar Image

/// Custom avatar image view that loads images using URLSession
/// and handles caching more reliably than AsyncImage
struct CachedAvatarImage: View {
    let urlString: String
    let size: CGFloat

    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var loadFailed = false

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else if isLoading {
                ProgressView()
                    .frame(width: size, height: size)
            } else {
                // Show placeholder on failure
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: size, height: size)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    )
            }
        }
        .id(urlString) // Force refresh when URL changes
        .task(id: urlString) {
            await loadImage()
        }
    }

    private func loadImage() async {
        guard let url = URL(string: urlString) else {
            isLoading = false
            loadFailed = true
            return
        }

        isLoading = true
        loadFailed = false
        image = nil

        // Create request with cache policy to bypass stale cache
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                #if DEBUG
                print("[CachedAvatarImage] Failed to load: HTTP \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                #endif
                isLoading = false
                loadFailed = true
                return
            }

            if let loadedImage = UIImage(data: data) {
                await MainActor.run {
                    self.image = loadedImage
                    self.isLoading = false
                }
                #if DEBUG
                print("[CachedAvatarImage] Successfully loaded image from: \(urlString)")
                #endif
            } else {
                #if DEBUG
                print("[CachedAvatarImage] Failed to create UIImage from data")
                #endif
                isLoading = false
                loadFailed = true
            }
        } catch {
            #if DEBUG
            print("[CachedAvatarImage] Error loading image: \(error.localizedDescription)")
            #endif
            isLoading = false
            loadFailed = true
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
        .environmentObject(LocalizationManager.shared)
}
