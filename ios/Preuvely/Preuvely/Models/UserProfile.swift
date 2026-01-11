import Foundation

// MARK: - User Profile

/// Complete user profile data including stats, submitted stores, and reviews
struct UserProfile: Codable, Identifiable {
    let id: Int
    let name: String
    let avatar: String?
    let memberSince: Date?
    let stats: UserStats
    let submittedStores: [Store]
    let reviews: [Review]

    // Note: Using JSONDecoder with .convertFromSnakeCase strategy

    /// Returns user initials for avatar placeholder
    var initials: String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            let first = components[0].prefix(1)
            let last = components[1].prefix(1)
            return "\(first)\(last)".uppercased()
        }
        return name.prefix(2).uppercased()
    }

    /// Formatted member since date
    var formattedMemberSince: String? {
        guard let date = memberSince else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - User Stats

/// Statistics about a user's activity
struct UserStats: Codable {
    let storesCount: Int
    let reviewsCount: Int

    // Note: Using JSONDecoder with .convertFromSnakeCase strategy
}

// MARK: - Preview Data

#if DEBUG
extension UserProfile {
    static let sample = UserProfile(
        id: 1,
        name: "Ahmed Benali",
        avatar: nil,
        memberSince: Calendar.current.date(byAdding: .month, value: -6, to: Date()),
        stats: UserStats(storesCount: 5, reviewsCount: 12),
        submittedStores: [Store.sample],
        reviews: [Review.sample]
    )
}

extension UserStats {
    static let sample = UserStats(storesCount: 5, reviewsCount: 12)
}
#endif
