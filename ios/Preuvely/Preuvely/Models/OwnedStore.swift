import Foundation

// MARK: - Owned Store

/// A store owned by the current user with additional owner-specific fields
struct OwnedStore: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let slug: String
    let description: String?
    let city: String?
    let logo: String?
    let isVerified: Bool
    let avgRating: Double
    let reviewsCount: Int
    let categories: [Category]
    let links: [StoreLink]
    let contacts: StoreContact?
    let createdAt: Date?

    // Owner-specific fields
    let claimStatus: ClaimStatus?
    let pendingReviewsCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, slug, description, city, logo, categories, links, contacts
        case isVerified, avgRating, reviewsCount, createdAt
        case claimStatus, pendingReviewsCount
    }

    /// Custom decoder to handle optional arrays that might be missing
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        slug = try container.decode(String.self, forKey: .slug)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        city = try container.decodeIfPresent(String.self, forKey: .city)
        logo = try container.decodeIfPresent(String.self, forKey: .logo)
        isVerified = try container.decode(Bool.self, forKey: .isVerified)
        avgRating = try container.decode(Double.self, forKey: .avgRating)
        reviewsCount = try container.decode(Int.self, forKey: .reviewsCount)
        categories = try container.decodeIfPresent([Category].self, forKey: .categories) ?? []
        links = try container.decodeIfPresent([StoreLink].self, forKey: .links) ?? []
        contacts = try container.decodeIfPresent(StoreContact.self, forKey: .contacts)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        claimStatus = try container.decodeIfPresent(ClaimStatus.self, forKey: .claimStatus)
        pendingReviewsCount = try container.decodeIfPresent(Int.self, forKey: .pendingReviewsCount)
    }

    /// Standard initializer for creating OwnedStore instances programmatically
    init(
        id: Int,
        name: String,
        slug: String,
        description: String?,
        city: String?,
        logo: String?,
        isVerified: Bool,
        avgRating: Double,
        reviewsCount: Int,
        categories: [Category],
        links: [StoreLink],
        contacts: StoreContact?,
        createdAt: Date?,
        claimStatus: ClaimStatus?,
        pendingReviewsCount: Int?
    ) {
        self.id = id
        self.name = name
        self.slug = slug
        self.description = description
        self.city = city
        self.logo = logo
        self.isVerified = isVerified
        self.avgRating = avgRating
        self.reviewsCount = reviewsCount
        self.categories = categories
        self.links = links
        self.contacts = contacts
        self.createdAt = createdAt
        self.claimStatus = claimStatus
        self.pendingReviewsCount = pendingReviewsCount
    }

    /// Convert to a regular Store object
    func toStore() -> Store {
        Store(
            id: id,
            name: name,
            slug: slug,
            description: description,
            city: city,
            logo: logo,
            isVerified: isVerified,
            avgRating: avgRating,
            reviewsCount: reviewsCount,
            categories: categories,
            links: links,
            contacts: contacts,
            createdAt: createdAt
        )
    }

    var formattedRating: String {
        String(format: "%.1f", avgRating)
    }

    var formattedReviewsCount: String {
        if reviewsCount >= 1000 {
            return String(format: "%.1fK", Double(reviewsCount) / 1000)
        }
        return "\(reviewsCount)"
    }

    /// Custom encoder to match the custom decoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(slug, forKey: .slug)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(city, forKey: .city)
        try container.encodeIfPresent(logo, forKey: .logo)
        try container.encode(isVerified, forKey: .isVerified)
        try container.encode(avgRating, forKey: .avgRating)
        try container.encode(reviewsCount, forKey: .reviewsCount)
        try container.encode(categories, forKey: .categories)
        try container.encode(links, forKey: .links)
        try container.encodeIfPresent(contacts, forKey: .contacts)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(claimStatus, forKey: .claimStatus)
        try container.encodeIfPresent(pendingReviewsCount, forKey: .pendingReviewsCount)
    }
}

// MARK: - Preview Data

#if DEBUG
extension OwnedStore {
    static let sample = OwnedStore(
        id: 1,
        name: "My Store",
        slug: "my-store",
        description: "A sample store for preview",
        city: "Algiers",
        logo: nil,
        isVerified: true,
        avgRating: 4.5,
        reviewsCount: 25,
        categories: [],
        links: [],
        contacts: nil,
        createdAt: Date(),
        claimStatus: .approved,
        pendingReviewsCount: 3
    )

    static let samples: [OwnedStore] = [sample]
}
#endif
