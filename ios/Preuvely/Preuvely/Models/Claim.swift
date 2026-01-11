import Foundation
import Combine

// MARK: - Claim Status

enum ClaimStatus: String, Codable, Hashable {
    case pending
    case approved
    case rejected

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .approved: return "Approved"
        case .rejected: return "Rejected"
        }
    }

    var localizedKey: String {
        switch self {
        case .pending: return L10n.Claim.pending
        case .approved: return L10n.Claim.approved
        case .rejected: return L10n.Claim.rejected
        }
    }
}

// MARK: - Claim

struct Claim: Identifiable, Codable, Hashable {
    let id: Int
    let storeId: Int
    let storeName: String?
    let storeSlug: String?
    let requesterName: String
    let requesterPhone: String
    let note: String?
    let status: ClaimStatus
    let rejectReason: String?
    let createdAt: Date?

    // Note: Using JSONDecoder with .convertFromSnakeCase strategy

    var formattedDate: String {
        guard let date = createdAt else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    /// Display name for the store (falls back to store ID if name not available)
    var displayStoreName: String {
        storeName ?? "Store #\(storeId)"
    }
}

// MARK: - Preview Data

#if DEBUG
extension Claim {
    static let samples: [Claim] = []
    static let sample = Claim(
        id: 1,
        storeId: 1,
        storeName: "Preview Store",
        storeSlug: "preview-store",
        requesterName: "Preview User",
        requesterPhone: "+213000000000",
        note: nil,
        status: .pending,
        rejectReason: nil,
        createdAt: Date()
    )
}
#endif
