import SwiftUI
import Combine

struct StoreCard: View {
    let store: Store
    var isCompact: Bool = false

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Store Logo
            storeLogoView

            // Store Info
            VStack(alignment: .leading, spacing: Spacing.sm) {
                // Header with name and verified badge
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

                // Description (only in non-compact mode)
                if !isCompact, let description = store.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                // Platform badges
                HStack(spacing: Spacing.xs) {
                    ForEach(store.platformBadges, id: \.self) { platform in
                        PlatformBadge(platform: platform)
                    }

                    Spacer()
                }

                // Category chips
                if !isCompact && !store.categories.isEmpty {
                    HStack(spacing: Spacing.xs) {
                        ForEach(store.categories.prefix(2)) { category in
                            CategoryChip(category: category)
                        }
                    }
                }

                // Rating and reviews
                HStack(spacing: Spacing.md) {
                    RatingDisplay(rating: store.avgRating)

                    Text("\(store.formattedReviewsCount) reviews")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let city = store.city {
                        Spacer()
                        Label(city, systemImage: "mappin")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(Spacing.cardPadding)
        .background(Color(.systemBackground))
        .cornerRadius(Spacing.radiusMedium)
        .shadow(
            color: .black.opacity(0.06),
            radius: 8,
            x: 0,
            y: 2
        )
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

// MARK: - Compact Store Card (for horizontal scroll)

struct CompactStoreCard: View {
    let store: Store

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Store Logo
            compactLogoView

            // Header
            HStack(spacing: Spacing.xs) {
                Text(store.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                if store.isVerified {
                    VerifiedBadge(size: .small)
                }
            }

            // Platforms
            HStack(spacing: Spacing.xxs) {
                ForEach(store.platformBadges.prefix(3), id: \.self) { platform in
                    PlatformBadge(platform: platform, size: .small)
                }
            }

            // Rating
            HStack(spacing: Spacing.xs) {
                RatingDisplay(rating: store.avgRating, size: .small)

                Text("(\(store.reviewsCount))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(Spacing.md)
        .frame(width: 160)
        .background(Color(.systemBackground))
        .cornerRadius(Spacing.radiusMedium)
        .shadow(
            color: .black.opacity(0.06),
            radius: 6,
            x: 0,
            y: 2
        )
    }

    // MARK: - Compact Logo View

    @ViewBuilder
    private var compactLogoView: some View {
        if let logoURL = store.logo, let url = URL(string: logoURL) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure, .empty:
                    compactLogoPlaceholder
                @unknown default:
                    compactLogoPlaceholder
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            compactLogoPlaceholder
        }
    }

    private var compactLogoPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [Color.primaryGreen.opacity(0.15), Color.primaryGreen.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text(store.name.prefix(1).uppercased())
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primaryGreen)
        }
        .frame(width: 50, height: 50)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: Spacing.lg) {
            StoreCard(store: Store.sample)

            StoreCard(store: Store.sample, isCompact: true)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    CompactStoreCard(store: Store.sample)
                    CompactStoreCard(store: Store.sample)
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }
    .background(Color(.secondarySystemBackground))
}
