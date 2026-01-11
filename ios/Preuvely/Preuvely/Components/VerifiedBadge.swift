import SwiftUI
import Combine

enum BadgeSize {
    case small
    case medium
    case large

    var iconSize: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 16
        case .large: return 20
        }
    }
}

struct VerifiedBadge: View {
    var size: BadgeSize = .medium

    var body: some View {
        Image(systemName: "checkmark.seal.fill")
            .font(.system(size: size.iconSize))
            .foregroundColor(.primaryGreen)
            .accessibilityLabel(Text("Verified"))
    }
}

// MARK: - Proof Badge

struct ProofBadge: View {
    var size: BadgeSize = .medium

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: size.iconSize - 2))

            if size != .small {
                Text("Proof")
                    .font(.caption2.weight(.medium))
            }
        }
        .foregroundColor(.primaryGreen)
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, 2)
        .background(Color.primaryGreen.opacity(0.1))
        .cornerRadius(Spacing.radiusSmall)
        .accessibilityLabel(Text("Has verified proof"))
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: String
    let color: Color

    init(status: String, color: Color) {
        self.status = status
        self.color = color
    }

    init(claimStatus: ClaimStatus) {
        self.status = claimStatus.displayName
        switch claimStatus {
        case .pending: self.color = .orange
        case .approved: self.color = .green
        case .rejected: self.color = .red
        }
    }

    init(proofStatus: ProofStatus) {
        self.status = proofStatus.displayName
        switch proofStatus {
        case .pending: self.color = .orange
        case .approved: self.color = .green
        case .rejected: self.color = .red
        }
    }

    var body: some View {
        Text(status)
            .font(.caption.weight(.medium))
            .foregroundColor(color)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xxs)
            .background(color.opacity(0.1))
            .cornerRadius(Spacing.radiusSmall)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            VerifiedBadge(size: .small)
            VerifiedBadge(size: .medium)
            VerifiedBadge(size: .large)
        }

        HStack(spacing: 20) {
            ProofBadge(size: .small)
            ProofBadge(size: .medium)
        }

        HStack(spacing: 10) {
            StatusBadge(claimStatus: .pending)
            StatusBadge(claimStatus: .approved)
            StatusBadge(claimStatus: .rejected)
        }
    }
    .padding()
}
