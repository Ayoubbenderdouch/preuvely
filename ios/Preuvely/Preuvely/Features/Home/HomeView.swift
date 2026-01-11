import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var notificationViewModel = NotificationViewModel()
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var searchText = ""
    @State private var showSearch = false
    @State private var showAllCategories = false
    @State private var showNotifications = false
    @State private var appearAnimation = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Categories Grid
                    categoriesSection
                        .offset(y: appearAnimation ? 0 : 20)
                        .opacity(appearAnimation ? 1 : 0)

                    // Promo Carousel
                    PromoCarouselView(banners: viewModel.banners)
                        .offset(y: appearAnimation ? 0 : 20)
                        .opacity(appearAnimation ? 1 : 0)

                    // Top Reviewed Section
                    topReviewedSection
                        .offset(y: appearAnimation ? 0 : 20)
                        .opacity(appearAnimation ? 1 : 0)

                    Spacer(minLength: 100)
                }
                .padding(.top, 10)
            }
            .refreshable {
                await viewModel.loadData()
                await notificationViewModel.loadNotifications()
            }
            .background(
                LinearGradient(
                    colors: [Color(.systemGray6), Color(.systemGray5).opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .safeAreaInset(edge: .top) {
                topBar
            }
            .navigationBarHidden(true)
            .navigationDestination(for: Store.self) { store in
                StoreDetailsView(store: store)
            }
            .navigationDestination(for: Category.self) { category in
                CategoryStoresView(category: category)
            }
            .sheet(isPresented: $showAllCategories) {
                AllCategoriesSheet(categories: viewModel.categories)
            }
            .sheet(isPresented: $showNotifications) {
                NotificationView()
            }
            .fullScreenCover(isPresented: $showSearch) {
                SearchView()
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            )) {
                Button("OK", role: .cancel) {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "An unexpected error occurred")
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    appearAnimation = true
                }
            }
        }
        .task {
            await viewModel.loadData()
            await notificationViewModel.loadNotifications()
        }
    }

    // MARK: - Top Bar (Fixed Header)

    private var topBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // App Logo - Bigger
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 52, height: 52)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

                // Search Field
                Button {
                    showSearch = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(.systemGray2))

                        Text(L10n.Home.searchPlaceholder.localized)
                            .font(.subheadline)
                            .foregroundColor(Color(.systemGray2))

                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
                }
                .buttonStyle(.plain)

                // Notification Icon
                Button {
                    showNotifications = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: 44, height: 44)

                        Image(systemName: "bell.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)

                        // Notification badge (only show if unread)
                        if notificationViewModel.hasUnreadNotifications {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 10, height: 10)
                                .offset(x: 10, y: -10)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Color(.systemBackground)
                    .ignoresSafeArea(edges: .top)
            )

            // Bottom shadow line
            Rectangle()
                .fill(Color.black.opacity(0.06))
                .frame(height: 1)
        }
    }

    // MARK: - Categories Section

    private var categoriesSection: some View {
        VStack(spacing: 16) {
            // Section Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primaryGreen)

                    Text(L10n.Home.categories.localized)
                        .font(.headline)
                        .foregroundColor(.primary)
                }

                Spacer()

                Button {
                    showAllCategories = true
                } label: {
                    HStack(spacing: 4) {
                        Text(L10n.Common.seeAll.localized)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primaryGreen)
                }
            }
            .padding(.horizontal, 20)

            // Categories Grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.categories.filter { $0.shouldShowOnHome }.prefix(8)) { category in
                    ModernCategoryTile(category: category)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Top Reviewed Section

    private var topReviewedSection: some View {
        VStack(spacing: 16) {
            // Section Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.starYellow)

                    Text(L10n.Home.topReviewed.localized)
                        .font(.headline)
                        .foregroundColor(.primary)
                }

                Spacer()

                Button {
                    showSearch = true
                } label: {
                    HStack(spacing: 4) {
                        Text(L10n.Common.seeAll.localized)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primaryGreen)
                }
            }
            .padding(.horizontal, 20)

            // Store Cards Grid
            let columns = [
                GridItem(.flexible(), spacing: 14),
                GridItem(.flexible(), spacing: 14)
            ]

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(viewModel.topRatedStores) { store in
                    NavigationLink(value: store) {
                        ModernStoreCard(store: store)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Modern Category Tile

struct ModernCategoryTile: View {
    let category: Category
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var isPressed = false

    var body: some View {
        NavigationLink(value: category) {
            VStack(spacing: 6) {
                // Category image - no background
                if UIImage(named: category.localImageName) != nil {
                    Image(category.localImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 65, height: 65)
                } else {
                    Image(systemName: category.sfSymbol)
                        .font(.system(size: 44, weight: .medium))
                        .foregroundColor(.primaryGreen)
                        .frame(width: 65, height: 65)
                }

                Text(category.localizedName(for: localizationManager.currentLanguage))
                    .font(.caption.weight(.medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .scaleEffect(isPressed ? 0.85 : 1.0)
            .offset(y: isPressed ? 4 : 0)
            .brightness(isPressed ? -0.15 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

// MARK: - Modern Store Card

struct ModernStoreCard: View {
    let store: Store

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Store Image/Initial
            ZStack {
                if let logoURL = store.logo, let url = URL(string: logoURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure, .empty:
                            placeholderView
                        @unknown default:
                            placeholderView
                        }
                    }
                } else {
                    placeholderView
                }
            }
            .frame(height: 100)
            .clipped()

            // Store Info
            VStack(alignment: .leading, spacing: 6) {
                // Store name with verified badge
                HStack(spacing: 4) {
                    Text(store.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    if store.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.primaryGreen)
                    }
                }

                // Rating & Reviews
                HStack(spacing: 6) {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.starYellow)

                        Text(String(format: "%.1f", store.avgRating))
                            .font(.caption.weight(.medium))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.starYellow.opacity(0.15))
                    .cornerRadius(8)

                    Text("\(store.reviewsCount) reviews")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    private var placeholderView: some View {
        ZStack {
            LinearGradient(
                colors: [Color.primaryGreen.opacity(0.15), Color.primaryGreen.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Text(store.name.prefix(1).uppercased())
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .offset(y: configuration.isPressed ? 3 : 0)
            .brightness(configuration.isPressed ? -0.1 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0), value: configuration.isPressed)
    }
}

// MARK: - Promo Carousel

struct PromoCarouselView: View {
    let banners: [Banner]
    @State private var currentPage = 0

    var body: some View {
        VStack(spacing: 12) {
            if banners.isEmpty {
                // Placeholder when loading
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray5))
                    .frame(height: 150)
                    .padding(.horizontal, 20)
                    .shimmer()
            } else {
                TabView(selection: $currentPage) {
                    ForEach(Array(banners.enumerated()), id: \.element.id) { index, banner in
                        BannerCard(banner: banner)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 150)
                .cornerRadius(20)
                .padding(.horizontal, 20)

                // Page indicators
                HStack(spacing: 6) {
                    ForEach(0..<banners.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? Color.primaryGreen : Color(.systemGray4))
                            .frame(width: index == currentPage ? 20 : 6, height: 6)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
            }
        }
        .task {
            await autoAdvance()
        }
    }

    private func autoAdvance() async {
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 4_000_000_000) // 4 seconds
            guard !Task.isCancelled, !banners.isEmpty else { break }
            withAnimation(.spring(response: 0.5)) {
                currentPage = (currentPage + 1) % banners.count
            }
        }
    }
}

// MARK: - Banner Card

struct BannerCard: View {
    let banner: Banner

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background - Image or Color
                if let url = URL(string: banner.imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                        case .failure:
                            backgroundGradient
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        case .empty:
                            backgroundGradient
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .overlay(
                                    ProgressView()
                                        .tint(.white)
                                )
                        @unknown default:
                            backgroundGradient
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    }
                } else {
                    backgroundGradient
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }

                // Content (only show if there's text)
                if banner.title != nil || banner.subtitle != nil || banner.hasLink {
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            if let title = banner.title, !title.isEmpty {
                                Text(title)
                                    .font(.title3.weight(.bold))
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            }

                            if let subtitle = banner.subtitle, !subtitle.isEmpty {
                                Text(subtitle)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineLimit(2)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            }

                            // Link indicator
                            if banner.hasLink {
                                HStack(spacing: 4) {
                                    Text("home_learn_more".localized)
                                        .font(.caption.weight(.semibold))
                                    Image(systemName: "arrow.right")
                                        .font(.caption)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                            }
                        }

                        Spacer()
                    }
                    .padding(20)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [banner.color, banner.color.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Legacy Components (kept for compatibility)

struct CategoryTile: View {
    let category: Category
    @EnvironmentObject private var localizationManager: LocalizationManager

    var body: some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                    .fill(Color.primaryGreen.opacity(0.1))
                    .frame(height: 56)

                Image(systemName: category.sfSymbol)
                    .font(.system(size: 24))
                    .foregroundColor(.primaryGreen)
            }

            Text(category.localizedName(for: localizationManager.currentLanguage))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MoreCategoryTile: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                        .fill(Color(.systemGray5))
                        .frame(height: 56)

                    Image(systemName: "ellipsis")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Text(L10n.Common.more.localized)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct StoreGridCard: View {
    let store: Store

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                    .fill(Color.primaryGreen.opacity(0.1))
                    .frame(height: 100)

                Text(store.name.prefix(1))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryGreen)
            }

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                HStack(spacing: Spacing.xxs) {
                    Text(store.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    if store.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(.primaryGreen)
                    }
                }

                HStack(spacing: Spacing.xs) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.starYellow)

                        Text(String(format: "%.1f", store.avgRating))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(L10n.Home.reviewsCount.localized(with: store.reviewsCount))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, Spacing.xs)
            .padding(.bottom, Spacing.sm)
        }
        .background(Color(.systemBackground))
        .cornerRadius(Spacing.radiusMedium)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

// MARK: - All Categories Sheet

struct AllCategoriesSheet: View {
    let categories: [Category]
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager

    var body: some View {
        NavigationStack {
            ScrollView {
                let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(categories) { category in
                        ModernCategoryTile(category: category)
                    }
                }
                .padding(20)
            }
            .background(
                LinearGradient(
                    colors: [Color(.systemGray6), Color(.systemGray5).opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationTitle(L10n.Home.allCategories.localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Category.self) { category in
                CategoryStoresView(category: category)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Common.done.localized) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .environmentObject(LocalizationManager.shared)
}
