import Foundation

// MARK: - Review Status

enum ReviewStatus: String, Codable, Hashable {
    case pending
    case approved
    case rejected
}

// MARK: - Proof Status

enum ProofStatus: String, Codable, Hashable {
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
        case .pending: return L10n.Review.proofPending
        case .approved: return L10n.Review.proofApproved
        case .rejected: return L10n.Review.proofRejected
        }
    }
}

// MARK: - Proof

struct Proof: Identifiable, Codable, Hashable {
    let id: Int
    let url: String
    let status: ProofStatus
    let createdAt: Date?

    // Note: Using JSONDecoder with .convertFromSnakeCase strategy
}

// MARK: - Store Reply

struct StoreReply: Identifiable, Codable, Hashable {
    let id: Int
    let replyText: String
    let user: ReviewUser
    let createdAt: Date?

    // Note: Using JSONDecoder with .convertFromSnakeCase strategy

    /// User name for display
    var userName: String {
        user.name
    }
}

// MARK: - Review User

struct ReviewUser: Codable, Hashable {
    let id: Int
    let name: String
    let avatar: String?
}

// MARK: - Review Store (for my reviews)

struct ReviewStore: Codable, Hashable {
    let id: Int
    let name: String
    let slug: String
}

// MARK: - Review

struct Review: Identifiable, Codable, Hashable {
    let id: Int
    let stars: Int
    let comment: String
    let status: ReviewStatus
    let isHighRisk: Bool
    let user: ReviewUser
    let proof: Proof?
    let reply: StoreReply?
    let store: ReviewStore?
    let createdAt: Date?

    // Note: Using JSONDecoder with .convertFromSnakeCase strategy

    /// User ID for convenience
    var userId: Int {
        user.id
    }

    /// User name for display
    var userName: String {
        user.name
    }

    /// User avatar URL for display
    var userAvatar: String? {
        user.avatar
    }

    /// Check if has proof (derived from proof object)
    var hasProof: Bool {
        proof != nil
    }

    var formattedDate: String {
        guard let date = createdAt else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    var hasVerifiedProof: Bool {
        proof?.status == .approved
    }
}

// MARK: - Preview Data

#if DEBUG
extension Review {
    static let samples: [Review] = []

    static let sample = Review(
        id: 1,
        stars: 5,
        comment: "Preview review",
        status: .approved,
        isHighRisk: false,
        user: ReviewUser(id: 1, name: "Preview User", avatar: nil),
        proof: nil,
        reply: nil,
        store: ReviewStore(id: 1, name: "Sample Store", slug: "sample-store"),
        createdAt: Date()
    )
}
#endif
