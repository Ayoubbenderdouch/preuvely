import SwiftUI
import Combine

struct NotificationView: View {
    @StateObject private var viewModel = NotificationViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var appearAnimation = false

    /// Maximum content width for iPad
    private var maxContentWidth: CGFloat {
        horizontalSizeClass == .regular ? 700 : .infinity
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(.systemGray6), Color(.systemGray5).opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                if viewModel.isLoading && viewModel.notifications.isEmpty {
                    LoadingStateView(message: L10n.Common.loading.localized)
                } else if viewModel.notifications.isEmpty {
                    emptyStateView
                } else {
                    notificationsList
                }
            }
            .frame(maxWidth: .infinity)
            .navigationTitle(L10n.Notification.title.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.done.localized) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }

                if !viewModel.notifications.isEmpty && viewModel.hasUnreadNotifications {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            Task {
                                await viewModel.markAllAsRead()
                            }
                        } label: {
                            Text(L10n.Notification.markAllRead.localized)
                                .font(.subheadline)
                                .foregroundColor(.primaryGreen)
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadNotifications()
            withAnimation(.easeOut(duration: 0.4)) {
                appearAnimation = true
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
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

                Image(systemName: "bell.slash")
                    .font(.system(size: 50, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            VStack(spacing: Spacing.sm) {
                Text(L10n.Notification.emptyTitle.localized)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.primary)

                Text(L10n.Notification.emptyMessage.localized)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xxxl)
            }

            Spacer()
        }
        .offset(y: appearAnimation ? 0 : 20)
        .opacity(appearAnimation ? 1 : 0)
    }

    // MARK: - Notifications List

    private var notificationsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                ForEach(Array(viewModel.groupedNotifications.enumerated()), id: \.1.0) { index, group in
                    Section {
                        ForEach(group.1) { notification in
                            NotificationRow(notification: notification)
                                .onTapGesture {
                                    Task {
                                        await viewModel.markAsRead(notification)
                                    }
                                    // Navigate to relevant content based on type
                                    handleNotificationTap(notification)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        Task {
                                            await viewModel.deleteNotification(notification)
                                        }
                                    } label: {
                                        Label(L10n.Common.delete.localized, systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    if !notification.isRead {
                                        Button {
                                            Task {
                                                await viewModel.markAsRead(notification)
                                            }
                                        } label: {
                                            Label(L10n.Notification.markRead.localized, systemImage: "envelope.open")
                                        }
                                        .tint(.primaryGreen)
                                    }
                                }
                        }
                    } header: {
                        sectionHeader(title: group.0)
                    }
                }
            }
            .padding(.bottom, Spacing.xxxl)
            .frame(maxWidth: maxContentWidth)
            .frame(maxWidth: .infinity)
        }
        .refreshable {
            await viewModel.refresh()
        }
        .offset(y: appearAnimation ? 0 : 20)
        .opacity(appearAnimation ? 1 : 0)
    }

    // MARK: - Section Header

    private func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Color(.systemGray6)
                .opacity(0.95)
        )
    }

    // MARK: - Handle Notification Tap

    private func handleNotificationTap(_ notification: AppNotification) {
        // In a real app, this would navigate to the relevant content
        // based on notification.type and notification.relatedId
        switch notification.type {
        case .reviewReceived, .reviewApproved, .reviewRejected, .newReply:
            // Navigate to review or store
            break
        case .claimApproved, .claimRejected:
            // Navigate to claim or store
            break
        case .storeVerified:
            // Navigate to store
            break
        }
    }
}

// MARK: - Notification Row

struct NotificationRow: View {
    let notification: AppNotification

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Icon with colored background
            notificationIcon

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)

                    Spacer()

                    Text(notification.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(notification.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            notification.isRead
                ? Color.clear
                : Color.primaryGreen.opacity(0.05)
        )
        .overlay(
            Rectangle()
                .fill(Color(.separator).opacity(0.3))
                .frame(height: 0.5),
            alignment: .bottom
        )
        .overlay(
            // Unread indicator
            Group {
                if !notification.isRead {
                    Circle()
                        .fill(Color.primaryGreen)
                        .frame(width: 8, height: 8)
                        .offset(x: -4)
                }
            },
            alignment: .leading
        )
    }

    // MARK: - Notification Icon

    private var notificationIcon: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: iconGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)

            Image(systemName: notification.type.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
        }
    }

    private var iconGradientColors: [Color] {
        switch notification.type {
        case .reviewReceived:
            return [Color.starYellow, Color.orange]
        case .reviewApproved:
            return [Color.primaryGreen, Color.primaryGreenLight]
        case .reviewRejected:
            return [Color.red, Color.red.opacity(0.7)]
        case .claimApproved:
            return [Color.primaryGreen, Color.primaryGreenLight]
        case .claimRejected:
            return [Color.orange, Color.red]
        case .newReply:
            return [Color.blue, Color.purple]
        case .storeVerified:
            return [Color.blue, Color.cyan]
        }
    }
}

// MARK: - Notification Badge View

/// A small badge view to display unread notification count
struct NotificationBadge: View {
    let count: Int

    var body: some View {
        if count > 0 {
            ZStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: count > 9 ? 20 : 18, height: 18)

                Text(count > 99 ? "99+" : "\(count)")
                    .font(.system(size: count > 9 ? 10 : 11, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Notification Bell Button

/// A reusable notification bell button with badge
struct NotificationBellButton: View {
    @ObservedObject var viewModel: NotificationViewModel
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 44, height: 44)

                Image(systemName: "bell.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.primary)

                if viewModel.hasUnreadNotifications {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .offset(x: 2, y: -2)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NotificationView()
}

#Preview("Notification Row - Unread") {
    NotificationRow(notification: AppNotification.sample)
        .previewLayout(.sizeThatFits)
}

#Preview("Notification Row - Read") {
    NotificationRow(
        notification: AppNotification(
            id: 1,
            type: .claimApproved,
            title: "Claim Approved",
            message: "Your store claim has been approved!",
            isRead: true,
            createdAt: Date().addingTimeInterval(-86400),
            relatedId: 1,
            userName: nil
        )
    )
    .previewLayout(.sizeThatFits)
}
