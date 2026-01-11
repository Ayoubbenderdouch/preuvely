import SwiftUI
import Combine

/// View displaying a user's public profile with their submitted stores and reviews
struct UserProfileView: View {
    @StateObject private var viewModel: UserProfileViewModel
    @State private var selectedTab: ProfileTab = .stores

    enum ProfileTab: String, CaseIterable {
        case stores
        case reviews

        var title: String {
            switch self {
            case .stores: return L10n.UserProfile.stores.localized
            case .reviews: return L10n.UserProfile.reviews.localized
            }
        }

        var icon: String {
            switch self {
            case .stores: return "storefront"
            case .reviews: return "star.bubble"
            }
        }
    }

    // MARK: - Initialization

    /// Initialize with a user ID
    init(userId: Int) {
        self._viewModel = StateObject(wrappedValue: UserProfileViewModel(userId: userId))
    }

    /// Initialize with a StoreSubmitter
    init(submitter: StoreSubmitter) {
        self._viewModel = StateObject(wrappedValue: UserProfileViewModel(submitter: submitter))
    }

    /// Initialize with a ReviewUser
    init(reviewUser: ReviewUser) {
        self._viewModel = StateObject(wrappedValue: UserProfileViewModel(reviewUser: reviewUser))
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Profile Header
                profileHeader
                    .padding(.bottom, Spacing.lg)

                // Tab Selector
                tabSelector
                    .padding(.horizontal, Spacing.screenPadding)
                    .padding(.bottom, Spacing.md)

                // Content based on selected tab
                switch selectedTab {
                case .stores:
                    storesSection
                case .reviews:
                    reviewsSection
                }
            }
        }
        .background(Color(.secondarySystemBackground))
        .navigationTitle(viewModel.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.refresh()
        }
        .alert(L10n.Common.error.localized, isPresented: $viewModel.showError) {
            Button(L10n.Common.ok.localized, role: .cancel) {
                viewModel.error = nil
            }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "An unexpected error occurred")
        }
        .task {
            await viewModel.loadData()
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: Spacing.lg) {
            if viewModel.isLoadingProfile && viewModel.profile == nil {
                // Skeleton loading state
                profileHeaderSkeleton
            } else {
                // Avatar
                avatarView
                    .padding(.top, Spacing.lg)

                // Name
                Text(viewModel.displayName)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.primary)

                // Member since
                if let memberSince = viewModel.memberSinceText {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(L10n.UserProfile.memberSince.localized(with: memberSince))
                            .font(.subheadline)
                    }
                    .foregroundColor(.secondary)
                }

                // Stats
                statsRow
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, Spacing.lg)
        .background(Color(.systemBackground))
    }

    private var profileHeaderSkeleton: some View {
        VStack(spacing: Spacing.lg) {
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 80, height: 80)
                .shimmer()
                .padding(.top, Spacing.lg)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(width: 150, height: 24)
                .shimmer()

            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(width: 120, height: 16)
                .shimmer()

            HStack(spacing: Spacing.xl) {
                statSkeletonItem
                statSkeletonItem
            }
        }
    }

    private var statSkeletonItem: some View {
        VStack(spacing: Spacing.xs) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(width: 40, height: 24)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(width: 60, height: 14)
        }
        .shimmer()
    }

    // MARK: - Avatar View

    private var avatarView: some View {
        Group {
            if let avatarURL = viewModel.profile?.avatar, !avatarURL.isEmpty {
                // Use CachedAvatarImage which handles both base64 data URLs and regular HTTP URLs
                CachedAvatarImage(urlString: avatarURL, size: 80)
                    .overlay(
                        Circle()
                            .stroke(Color.primaryGreen.opacity(0.2), lineWidth: 3)
                    )
            } else {
                avatarPlaceholder
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.primaryGreen.opacity(0.2), lineWidth: 3)
                    )
            }
        }
    }

    private var avatarPlaceholder: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.primaryGreen.opacity(0.2), Color.primaryGreen.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text(viewModel.initials)
                .font(.title.weight(.bold))
                .foregroundColor(.primaryGreen)
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: Spacing.xxxl) {
            statItem(
                value: viewModel.storesCount,
                label: L10n.UserProfile.storesSubmitted.localized,
                icon: "storefront"
            )

            statItem(
                value: viewModel.reviewsCount,
                label: L10n.UserProfile.reviewsWritten.localized,
                icon: "star.bubble"
            )
        }
        .padding(.horizontal, Spacing.screenPadding)
    }

    private func statItem(value: Int, label: String, icon: String) -> some View {
        VStack(spacing: Spacing.xs) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primaryGreen)
                Text("\(value)")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.primary)
            }

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(ProfileTab.allCases, id: \.rawValue) { tab in
                tabButton(for: tab)
            }
        }
        .padding(4)
        .background(Color(.systemGray6))
        .cornerRadius(Spacing.radiusMedium)
    }

    private func tabButton(for tab: ProfileTab) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: Spacing.xs) {
                Image(systemName: tab.icon)
                    .font(.system(size: 14, weight: .medium))
                Text(tab.title)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundColor(selectedTab == tab ? .white : .secondary)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(
                selectedTab == tab
                    ? Color.primaryGreen
                    : Color.clear
            )
            .cornerRadius(Spacing.radiusSmall)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Stores Section

    private var storesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            if viewModel.isLoadingProfile && viewModel.stores.isEmpty {
                // Loading skeleton
                VStack(spacing: Spacing.md) {
                    ForEach(0..<3, id: \.self) { _ in
                        storeCardSkeleton
                    }
                }
                .padding(.horizontal, Spacing.screenPadding)
            } else if viewModel.stores.isEmpty {
                // Empty state
                emptyStateView(
                    icon: "storefront",
                    title: L10n.UserProfile.noStoresTitle.localized,
                    message: L10n.UserProfile.noStoresMessage.localized
                )
            } else {
                // Stores list
                LazyVStack(spacing: Spacing.md) {
                    ForEach(viewModel.stores) { store in
                        NavigationLink {
                            StoreDetailsView(store: store)
                        } label: {
                            StoreCard(store: store)
                        }
                        .buttonStyle(.plain)
                    }

                    // Load more button
                    if viewModel.hasMoreStores {
                        loadMoreButton(
                            isLoading: viewModel.isLoadingMoreStores
                        ) {
                            await viewModel.loadMoreStores()
                        }
                    }
                }
                .padding(.horizontal, Spacing.screenPadding)
            }
        }
        .padding(.bottom, Spacing.xxxl)
    }

    private var storeCardSkeleton: some View {
        HStack(spacing: Spacing.md) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))
                .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: Spacing.sm) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 150, height: 16)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 100, height: 12)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 80, height: 12)
            }

            Spacer()
        }
        .padding(Spacing.cardPadding)
        .background(Color(.systemBackground))
        .cornerRadius(Spacing.radiusMedium)
        .shimmer()
    }

    // MARK: - Reviews Section

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            if viewModel.isLoadingProfile && viewModel.reviews.isEmpty {
                // Loading skeleton
                VStack(spacing: Spacing.md) {
                    ForEach(0..<3, id: \.self) { _ in
                        ReviewCardSkeleton()
                    }
                }
                .padding(.horizontal, Spacing.screenPadding)
            } else if viewModel.reviews.isEmpty {
                // Empty state
                emptyStateView(
                    icon: "star.bubble",
                    title: L10n.UserProfile.noReviewsTitle.localized,
                    message: L10n.UserProfile.noReviewsMessage.localized
                )
            } else {
                // Reviews list
                LazyVStack(spacing: Spacing.md) {
                    ForEach(viewModel.reviews) { review in
                        UserReviewCard(review: review)
                    }

                    // Load more button
                    if viewModel.hasMoreReviews {
                        loadMoreButton(
                            isLoading: viewModel.isLoadingMoreReviews
                        ) {
                            await viewModel.loadMoreReviews()
                        }
                    }
                }
                .padding(.horizontal, Spacing.screenPadding)
            }
        }
        .padding(.bottom, Spacing.xxxl)
    }

    // MARK: - Helper Views

    private func emptyStateView(icon: String, title: String, message: String) -> some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(Color(.systemGray3))

            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xl)
        .padding(.top, Spacing.xxxl)
    }

    private func loadMoreButton(isLoading: Bool, action: @escaping () async -> Void) -> some View {
        Button {
            Task {
                await action()
            }
        } label: {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Text(L10n.Common.more.localized)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primaryGreen)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryGreen.opacity(0.1))
                    .cornerRadius(Spacing.radiusMedium)
            }
        }
        .disabled(isLoading)
    }
}

// MARK: - User Review Card (with store name)

/// A review card variant that shows the store name (for user profile reviews)
struct UserReviewCard: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Store info (if available)
            if let store = review.store {
                NavigationLink {
                    StoreDetailsView(slug: store.slug)
                } label: {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "storefront")
                            .font(.system(size: 14))
                            .foregroundColor(.primaryGreen)

                        Text(store.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.primaryGreen)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.medium))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                }
                .buttonStyle(.plain)
            }

            // Rating and date
            HStack {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= review.stars ? "star.fill" : "star")
                            .font(.system(size: 12))
                            .foregroundColor(star <= review.stars ? .starYellow : Color(.systemGray4))
                    }
                }

                Spacer()

                Text(review.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Comment
            Text(review.comment)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(nil)

            // Badges
            HStack(spacing: Spacing.sm) {
                if review.hasVerifiedProof {
                    ProofBadge()
                }

                if review.isHighRisk && review.proof?.status == .pending {
                    StatusBadge(status: L10n.Review.proofPending.localized, color: .orange)
                }
            }

            // Merchant Reply
            if let reply = review.reply {
                MerchantReplyView(reply: reply)
            }
        }
        .padding(Spacing.cardPadding)
        .background(Color(.systemBackground))
        .cornerRadius(Spacing.radiusMedium)
        .shadow(
            color: .black.opacity(0.04),
            radius: 4,
            x: 0,
            y: 2
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        UserProfileView(userId: 1)
    }
    .environmentObject(LocalizationManager.shared)
}
