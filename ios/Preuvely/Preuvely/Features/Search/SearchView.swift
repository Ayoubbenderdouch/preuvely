import SwiftUI
import Combine

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var showFilters = false
    @State private var showAddStore = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isPresented) private var isPresented
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // MARK: - iPad Layout Constants

    /// Maximum content width for iPad to prevent overly wide content
    private var maxContentWidth: CGFloat {
        horizontalSizeClass == .regular ? 900 : .infinity
    }

    /// Maximum search bar width for iPad
    private var maxSearchBarWidth: CGFloat {
        horizontalSizeClass == .regular ? 700 : .infinity
    }

    /// Number of grid columns based on device
    private var gridColumns: [GridItem] {
        if horizontalSizeClass == .regular {
            // iPad: 3-4 columns depending on orientation
            return Array(repeating: GridItem(.flexible(), spacing: Spacing.md), count: 3)
        } else {
            // iPhone: Single column (list view)
            return [GridItem(.flexible())]
        }
    }

    /// Horizontal padding for centering content on iPad
    private var contentPadding: CGFloat {
        horizontalSizeClass == .regular ? Spacing.xl : Spacing.screenPadding
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchBarSection

                // Filter chips
                filterChipsSection

                // Results
                if viewModel.isLoading && viewModel.stores.isEmpty {
                    LoadingStateView(message: L10n.Search.searching.localized)
                } else if viewModel.stores.isEmpty && !viewModel.searchQuery.isEmpty {
                    emptyStateView
                } else if viewModel.stores.isEmpty {
                    initialStateView
                } else {
                    resultsListView
                }
            }
            .background(Color(.secondarySystemBackground))
            .navigationDestination(for: Store.self) { store in
                StoreDetailsView(store: store)
            }
            .sheet(isPresented: $showFilters) {
                SearchFiltersSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showAddStore) {
                NavigationStack {
                    AddStoreView(prefillName: viewModel.searchQuery)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button(L10n.Common.cancel.localized) {
                                    showAddStore = false
                                }
                            }
                        }
                }
            }
        }
    }

    // MARK: - Search Bar Section

    private var searchBarSection: some View {
        HStack(spacing: Spacing.sm) {
            // Close button (when presented as modal)
            if isPresented {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.body.weight(.medium))
                        .foregroundColor(.primary)
                        .frame(width: 36, height: 36)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
            }

            SearchBar(
                text: $viewModel.searchQuery,
                placeholder: L10n.Search.placeholder.localized
            ) {
                Task {
                    await viewModel.search()
                }
            }

            Button {
                showFilters = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.body)
                    .foregroundColor(viewModel.hasActiveFilters ? .white : .primaryGreen)
                    .frame(width: 44, height: 44)
                    .background(viewModel.hasActiveFilters ? Color.primaryGreen : Color(.secondarySystemBackground))
                    .cornerRadius(Spacing.radiusMedium)
            }
        }
        .frame(maxWidth: maxSearchBarWidth)
        .padding(.horizontal, contentPadding)
        .padding(.vertical, Spacing.md)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }

    // MARK: - Filter Chips

    private var filterChipsSection: some View {
        Group {
            if viewModel.hasActiveFilters {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        if let category = viewModel.selectedCategory {
                            FilterChip(
                                label: category.name,
                                icon: "tag.fill"
                            ) {
                                viewModel.selectedCategory = nil
                                Task { await viewModel.search() }
                            }
                        }

                        if viewModel.verifiedOnly {
                            FilterChip(
                                label: L10n.Common.verified.localized,
                                icon: "checkmark.seal.fill"
                            ) {
                                viewModel.verifiedOnly = false
                                Task { await viewModel.search() }
                            }
                        }

                        FilterChip(
                            label: viewModel.sortOption.displayName,
                            icon: "arrow.up.arrow.down"
                        ) {
                            showFilters = true
                        }
                    }
                    .frame(maxWidth: maxContentWidth, alignment: .leading)
                    .padding(.horizontal, contentPadding)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
                .background(Color(.systemBackground))
            }
        }
    }

    // MARK: - Results List

    private var resultsListView: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: Spacing.md) {
                ForEach(viewModel.stores) { store in
                    NavigationLink(value: store) {
                        StoreCard(store: store, isCompact: horizontalSizeClass == .regular)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: maxContentWidth)
            .padding(.horizontal, contentPadding)
            .padding(.vertical, Spacing.screenPadding)
            .frame(maxWidth: .infinity)

            if viewModel.isLoading {
                ProgressView()
                    .padding()
            }
        }
        .refreshable {
            await viewModel.search()
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        EmptyStateView(
            icon: "magnifyingglass",
            title: L10n.Search.noStoreFound.localized,
            message: L10n.Search.adjustSearchOrAdd.localized,
            actionTitle: L10n.Search.addThisStore.localized
        ) {
            showAddStore = true
        }
    }

    // MARK: - Initial State

    private var initialStateView: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                Spacer(minLength: Spacing.xl)

                Image(systemName: "magnifyingglass")
                    .font(.system(size: horizontalSizeClass == .regular ? 60 : 50))
                    .foregroundColor(Color(.systemGray3))

                Text(L10n.Search.searchForStores.localized)
                    .font(horizontalSizeClass == .regular ? .title2 : .title3)
                    .foregroundColor(.secondary)

                Text(L10n.Search.findStoresByName.localized)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, contentPadding)

                // Search Hints Section
                searchHintsSection

                Spacer(minLength: Spacing.xl)
            }
            .frame(maxWidth: maxContentWidth)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Search Hints Section

    private var searchHintsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(L10n.Search.hintTitle.localized)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, contentPadding)

            // Wrapping flow layout for chips
            FlowLayout(spacing: Spacing.sm) {
                SearchHintChip(icon: "storefront.fill", label: L10n.Search.hintName.localized) {
                    viewModel.searchQuery = ""
                }

                PlatformSearchHintChip(platform: .tiktok, label: L10n.Search.hintTikTok.localized) {
                    viewModel.searchQuery = "@"
                }

                PlatformSearchHintChip(platform: .instagram, label: L10n.Search.hintInstagram.localized) {
                    viewModel.searchQuery = "@"
                }

                PlatformSearchHintChip(platform: .facebook, label: L10n.Search.hintFacebook.localized) {
                    viewModel.searchQuery = ""
                }

                PlatformSearchHintChip(platform: .whatsapp, label: L10n.Search.hintWhatsApp.localized) {
                    viewModel.searchQuery = "+213"
                }

                SearchHintChip(icon: "phone.fill", label: L10n.Search.hintPhone.localized) {
                    viewModel.searchQuery = "0"
                }

                SearchHintChip(icon: "link", label: L10n.Search.hintLink.localized) {
                    viewModel.searchQuery = "https://"
                }
            }
            .padding(.horizontal, contentPadding)
        }
        .padding(.top, Spacing.lg)
    }
}

// MARK: - Platform Search Hint Chip (with brand images)

struct PlatformSearchHintChip: View {
    enum Platform: String {
        case tiktok
        case instagram
        case facebook
        case whatsapp

        /// Asset image name in Assets.xcassets
        var imageName: String {
            switch self {
            case .tiktok: return "Tiktok"
            case .instagram: return "Instagram"
            case .facebook: return "facebook"
            case .whatsapp: return "Whatsapp"
            }
        }
    }

    let platform: Platform
    let label: String
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: Spacing.xs) {
                // Platform icon from assets
                Image(platform.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)

                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.primary)
            }
            .padding(.leading, Spacing.sm)
            .padding(.trailing, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(Color(.systemBackground))
            .cornerRadius(Spacing.radiusRound)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.radiusRound)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Search Hint Chip

struct SearchHintChip: View {
    let icon: String
    let label: String
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.primaryGreen)

                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(Color(.systemBackground))
            .cornerRadius(Spacing.radiusRound)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.radiusRound)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)

        for (index, subview) in subviews.enumerated() {
            let point = result.positions[index]
            subview.place(at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y), proposal: .unspecified)
        }
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxWidth: CGFloat = 0

        let containerWidth = proposal.width ?? .infinity

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > containerWidth && currentX > 0 {
                // Move to next line
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxWidth = max(maxWidth, currentX - spacing)
        }

        return (CGSize(width: maxWidth, height: currentY + lineHeight), positions)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let label: String
    var icon: String? = nil
    var onRemove: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: Spacing.xs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption)
            }

            Text(label)
                .font(.caption.weight(.medium))

            if onRemove != nil {
                Button {
                    onRemove?()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption2.weight(.bold))
                }
            }
        }
        .foregroundColor(.primaryGreen)
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs)
        .background(Color.primaryGreen.opacity(0.1))
        .cornerRadius(Spacing.radiusRound)
    }
}

// MARK: - Search Filters Sheet

struct SearchFiltersSheet: View {
    @ObservedObject var viewModel: SearchViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var showCategoryPicker = false

    /// Maximum content width for iPad filters sheet
    private var maxSheetContentWidth: CGFloat {
        horizontalSizeClass == .regular ? 600 : .infinity
    }

    /// Number of category columns based on device
    private var categoryColumns: [GridItem] {
        if horizontalSizeClass == .regular {
            return Array(repeating: GridItem(.flexible()), count: 4)
        } else {
            return Array(repeating: GridItem(.flexible()), count: 3)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Category Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.grid.2x2.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primaryGreen)

                            Text(L10n.Search.category.localized)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.primary)
                        }

                        // Category Grid
                        LazyVGrid(columns: categoryColumns, spacing: 10) {
                            // All Categories Option
                            FilterCategoryButton(
                                icon: "square.grid.2x2",
                                name: L10n.Common.all.localized,
                                color: .gray,
                                isSelected: viewModel.selectedCategory == nil
                            ) {
                                viewModel.selectedCategory = nil
                            }

                            ForEach(Category.samples) { category in
                                FilterCategoryButton(
                                    icon: category.sfSymbol,
                                    name: category.localizedName(for: localizationManager.currentLanguage),
                                    color: categoryColor(for: category),
                                    isSelected: viewModel.selectedCategory == category
                                ) {
                                    viewModel.selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)

                    // Verified Only Section
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color.primaryGreen.opacity(0.15))
                                .frame(width: 44, height: 44)

                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.primaryGreen)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(L10n.Search.verifiedOnly.localized)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.primary)

                            Text("search_verified_only_desc".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Toggle("", isOn: $viewModel.verifiedOnly)
                            .tint(.primaryGreen)
                            .labelsHidden()
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)

                    // Sort Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primaryGreen)

                            Text(L10n.Search.sortBy.localized)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.primary)
                        }

                        VStack(spacing: 8) {
                            ForEach(StoreSortOption.allCases) { option in
                                SortOptionRow(
                                    option: option,
                                    isSelected: viewModel.sortOption == option
                                ) {
                                    viewModel.sortOption = option
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                }
                .frame(maxWidth: maxSheetContentWidth)
                .padding(20)
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemGray6))
            .navigationTitle(L10n.Search.filters.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.reset.localized) {
                        viewModel.resetFilters()
                    }
                    .foregroundColor(.red)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Common.apply.localized) {
                        Task {
                            await viewModel.search()
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryGreen)
                }
            }
        }
        .presentationDetents([.large])
    }

    private func categoryColor(for category: Category) -> Color {
        switch category.slug {
        case "fashion": return .pink
        case "electronics": return .blue
        case "beauty": return .purple
        case "food": return .orange
        case "home": return .green
        case "sports": return .red
        case "kids": return .cyan
        default: return .primaryGreen
        }
    }
}

// MARK: - Filter Category Button

struct FilterCategoryButton: View {
    let icon: String
    let name: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            isSelected
                                ? color.opacity(0.2)
                                : Color(.systemGray6)
                        )
                        .frame(height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? color : Color.clear, lineWidth: 2)
                        )

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isSelected ? color : .secondary)
                }

                Text(name)
                    .font(.caption2.weight(.medium))
                    .foregroundColor(isSelected ? color : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Sort Option Row

struct SortOptionRow: View {
    let option: StoreSortOption
    let isSelected: Bool
    let action: () -> Void

    private var icon: String {
        switch option {
        case .bestRated: return "star.fill"
        case .mostReviewed: return "text.bubble.fill"
        case .newest: return "clock.fill"
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .primaryGreen : .secondary)
                    .frame(width: 24)

                Text(option.displayName)
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.primaryGreen)
                } else {
                    Circle()
                        .stroke(Color(.systemGray4), lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.primaryGreen.opacity(0.08) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.primaryGreen.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    SearchView()
        .environmentObject(LocalizationManager.shared)
}
