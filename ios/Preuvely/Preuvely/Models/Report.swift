import Foundation

// MARK: - Reportable Type

enum ReportableType: String, Codable {
    case store
    case review
    case reply
}

// MARK: - Report Reason

enum ReportReason: String, Codable, CaseIterable, Identifiable, Hashable {
    case spam
    case abuse
    case fake
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .spam: return "Spam"
        case .abuse: return "Abuse"
        case .fake: return "Fake/Misleading"
        case .other: return "Other"
        }
    }

    var localizedDisplayName: String {
        switch self {
        case .spam: return L10n.Report.Reason.spam.localized
        case .abuse: return L10n.Report.Reason.abuse.localized
        case .fake: return L10n.Report.Reason.fake.localized
        case .other: return L10n.Report.Reason.other.localized
        }
    }

    var iconName: String {
        switch self {
        case .spam: return "exclamationmark.bubble.fill"
        case .abuse: return "hand.raised.fill"
        case .fake: return "eye.slash.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

// MARK: - Report Status

enum ReportStatus: String, Codable, Hashable {
    case open
    case resolved
    case dismissed

    var displayName: String {
        switch self {
        case .open: return "Open"
        case .resolved: return "Resolved"
        case .dismissed: return "Dismissed"
        }
    }
}

// MARK: - Report

struct Report: Identifiable, Codable, Hashable {
    let id: Int
    let reportableType: String // Backend returns lowercase type: "store", "review", "reply"
    let reportableId: Int
    let reportableName: String?
    let reason: ReportReason
    let note: String?
    let status: ReportStatus
    let createdAt: Date?

    // Note: Using JSONDecoder with .convertFromSnakeCase strategy

    var formattedDate: String {
        guard let date = createdAt else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    /// Get the reportable type for display (converts backend type to user-friendly text)
    var displayableType: String {
        switch reportableType.lowercased() {
        case "store": return "Store"
        case "review": return "Review"
        case "storereply", "reply": return "Reply"
        default: return reportableType.capitalized
        }
    }

    /// Display name for the reported content (falls back to type + ID if name not available)
    var displayReportableName: String {
        reportableName ?? "\(displayableType) #\(reportableId)"
    }
}

// MARK: - Preview Data

#if DEBUG
extension Report {
    static let samples: [Report] = []
    static let sample = Report(
        id: 1,
        reportableType: "store",
        reportableId: 1,
        reportableName: "Preview Store",
        reason: .other,
        note: nil,
        status: .open,
        createdAt: Date()
    )
}
#endif
