import Foundation

// MARK: - Notification Service Protocol

protocol NotificationServiceProtocol {
    /// Fetches all notifications for the current user
    func getNotifications() async throws -> [AppNotification]

    /// Returns count of unread notifications
    func getUnreadCount() async throws -> Int

    /// Marks a single notification as read
    func markAsRead(notificationId: Int) async throws

    /// Marks all notifications as read
    func markAllAsRead() async throws

    /// Deletes a notification
    func deleteNotification(notificationId: Int) async throws
}
