import SwiftUI
import Combine

struct ReviewCard: View {
    let review: Review
    var showUserLink: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            HStack(alignment: .top) {
                // User avatar and name - tappable to view profile
                if showUserLink {
                    NavigationLink {
                        UserProfileView(reviewUser: review.user)
                    } label: {
                        reviewerHeader
                    }
                    .buttonStyle(.plain)
                } else {
                    reviewerHeader
                }

                Spacer()

                // Stars
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= review.stars ? "star.fill" : "star")
                            .font(.system(size: 12))
                            .foregroundColor(star <= review.stars ? .starYellow : Color(.systemGray4))
                    }
                }
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
                    StatusBadge(status: "Proof Pending", color: .orange)
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

    // MARK: - Reviewer Header

    private var reviewerHeader: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            // User avatar
            userAvatarView

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: Spacing.xs) {
                    Text(review.userName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)

                    if showUserLink {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                }

                Text(review.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - User Avatar View

    @ViewBuilder
    private var userAvatarView: some View {
        if let avatarURL = review.userAvatar, !avatarURL.isEmpty {
            // Use CachedAvatarImage which handles both base64 data URLs and regular HTTP URLs
            CachedAvatarImage(urlString: avatarURL, size: 40)
        } else {
            avatarFallback
        }
    }

    private var avatarFallback: some View {
        ZStack {
            Circle()
                .fill(Color.primaryGreen.opacity(0.1))
                .frame(width: 40, height: 40)

            Text(review.userName.prefix(1).uppercased())
                .font(.headline)
                .foregroundColor(.primaryGreen)
        }
    }
}

// MARK: - Merchant Reply View

struct MerchantReplyView: View {
    let reply: StoreReply

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Divider()

            HStack(spacing: Spacing.xs) {
                Image(systemName: "arrowshape.turn.up.left.fill")
                    .font(.caption)
                    .foregroundColor(.primaryGreen)

                Text(reply.userName)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.primaryGreen)

                VerifiedBadge(size: .small)

                Spacer()

                if let date = reply.createdAt {
                    Text(RelativeDateTimeFormatter().localizedString(for: date, relativeTo: Date()))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Text(reply.replyText)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.leading, Spacing.lg)
        }
        .padding(.top, Spacing.sm)
    }
}

// MARK: - Review Skeleton (Loading)

struct ReviewCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(width: 100, height: 14)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(width: 60, height: 10)
                }

                Spacer()

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 70, height: 14)
            }

            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(height: 14)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 200, height: 14)
            }
        }
        .padding(Spacing.cardPadding)
        .background(Color(.systemBackground))
        .cornerRadius(Spacing.radiusMedium)
        .shimmer()
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: Spacing.md) {
            ReviewCard(review: Review.samples[0])
            ReviewCard(review: Review.samples[2])
            ReviewCardSkeleton()
        }
        .padding()
    }
    .background(Color(.secondarySystemBackground))
}
