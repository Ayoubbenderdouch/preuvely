import SwiftUI
import Combine

struct StoreDetailsView: View {
    @StateObject private var viewModel: StoreDetailsViewModel
    @State private var showWriteReview = false
    @State private var showClaimStore = false
    @State private var showReportStore = false

    /// Initialize with a store from search results
    init(store: Store) {
        self._viewModel = StateObject(wrappedValue: StoreDetailsViewModel(store: store))
    }

    /// Initialize with a store slug (for deep links)
    init(slug: String) {
        self._viewModel = StateObject(wrappedValue: StoreDetailsViewModel(slug: slug))
    }

    /// Convenience accessor for the store from viewModel
    private var store: Store {
        viewModel.store
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                headerSection

                // Social Media
                socialMediaSection

                // Links
                linksSection

                // Contacts
                contactsSection

                // Rating Summary
                ratingSummarySection

                // Reviews
                reviewsSection
            }
        }
        .refreshable {
            await viewModel.loadData()
        }
        .background(Color(.secondarySystemBackground))
        .navigationTitle(store.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showClaimStore = true
                    } label: {
                        Label(L10n.Store.claimStore.localized, systemImage: "hand.raised.fill")
                    }

                    Button(role: .destructive) {
                        showReportStore = true
                    } label: {
                        Label(L10n.Store.reportStore.localized, systemImage: "exclamationmark.triangle.fill")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showWriteReview) {
            // Refresh reviews after dismissing the write review sheet
            Task {
                await viewModel.refreshReviews()
            }
        } content: {
            WriteReviewSheet(store: store)
        }
        .sheet(isPresented: $showClaimStore) {
            ClaimStoreSheet(store: store)
        }
        .sheet(isPresented: $showReportStore) {
            ReportSheet(reportableType: .store, reportableId: store.id, reportableName: store.name)
        }
        .task {
            await viewModel.loadData()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: Spacing.lg) {
            // Store Logo
            storeLogoView

            VStack(alignment: .center, spacing: Spacing.md) {
                // Name and badges
                HStack(spacing: Spacing.sm) {
                    Text(store.name)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)

                    if store.isVerified {
                        VerifiedBadge(size: .large)
                    }

                    if viewModel.summary?.proofBadge == true {
                        ProofBadge()
                    }
                }

                // Description
                if let description = store.description {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Categories
                if !store.categories.isEmpty {
                    HStack(spacing: Spacing.xs) {
                        ForEach(store.categories) { category in
                            CategoryChip(category: category)
                        }
                    }
                }

                // City
                if let city = store.city {
                    Label(city, systemImage: "mappin.circle.fill")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(Spacing.screenPadding)
        .background(Color(.systemBackground))
    }

    // MARK: - Store Logo View

    private var storeLogoView: some View {
        Group {
            if let logoURL = store.logo, let url = URL(string: logoURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    case .failure:
                        storeLogoFallback
                    case .empty:
                        ProgressView()
                            .frame(width: 100, height: 100)
                    @unknown default:
                        storeLogoFallback
                    }
                }
            } else {
                storeLogoFallback
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    /// Fallback view when no logo is available
    private var storeLogoFallback: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.primaryGreen.opacity(0.2), Color.primaryGreen.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)

            Text(store.name.prefix(1).uppercased())
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    // MARK: - Social Media Section

    private var socialMediaLinks: [StoreLink] {
        store.links.filter { [.instagram, .facebook, .tiktok, .whatsapp].contains($0.platform) }
    }

    private var socialMediaSection: some View {
        Group {
            if !socialMediaLinks.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text(L10n.Store.contact.localized)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal, Spacing.screenPadding)

                    HStack(spacing: Spacing.lg) {
                        ForEach(Array(socialMediaLinks.enumerated()), id: \.element.id) { index, link in
                            StoreSocialButton(link: link, animationDelay: Double(index) * 0.1) {
                                openLink(link)
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.screenPadding)
                }
                .padding(.top, Spacing.lg)
            }
        }
    }

    // MARK: - Links Section

    private var linksSection: some View {
        Group {
            if !store.links.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text(L10n.Store.links.localized)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal, Spacing.screenPadding)

                    VStack(spacing: Spacing.sm) {
                        ForEach(store.links) { link in
                            PlatformLinkButton(link: link) {
                                openLink(link)
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.screenPadding)
                }
                .padding(.top, Spacing.lg)
            }
        }
    }

    // MARK: - Contacts Section

    private var contactsSection: some View {
        Group {
            if let contacts = store.contacts, (contacts.whatsapp != nil || contacts.phone != nil) {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text(L10n.Store.contact.localized)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal, Spacing.screenPadding)

                    HStack(spacing: Spacing.md) {
                        if let whatsapp = contacts.whatsapp {
                            ContactButton(
                                icon: "message.fill",
                                label: "WhatsApp",
                                color: .whatsappGreen,
                                customIcon: "Whatsapp"
                            ) {
                                openWhatsApp(whatsapp)
                            }
                        }

                        if let phone = contacts.phone {
                            ContactButton(
                                icon: "phone.fill",
                                label: L10n.Store.call.localized,
                                color: .primaryGreen
                            ) {
                                callPhone(phone)
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.screenPadding)
                }
                .padding(.top, Spacing.lg)
            }
        }
    }

    // MARK: - Rating Summary Section

    private var ratingSummarySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(L10n.Store.ratingBreakdown.localized)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal, Spacing.screenPadding)

            if let summary = viewModel.summary {
                RatingBreakdownView(
                    breakdown: summary.ratingBreakdown,
                    avgRating: summary.avgRating,
                    totalReviews: summary.reviewsCount
                )
                .padding(.horizontal, Spacing.screenPadding)
            } else if viewModel.isLoadingSummary {
                RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                    .fill(Color(.systemGray5))
                    .frame(height: 150)
                    .shimmer()
                    .padding(.horizontal, Spacing.screenPadding)
            }

            // Write Review Button (only show if user hasn't reviewed)
            if viewModel.userReview == nil {
                Button {
                    showWriteReview = true
                } label: {
                    Label(L10n.Store.writeReview.localized, systemImage: "square.and.pencil")
                }
                .primaryButtonStyle()
                .padding(.horizontal, Spacing.screenPadding)
            } else {
                // User already reviewed - show their review status
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.primaryGreen)
                    Text("you_already_reviewed".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, Spacing.screenPadding)
            }
        }
        .padding(.top, Spacing.sectionSpacing)
    }

    // MARK: - Reviews Section

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text(L10n.Store.reviews.localized)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                // Show total from summary if available, otherwise show loaded count
                Text("\(viewModel.summary?.reviewsCount ?? viewModel.reviews.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, Spacing.screenPadding)

            if viewModel.isLoadingReviews && viewModel.reviews.isEmpty {
                VStack(spacing: Spacing.md) {
                    ForEach(0..<3, id: \.self) { _ in
                        ReviewCardSkeleton()
                    }
                }
                .padding(.horizontal, Spacing.screenPadding)
            } else if viewModel.reviews.isEmpty {
                EmptyReviewsView()
                    .padding(.horizontal, Spacing.screenPadding)
            } else {
                LazyVStack(spacing: Spacing.md) {
                    ForEach(viewModel.reviews) { review in
                        ReviewCard(review: review, showUserLink: false)
                    }

                    // Load more reviews button
                    if viewModel.hasMoreReviews {
                        Button {
                            Task {
                                await viewModel.loadMoreReviews()
                            }
                        } label: {
                            if viewModel.isLoadingMoreReviews {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("load_more_reviews".localized)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.primaryGreen)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.primaryGreen.opacity(0.1))
                                    .cornerRadius(Spacing.radiusMedium)
                            }
                        }
                        .disabled(viewModel.isLoadingMoreReviews)
                    }
                }
                .padding(.horizontal, Spacing.screenPadding)
            }
        }
        .padding(.top, Spacing.sectionSpacing)
        .padding(.bottom, Spacing.xxxl)
    }

    // MARK: - Actions

    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString), url.scheme != nil else { return }
        UIApplication.shared.open(url)
    }

    private func openLink(_ link: StoreLink) {
        let urlString = link.url.trimmingCharacters(in: .whitespacesAndNewlines)

        // If it's already a full URL, open it directly
        if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
            return
        }

        // Extract handle (remove @ if present)
        let handle = urlString.hasPrefix("@") ? String(urlString.dropFirst()) : urlString

        // Construct URL based on platform
        var finalURL: URL?

        switch link.platform {
        case .instagram:
            // Try app first, then web
            if let appURL = URL(string: "instagram://user?username=\(handle)"),
               UIApplication.shared.canOpenURL(appURL) {
                finalURL = appURL
            } else {
                finalURL = URL(string: "https://instagram.com/\(handle)")
            }

        case .facebook:
            // Facebook URL - could be page name or ID
            if let appURL = URL(string: "fb://profile/\(handle)"),
               UIApplication.shared.canOpenURL(appURL) {
                finalURL = appURL
            } else {
                finalURL = URL(string: "https://facebook.com/\(handle)")
            }

        case .tiktok:
            if let appURL = URL(string: "tiktok://user?username=\(handle)"),
               UIApplication.shared.canOpenURL(appURL) {
                finalURL = appURL
            } else {
                finalURL = URL(string: "https://tiktok.com/@\(handle)")
            }

        case .whatsapp:
            // WhatsApp - handle is phone number
            let cleanNumber = handle.replacingOccurrences(of: "+", with: "")
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "-", with: "")
            finalURL = URL(string: "https://wa.me/\(cleanNumber)")

        case .website:
            // For website, add https if no scheme
            if urlString.contains(".") {
                finalURL = URL(string: "https://\(urlString)")
            }
        }

        if let url = finalURL {
            UIApplication.shared.open(url)
        }
    }

    private func openWhatsApp(_ number: String) {
        let cleanNumber = number.replacingOccurrences(of: "+", with: "")
        guard let url = URL(string: "https://wa.me/\(cleanNumber)") else { return }
        UIApplication.shared.open(url)
    }

    private func callPhone(_ number: String) {
        guard let url = URL(string: "tel://\(number)") else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Contact Button

struct ContactButton: View {
    let icon: String
    let label: String
    let color: Color
    var customIcon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                if let customIcon = customIcon {
                    Image(customIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(color)
                        .clipShape(Circle())
                }

                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Store Social Button

struct StoreSocialButton: View {
    let link: StoreLink
    let animationDelay: Double
    let action: () -> Void

    @State private var isAppeared = false
    @State private var isPressed = false

    private var iconName: String {
        switch link.platform {
        case .instagram: return "Instagram"
        case .facebook: return "facebook"
        case .tiktok: return "Tiktok"
        case .whatsapp: return "Whatsapp"
        case .website: return "globe"
        }
    }

    private var backgroundColor: Color {
        switch link.platform {
        case .instagram: return .instagramPink
        case .facebook: return .facebookBlue
        case .tiktok: return .black
        case .whatsapp: return .whatsappGreen
        case .website: return .primaryGreen
        }
    }

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                action()
            }
        }) {
            VStack(spacing: Spacing.xs) {
                ZStack {
                    Circle()
                        .fill(backgroundColor.opacity(0.15))
                        .frame(width: 60, height: 60)

                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .shadow(color: backgroundColor.opacity(0.3), radius: isPressed ? 2 : 6, y: isPressed ? 1 : 3)

                Text(link.platform.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isAppeared ? 1.0 : 0.5)
        .opacity(isAppeared ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(animationDelay)) {
                isAppeared = true
            }
        }
        .accessibilityLabel(Text("Open \(link.platform.displayName)"))
        .accessibilityHint(Text("Opens \(link.platform.displayName) in a new window"))
    }
}

// MARK: - Empty Reviews View

struct EmptyReviewsView: View {
    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "star.bubble")
                .font(.system(size: 40))
                .foregroundColor(Color(.systemGray3))

            Text(L10n.Store.noReviewsYet.localized)
                .font(.headline)
                .foregroundColor(.secondary)

            Text(L10n.Store.beFirstToReview.localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xl)
        .background(Color(.systemBackground))
        .cornerRadius(Spacing.radiusMedium)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        StoreDetailsView(store: Store.sample)
    }
    .environmentObject(LocalizationManager.shared)
}
