import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var notificationViewModel = NotificationViewModel()
    @EnvironmentObject private var localizationManager: LocalizationManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var searchText = ""
    @State private var showSearch = false
    @State private var showAllCategories = false
    @State private var showNotifications = false
    @State private var appearAnimation = false

    /// Check if we're on iPad (regular size class)
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }

    /// Dynamic spacing between sections
    private var sectionSpacing: CGFloat {
        iPadLayout.sectionSpacing(for: horizontalSizeClass)
    }

    /// Dynamic horizontal padding
    private var horizontalPadding: CGFloat {
        iPadLayout.horizontalPadding(for: horizontalSizeClass)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: sectionSpacing) {
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
                .frame(maxWidth: isIPad ? iPadLayout.maxWideContentWidth : .infinity)
                .frame(maxWidth: .infinity) // Center on iPad
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
            HStack(spacing: isIPad ? 16 : 12) {
                // App Logo - Bigger on iPad
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: isIPad ? 60 : 52, height: isIPad ? 60 : 52)
                    .cornerRadius(isIPad ? 16 : 14)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

                // Search Field
                Button {
                    showSearch = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: isIPad ? 18 : 16, weight: .medium))
                            .foregroundColor(Color(.systemGray2))

                        Text(L10n.Home.searchPlaceholder.localized)
                            .font(isIPad ? .body : .subheadline)
                            .foregroundColor(Color(.systemGray2))

                        Spacer()
                    }
                    .padding(.horizontal, isIPad ? 18 : 14)
                    .padding(.vertical, isIPad ? 14 : 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(isIPad ? 16 : 14)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: isIPad ? 500 : .infinity)

                // Notification Icon
                Button {
                    showNotifications = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: isIPad ? 52 : 44, height: isIPad ? 52 : 44)

                        Image(systemName: "bell.fill")
                            .font(.system(size: isIPad ? 22 : 18))
                            .foregroundColor(.primary)

                        // Notification badge (only show if unread)
                        if notificationViewModel.hasUnreadNotifications {
                            Circle()
                                .fill(Color.red)
                                .frame(width: isIPad ? 12 : 10, height: isIPad ? 12 : 10)
                                .offset(x: isIPad ? 12 : 10, y: isIPad ? -12 : -10)
                        }
                    }
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, isIPad ? 16 : 12)
            .frame(maxWidth: isIPad ? iPadLayout.maxWideContentWidth : .infinity)
            .frame(maxWidth: .infinity) // Center on iPad
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
        let columnCount = iPadLayout.categoryGridColumns(for: horizontalSizeClass)
        let gridSpacing = iPadLayout.gridSpacing(for: horizontalSizeClass)
        let categoryLimit = isIPad ? 12 : 8 // Show more categories on iPad

        return VStack(spacing: isIPad ? 20 : 16) {
            // Section Header
            HStack {
                HStack(spacing: isIPad ? 10 : 8) {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: isIPad ? 16 : 14, weight: .semibold))
                        .foregroundColor(.primaryGreen)

                    Text(L10n.Home.categories.localized)
                        .font(isIPad ? .title3.weight(.semibold) : .headline)
                        .foregroundColor(.primary)
                }

                Spacer()

                Button {
                    showAllCategories = true
                } label: {
                    HStack(spacing: 4) {
                        Text(L10n.Common.seeAll.localized)
                        Image(systemName: "chevron.right")
                            .font(.system(size: isIPad ? 12 : 10, weight: .bold))
                    }
                    .font(isIPad ? .body.weight(.medium) : .subheadline.weight(.medium))
                    .foregroundColor(.primaryGreen)
                }
            }
            .padding(.horizontal, horizontalPadding)

            // Categories Grid - More columns on iPad
            let columns = Array(repeating: GridItem(.flexible(), spacing: gridSpacing), count: columnCount)

            LazyVGrid(columns: columns, spacing: gridSpacing) {
                ForEach(viewModel.categories.filter { $0.shouldShowOnHome }.prefix(categoryLimit)) { category in
                    ModernCategoryTile(category: category)
                }
            }
            .padding(.horizontal, horizontalPadding)
        }
    }

    // MARK: - Top Reviewed Section

    private var topReviewedSection: some View {
        let columnCount = iPadLayout.storeGridColumns(for: horizontalSizeClass)
        let gridSpacing = iPadLayout.gridSpacing(for: horizontalSizeClass)

        return VStack(spacing: isIPad ? 20 : 16) {
            // Section Header
            HStack {
                HStack(spacing: isIPad ? 10 : 8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: isIPad ? 16 : 14, weight: .semibold))
                        .foregroundColor(.starYellow)

                    Text(L10n.Home.topReviewed.localized)
                        .font(isIPad ? .title3.weight(.semibold) : .headline)
                        .foregroundColor(.primary)
                }

                Spacer()

                Button {
                    showSearch = true
                } label: {
                    HStack(spacing: 4) {
                        Text(L10n.Common.seeAll.localized)
                        Image(systemName: "chevron.right")
                            .font(.system(size: isIPad ? 12 : 10, weight: .bold))
                    }
                    .font(isIPad ? .body.weight(.medium) : .subheadline.weight(.medium))
                    .foregroundColor(.primaryGreen)
                }
            }
            .padding(.horizontal, horizontalPadding)

            // Store Cards Grid - More columns on iPad
            let columns = Array(repeating: GridItem(.flexible(), spacing: gridSpacing), count: columnCount)

            LazyVGrid(columns: columns, spacing: gridSpacing) {
                ForEach(viewModel.topRatedStores) { store in
                    NavigationLink(value: store) {
                        ModernStoreCard(store: store)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, horizontalPadding)
        }
    }
}

// MARK: - Modern Category Tile

struct ModernCategoryTile: View {
    let category: Category
    @EnvironmentObject private var localizationManager: LocalizationManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var isPressed = false

    /// Check if we're on iPad
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }

    /// Dynamic image size based on device
    private var imageSize: CGFloat {
        isIPad ? 80 : 65
    }

    /// Dynamic icon size for fallback
    private var iconSize: CGFloat {
        isIPad ? 54 : 44
    }

    var body: some View {
        NavigationLink(value: category) {
            VStack(spacing: isIPad ? 8 : 6) {
                // Category image - no background
                if UIImage(named: category.localImageName) != nil {
                    Image(category.localImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: imageSize, height: imageSize)
                } else {
                    Image(systemName: category.sfSymbol)
                        .font(.system(size: iconSize, weight: .medium))
                        .foregroundColor(.primaryGreen)
                        .frame(width: imageSize, height: imageSize)
                }

                Text(category.localizedName(for: localizationManager.currentLanguage))
                    .font(isIPad ? .subheadline.weight(.medium) : .caption.weight(.medium))
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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// Check if we're on iPad
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }

    /// Dynamic image height based on device
    private var imageHeight: CGFloat {
        isIPad ? 160 : 120
    }

    /// Dynamic padding based on device
    private var cardPadding: CGFloat {
        isIPad ? 16 : 12
    }

    /// Dynamic placeholder font size
    private var placeholderFontSize: CGFloat {
        isIPad ? 52 : 40
    }

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
            .frame(height: imageHeight)
            .clipped()

            // Store Info
            VStack(alignment: .leading, spacing: isIPad ? 8 : 6) {
                // Store name with verified badge
                HStack(spacing: isIPad ? 6 : 4) {
                    Text(store.name)
                        .font(isIPad ? .body.weight(.semibold) : .subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    if store.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: isIPad ? 14 : 12))
                            .foregroundColor(.primaryGreen)
                    }
                }

                // Rating & Reviews
                HStack(spacing: isIPad ? 8 : 6) {
                    HStack(spacing: isIPad ? 4 : 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: isIPad ? 13 : 11))
                            .foregroundColor(.starYellow)

                        Text(String(format: "%.1f", store.avgRating))
                            .font(isIPad ? .subheadline.weight(.medium) : .caption.weight(.medium))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, isIPad ? 10 : 8)
                    .padding(.vertical, isIPad ? 6 : 4)
                    .background(Color.starYellow.opacity(0.15))
                    .cornerRadius(isIPad ? 10 : 8)

                    Text("\(store.reviewsCount) reviews")
                        .font(isIPad ? .subheadline : .caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(cardPadding)
        }
        .background(Color(.systemBackground))
        .cornerRadius(isIPad ? 22 : 18)
        .shadow(color: .black.opacity(0.06), radius: isIPad ? 16 : 12, x: 0, y: isIPad ? 6 : 4)
    }

    private var placeholderView: some View {
        ZStack {
            LinearGradient(
                colors: [Color.primaryGreen.opacity(0.15), Color.primaryGreen.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Text(store.name.prefix(1).uppercased())
                .font(.system(size: placeholderFontSize, weight: .bold, design: .rounded))
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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var currentPage = 0

    /// Check if we're on iPad
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }

    /// Dynamic banner height based on device
    private var bannerHeight: CGFloat {
        iPadLayout.bannerHeight(for: horizontalSizeClass)
    }

    /// Dynamic horizontal padding
    private var horizontalPadding: CGFloat {
        iPadLayout.horizontalPadding(for: horizontalSizeClass)
    }

    /// Dynamic corner radius
    private var cornerRadius: CGFloat {
        isIPad ? 24 : 20
    }

    var body: some View {
        VStack(spacing: isIPad ? 16 : 12) {
            if banners.isEmpty {
                // Placeholder when loading
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemGray5))
                    .frame(height: bannerHeight)
                    .padding(.horizontal, horizontalPadding)
                    .shimmer()
            } else {
                TabView(selection: $currentPage) {
                    ForEach(Array(banners.enumerated()), id: \.element.id) { index, banner in
                        BannerCard(banner: banner)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: bannerHeight)
                .cornerRadius(cornerRadius)
                .padding(.horizontal, horizontalPadding)

                // Page indicators - larger on iPad
                HStack(spacing: isIPad ? 8 : 6) {
                    ForEach(0..<banners.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? Color.primaryGreen : Color(.systemGray4))
                            .frame(width: index == currentPage ? (isIPad ? 28 : 20) : (isIPad ? 8 : 6), height: isIPad ? 8 : 6)
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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// Check if we're on iPad
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }

    /// Dynamic corner radius
    private var cornerRadius: CGFloat {
        isIPad ? 24 : 20
    }

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
                    HStack(spacing: isIPad ? 20 : 16) {
                        VStack(alignment: .leading, spacing: isIPad ? 12 : 8) {
                            if let title = banner.title, !title.isEmpty {
                                Text(title)
                                    .font(isIPad ? .title2.weight(.bold) : .title3.weight(.bold))
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            }

                            if let subtitle = banner.subtitle, !subtitle.isEmpty {
                                Text(subtitle)
                                    .font(isIPad ? .body : .subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineLimit(2)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            }

                            // Link indicator
                            if banner.hasLink {
                                HStack(spacing: isIPad ? 6 : 4) {
                                    Text("home_learn_more".localized)
                                        .font(isIPad ? .subheadline.weight(.semibold) : .caption.weight(.semibold))
                                    Image(systemName: "arrow.right")
                                        .font(isIPad ? .subheadline : .caption)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, isIPad ? 16 : 12)
                                .padding(.vertical, isIPad ? 8 : 6)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(isIPad ? 14 : 12)
                            }
                        }

                        Spacer()
                    }
                    .padding(isIPad ? 28 : 20)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var localizationManager: LocalizationManager

    /// Check if we're on iPad
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }

    /// Dynamic column count
    private var columnCount: Int {
        iPadLayout.allCategoriesColumns(for: horizontalSizeClass)
    }

    /// Dynamic grid spacing
    private var gridSpacing: CGFloat {
        iPadLayout.gridSpacing(for: horizontalSizeClass)
    }

    /// Dynamic horizontal padding
    private var horizontalPadding: CGFloat {
        iPadLayout.horizontalPadding(for: horizontalSizeClass)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                let columns = Array(repeating: GridItem(.flexible(), spacing: gridSpacing), count: columnCount)

                LazyVGrid(columns: columns, spacing: isIPad ? 24 : 16) {
                    ForEach(categories) { category in
                        ModernCategoryTile(category: category)
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, isIPad ? 28 : 20)
                .frame(maxWidth: isIPad ? iPadLayout.maxWideContentWidth : .infinity)
                .frame(maxWidth: .infinity) // Center on iPad
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
                    .font(isIPad ? .body.weight(.semibold) : .body)
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
