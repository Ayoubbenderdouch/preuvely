import SwiftUI
import Combine

struct MyStoresView: View {
    @StateObject private var viewModel = MyStoreViewModel()
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var selectedStore: Store?
    @State private var appearAnimation = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    loadingContent
                } else if viewModel.ownedStores.isEmpty {
                    emptyContent
                } else {
                    storeListContent
                }
            }
            .background(
                LinearGradient(
                    colors: [Color(.systemGray6), Color(.systemGray5).opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationTitle("my_stores_title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selectedStore) { store in
                EditStoreView(store: store, viewModel: viewModel)
            }
            .alert(L10n.Common.error.localized, isPresented: $viewModel.showError) {
                Button(L10n.Common.ok.localized, role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    appearAnimation = true
                }
            }
        }
        .task {
            await viewModel.fetchOwnedStores()
        }
    }

    // MARK: - Loading Content

    private var loadingContent: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.primaryGreen)

            Text(L10n.Common.loading.localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty Content

    private var emptyContent: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.primaryGreen.opacity(0.15), Color.primaryGreen.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: "storefront")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .offset(y: appearAnimation ? 0 : 20)
            .opacity(appearAnimation ? 1 : 0)

            VStack(spacing: Spacing.sm) {
                Text("my_stores_empty_title".localized)
                    .font(.title3.weight(.bold))
                    .foregroundColor(.primary)

                Text("my_stores_empty_message".localized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xxl)
            }
            .offset(y: appearAnimation ? 0 : 20)
            .opacity(appearAnimation ? 1 : 0)

            Spacer()
        }
        .padding(Spacing.xl)
    }

    // MARK: - Store List Content

    private var storeListContent: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: Spacing.md) {
                ForEach(viewModel.ownedStores) { store in
                    OwnedStoreCard(store: store.toStore()) {
                        selectedStore = store.toStore()
                    }
                    .offset(y: appearAnimation ? 0 : 20)
                    .opacity(appearAnimation ? 1 : 0)
                }
            }
            .padding(.horizontal, Spacing.screenPadding)
            .padding(.top, Spacing.md)
            .padding(.bottom, 100)
        }
        .refreshable {
            await viewModel.fetchOwnedStores()
        }
    }
}

// MARK: - Owned Store Card

struct OwnedStoreCard: View {
    let store: Store
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                // Store Logo
                storeLogoView

                // Store Info
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    // Name and verified badge
                    HStack(spacing: Spacing.xs) {
                        Text(store.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)

                        if store.isVerified {
                            VerifiedBadge()
                        }

                        Spacer()
                    }

                    // Rating
                    HStack(spacing: Spacing.xs) {
                        RatingDisplay(rating: store.avgRating, size: .small)

                        Text("(\(store.reviewsCount))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // City
                    if let city = store.city {
                        Label(city, systemImage: "mappin")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Chevron
                ZStack {
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 32, height: 32)

                    Image(systemName: "chevron.forward")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primaryGreen)
                }
            }
            .padding(Spacing.cardPadding)
            .background(Color(.systemBackground))
            .cornerRadius(Spacing.radiusLarge)
            .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Store Logo View

    @ViewBuilder
    private var storeLogoView: some View {
        if let logoURL = store.logo, let url = URL(string: logoURL) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure, .empty:
                    logoPlaceholder
                @unknown default:
                    logoPlaceholder
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            logoPlaceholder
        }
    }

    private var logoPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color.primaryGreen.opacity(0.15), Color.primaryGreen.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text(store.name.prefix(1).uppercased())
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primaryGreen)
        }
        .frame(width: 60, height: 60)
    }
}

// MARK: - Preview

#Preview {
    MyStoresView()
        .environmentObject(LocalizationManager.shared)
}
