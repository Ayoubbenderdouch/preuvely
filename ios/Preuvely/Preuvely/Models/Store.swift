import Foundation

// MARK: - Platform Type

enum Platform: String, Codable, CaseIterable, Identifiable, Hashable {
    case instagram
    case facebook
    case tiktok
    case website
    case whatsapp

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .instagram: return "Instagram"
        case .facebook: return "Facebook"
        case .tiktok: return "TikTok"
        case .website: return "Website"
        case .whatsapp: return "WhatsApp"
        }
    }

    var sfSymbol: String {
        switch self {
        case .instagram: return "camera.fill"
        case .facebook: return "person.2.fill"
        case .tiktok: return "music.note"
        case .website: return "globe"
        case .whatsapp: return "message.fill"
        }
    }

    var iconName: String {
        // For future 3D icons
        "icon_\(rawValue)"
    }
}

// MARK: - Store Link

struct StoreLink: Identifiable, Codable, Hashable {
    let id: Int
    let platform: Platform
    let url: String
    let handle: String?
}

// MARK: - Store Contact

struct StoreContact: Codable, Hashable {
    let whatsapp: String?
    let phone: String?
}

// MARK: - Store Submitter

/// Represents the user who submitted a store
struct StoreSubmitter: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let avatar: String?
    let storesCount: Int
    let reviewsCount: Int

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
}

#if DEBUG
extension StoreSubmitter {
    static let sample = StoreSubmitter(
        id: 1,
        name: "Ahmed Benali",
        avatar: nil,
        storesCount: 5,
        reviewsCount: 12
    )
}
#endif

// MARK: - Store

struct Store: Identifiable, Codable, Hashable {
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
    /// Links are optional - not included in list/search responses
    let links: [StoreLink]
    /// Contacts are optional - not included in list/search responses
    let contacts: StoreContact?
    let createdAt: Date?
    /// The user who submitted this store - only included in detail responses
    let submitter: StoreSubmitter?

    // CodingKeys - uses JSONDecoder .convertFromSnakeCase strategy
    // which auto-converts is_verified -> isVerified, etc.
    enum CodingKeys: String, CodingKey {
        case id, name, slug, description, city, logo, categories, links, contacts, submitter
        case isVerified, avgRating, reviewsCount, createdAt
    }

    /// Custom decoder to handle optional arrays that might be missing in list responses
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
        submitter = try container.decodeIfPresent(StoreSubmitter.self, forKey: .submitter)
    }

    /// Standard initializer for creating Store instances programmatically
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
        submitter: StoreSubmitter? = nil
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
        self.submitter = submitter
    }

    var primaryPlatform: Platform? {
        links.first?.platform
    }

    var platformBadges: [Platform] {
        links.map { $0.platform }
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
}

// MARK: - Store Summary

struct StoreSummary: Codable {
    let avgRating: Double
    let reviewsCount: Int
    let isVerified: Bool
    let ratingBreakdown: RatingBreakdown
    let proofBadge: Bool

    // Uses JSONDecoder .convertFromSnakeCase strategy
}

// MARK: - Rating Breakdown

struct RatingBreakdown: Codable {
    let one: Int
    let two: Int
    let three: Int
    let four: Int
    let five: Int

    enum CodingKeys: String, CodingKey {
        case one = "1"
        case two = "2"
        case three = "3"
        case four = "4"
        case five = "5"
    }

    var total: Int {
        one + two + three + four + five
    }

    func percentage(for stars: Int) -> Double {
        guard total > 0 else { return 0 }
        let count: Int
        switch stars {
        case 1: count = one
        case 2: count = two
        case 3: count = three
        case 4: count = four
        case 5: count = five
        default: count = 0
        }
        return Double(count) / Double(total)
    }
}

// MARK: - Preview Data (minimal, for SwiftUI Previews only)

#if DEBUG
extension Store {
    static let sample = Store(
        id: 1,
        name: "Preview Store",
        slug: "preview-store",
        description: "Preview description",
        city: "Algiers",
        logo: nil,
        isVerified: true,
        avgRating: 4.5,
        reviewsCount: 10,
        categories: [],
        links: [],
        contacts: nil,
        createdAt: Date()
    )

    static let samples: [Store] = []
}

extension StoreSummary {
    static let sample = StoreSummary(
        avgRating: 4.5,
        reviewsCount: 10,
        isVerified: true,
        ratingBreakdown: RatingBreakdown(one: 0, two: 0, three: 1, four: 4, five: 5),
        proofBadge: false
    )
}
#endif
