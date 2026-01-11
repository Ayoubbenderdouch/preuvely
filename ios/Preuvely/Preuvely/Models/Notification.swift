import Foundation

// MARK: - Notification Type

enum NotificationType: String, Codable, CaseIterable {
    // Note: Explicit raw values for backend snake_case format
    case reviewReceived = "review_received"
    case reviewApproved = "review_approved"
    case reviewRejected = "review_rejected"
    case claimApproved = "claim_approved"
    case claimRejected = "claim_rejected"
    case newReply = "new_reply"
    case storeVerified = "store_verified"

    /// SF Symbol icon for each notification type
    var icon: String {
        switch self {
        case .reviewReceived: return "star.bubble.fill"
        case .reviewApproved: return "checkmark.circle.fill"
        case .reviewRejected: return "xmark.circle.fill"
        case .claimApproved: return "building.2.crop.circle.fill"
        case .claimRejected: return "building.2.crop.circle"
        case .newReply: return "arrowshape.turn.up.left.fill"
        case .storeVerified: return "checkmark.seal.fill"
        }
    }

    /// Localized title key for each notification type
    var titleKey: String {
        switch self {
        case .reviewReceived: return L10n.Notification.reviewReceivedTitle
        case .reviewApproved: return L10n.Notification.reviewApprovedTitle
        case .reviewRejected: return L10n.Notification.reviewRejectedTitle
        case .claimApproved: return L10n.Notification.claimApprovedTitle
        case .claimRejected: return L10n.Notification.claimRejectedTitle
        case .newReply: return L10n.Notification.newReplyTitle
        case .storeVerified: return L10n.Notification.storeVerifiedTitle
        }
    }

    /// Localized message key for each notification type
    var messageKey: String {
        switch self {
        case .reviewReceived: return L10n.Notification.reviewReceivedMessage
        case .reviewApproved: return L10n.Notification.reviewApprovedMessage
        case .reviewRejected: return L10n.Notification.reviewRejectedMessage
        case .claimApproved: return L10n.Notification.claimApprovedMessage
        case .claimRejected: return L10n.Notification.claimRejectedMessage
        case .newReply: return L10n.Notification.newReplyMessage
        case .storeVerified: return L10n.Notification.storeVerifiedMessage
        }
    }
}

// MARK: - App Notification

/// Represents an in-app notification for the user
struct AppNotification: Identifiable, Codable, Hashable {
    let id: Int
    let type: NotificationType
    let title: String
    let message: String
    var isRead: Bool
    let createdAt: Date
    let relatedId: Int? // Can be storeId or reviewId depending on type
    let userName: String? // For reviewReceived notifications

    // Note: Using JSONDecoder with .convertFromSnakeCase strategy

    /// Formatted relative time (e.g., "2h ago", "Yesterday")
    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }

    /// Full formatted date for accessibility
    var fullFormattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
}

// MARK: - Preview Data

#if DEBUG
extension AppNotification {
    static let samples: [AppNotification] = []
    static let sample = AppNotification(
        id: 1,
        type: .reviewReceived,
        title: "Preview Notification",
        message: "This is a preview notification.",
        isRead: false,
        createdAt: Date(),
        relatedId: nil,
        userName: nil
    )
}
#endif
