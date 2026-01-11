import Foundation
import Combine

@MainActor
final class NotificationViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var notifications: [AppNotification] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var error: Error?
    @Published var unreadCount: Int = 0

    // MARK: - Dependencies

    private let service: NotificationServiceProtocol

    // MARK: - Initialization

    init(service: NotificationServiceProtocol = APIClient.shared) {
        self.service = service
    }

    // MARK: - Computed Properties

    var hasUnreadNotifications: Bool {
        unreadCount > 0
    }

    var groupedNotifications: [(String, [AppNotification])] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!

        var todayNotifications: [AppNotification] = []
        var yesterdayNotifications: [AppNotification] = []
        var thisWeekNotifications: [AppNotification] = []
        var olderNotifications: [AppNotification] = []

        for notification in notifications {
            let notificationDate = calendar.startOfDay(for: notification.createdAt)

            if notificationDate >= today {
                todayNotifications.append(notification)
            } else if notificationDate >= yesterday {
                yesterdayNotifications.append(notification)
            } else if notificationDate >= weekAgo {
                thisWeekNotifications.append(notification)
            } else {
                olderNotifications.append(notification)
            }
        }

        var groups: [(String, [AppNotification])] = []

        if !todayNotifications.isEmpty {
            groups.append((L10n.Notification.today.localized, todayNotifications))
        }
        if !yesterdayNotifications.isEmpty {
            groups.append((L10n.Notification.yesterday.localized, yesterdayNotifications))
        }
        if !thisWeekNotifications.isEmpty {
            groups.append((L10n.Notification.thisWeek.localized, thisWeekNotifications))
        }
        if !olderNotifications.isEmpty {
            groups.append((L10n.Notification.older.localized, olderNotifications))
        }

        return groups
    }

    // MARK: - Public Methods

    /// Check if an error is a cancellation error (should be ignored)
    private func isCancellationError(_ error: Error) -> Bool {
        if (error as NSError).code == NSURLErrorCancelled {
            return true
        }
        if error is CancellationError {
            return true
        }
        return false
    }

    func loadNotifications() async {
        isLoading = true
        error = nil

        do {
            notifications = try await service.getNotifications()
            unreadCount = try await service.getUnreadCount()
        } catch {
            // Ignore cancellation errors
            guard !isCancellationError(error) else {
                isLoading = false
                return
            }
            self.error = error
        }

        isLoading = false
    }

    func refresh() async {
        // Prevent concurrent refreshes
        guard !isRefreshing else { return }
        isRefreshing = true

        do {
            notifications = try await service.getNotifications()
            unreadCount = try await service.getUnreadCount()
        } catch {
            // Ignore cancellation errors
            guard !isCancellationError(error) else {
                isRefreshing = false
                return
            }
            self.error = error
        }

        isRefreshing = false
    }

    func markAsRead(_ notification: AppNotification) async {
        guard !notification.isRead else { return }

        do {
            try await service.markAsRead(notificationId: notification.id)

            // Update local state
            if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                notifications[index].isRead = true
                unreadCount = max(0, unreadCount - 1)
            }
        } catch {
            self.error = error
        }
    }

    func markAllAsRead() async {
        do {
            try await service.markAllAsRead()

            // Update local state
            for index in notifications.indices {
                notifications[index].isRead = true
            }
            unreadCount = 0
        } catch {
            self.error = error
        }
    }

    func deleteNotification(_ notification: AppNotification) async {
        do {
            try await service.deleteNotification(notificationId: notification.id)

            // Update local state
            if !notification.isRead {
                unreadCount = max(0, unreadCount - 1)
            }
            notifications.removeAll { $0.id == notification.id }
        } catch {
            self.error = error
        }
    }

    func updateUnreadCount() async {
        do {
            unreadCount = try await service.getUnreadCount()
        } catch {
            // Silently fail for badge count updates
        }
    }
}
