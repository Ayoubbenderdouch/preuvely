import SwiftUI
import Combine

// MARK: - Rating Display

struct RatingDisplay: View {
    let rating: Double
    var size: BadgeSize = .medium
    var showValue: Bool = true

    private var starSize: CGFloat {
        switch size {
        case .small: return 12
        case .medium: return 14
        case .large: return 18
        }
    }

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "star.fill")
                .font(.system(size: starSize))
                .foregroundColor(.starYellow)

            if showValue {
                Text(String(format: "%.1f", rating))
                    .font(size == .small ? .caption2 : .caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
        }
        .accessibilityLabel(Text("\(String(format: "%.1f", rating)) stars"))
    }
}

// MARK: - Star Rating Selector

struct StarRatingSelector: View {
    @Binding var rating: Int
    var maxRating: Int = 5
    var size: CGFloat = 36

    var body: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(1...maxRating, id: \.self) { star in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        rating = star
                    }
                } label: {
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .font(.system(size: size))
                        .foregroundColor(star <= rating ? .starYellow : Color(.systemGray4))
                        .scaleEffect(star == rating ? 1.1 : 1.0)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("\(star) star\(star > 1 ? "s" : "")"))
            }
        }
    }
}

// MARK: - Rating Breakdown View

struct RatingBreakdownView: View {
    let breakdown: RatingBreakdown
    let avgRating: Double
    let totalReviews: Int

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.xl) {
            // Average rating display
            VStack(spacing: Spacing.xs) {
                Text(String(format: "%.1f", avgRating))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= Int(avgRating.rounded()) ? "star.fill" : "star")
                            .font(.system(size: 14))
                            .foregroundColor(.starYellow)
                    }
                }

                Text("\(totalReviews) reviews")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Breakdown bars
            VStack(spacing: Spacing.xs) {
                ForEach((1...5).reversed(), id: \.self) { stars in
                    RatingBreakdownRow(
                        stars: stars,
                        count: countForStars(stars),
                        percentage: breakdown.percentage(for: stars)
                    )
                }
            }
        }
        .padding(Spacing.lg)
        .background(Color(.systemBackground))
        .cornerRadius(Spacing.radiusMedium)
    }

    private func countForStars(_ stars: Int) -> Int {
        switch stars {
        case 1: return breakdown.one
        case 2: return breakdown.two
        case 3: return breakdown.three
        case 4: return breakdown.four
        case 5: return breakdown.five
        default: return 0
        }
    }
}

// MARK: - Rating Breakdown Row

struct RatingBreakdownRow: View {
    let stars: Int
    let count: Int
    let percentage: Double

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Text("\(stars)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 12)

            Image(systemName: "star.fill")
                .font(.system(size: 10))
                .foregroundColor(.starYellow)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.primaryGreen)
                        .frame(width: geometry.size.width * percentage, height: 8)
                }
            }
            .frame(height: 8)

            Text("\(count)")
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 30) {
        HStack(spacing: 20) {
            RatingDisplay(rating: 4.5, size: .small)
            RatingDisplay(rating: 4.5, size: .medium)
            RatingDisplay(rating: 4.5, size: .large)
        }

        StarRatingSelector(rating: .constant(4))

        RatingBreakdownView(
            breakdown: RatingBreakdown(one: 5, two: 8, three: 21, four: 78, five: 122),
            avgRating: 4.7,
            totalReviews: 234
        )
    }
    .padding()
    .background(Color(.secondarySystemBackground))
}
