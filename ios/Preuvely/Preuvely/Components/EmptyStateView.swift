import SwiftUI
import Combine

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(Color(.systemGray3))

            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.primary)

                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                }
                .primaryButtonStyle()
                .padding(.horizontal, Spacing.xxxl)
            }

            Spacer()
        }
        .padding(Spacing.xl)
    }
}

// MARK: - Loading State View

struct LoadingStateView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.primaryGreen)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Error State View

struct ErrorStateView: View {
    let message: String
    var retryAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)

            Text(L10n.Common.oops.localized)
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)

            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if let retryAction = retryAction {
                Button(action: retryAction) {
                    Label(L10n.Common.tryAgain.localized, systemImage: "arrow.clockwise")
                }
                .secondaryButtonStyle()
                .padding(.horizontal, Spacing.xxxl)
            }

            Spacer()
        }
        .padding(Spacing.xl)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No stores found",
            message: "Try adjusting your search or filters",
            actionTitle: "Add This Store"
        ) {
            print("Action tapped")
        }
    }
}
