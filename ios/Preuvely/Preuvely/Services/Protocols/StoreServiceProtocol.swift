import Foundation
import UIKit

// MARK: - Store Service Protocol

protocol StoreServiceProtocol {
    /// Search stores with optional filters
    func searchStores(
        query: String?,
        category: String?,
        verifiedOnly: Bool,
        sortBy: StoreSortOption,
        page: Int,
        perPage: Int
    ) async throws -> PaginatedResponse<Store>

    /// Get store details by slug
    func getStore(slug: String) async throws -> Store

    /// Get store summary (rating breakdown)
    func getStoreSummary(slug: String) async throws -> StoreSummary

    /// Get reviews for a store
    func getStoreReviews(storeId: Int, page: Int, perPage: Int) async throws -> PaginatedResponse<Review>

    /// Create a new store
    func createStore(request: CreateStoreRequest, logo: UIImage?) async throws -> Store

    /// Get trending stores
    func getTrendingStores() async throws -> [Store]

    /// Get top rated stores
    func getTopRatedStores() async throws -> [Store]

    /// Get reviews created by the current user
    func getMyReviews(page: Int, perPage: Int) async throws -> PaginatedResponse<Review>
}

// MARK: - Sort Options

enum StoreSortOption: String, CaseIterable, Identifiable {
    case bestRated = "best_rated"
    case mostReviewed = "most_reviewed"
    case newest = "newest"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .bestRated: return "Best Rated"
        case .mostReviewed: return "Most Reviewed"
        case .newest: return "Newest"
        }
    }

    var localizedKey: String {
        switch self {
        case .bestRated: return L10n.Search.bestRated
        case .mostReviewed: return L10n.Search.mostReviewed
        case .newest: return L10n.Search.newest
        }
    }
}

// MARK: - Create Store Request

struct CreateStoreRequest: Encodable {
    let name: String
    let description: String?
    let city: String?
    let categoryIds: [Int]
    let links: [CreateStoreLinkRequest]
    let contacts: CreateStoreContactRequest?

    enum CodingKeys: String, CodingKey {
        case name, description, city, links, contacts
        case categoryIds = "category_ids"
    }
}

struct CreateStoreLinkRequest: Encodable {
    let platform: Platform
    let url: String
    let handle: String?
}

struct CreateStoreContactRequest: Encodable {
    let whatsapp: String?
    let phone: String?
}

// MARK: - Paginated Response

struct PaginatedResponse<T: Codable>: Codable where T: Hashable {
    let data: [T]
    let meta: PaginationMeta
}

struct PaginationMeta: Codable {
    let currentPage: Int
    let lastPage: Int
    let perPage: Int
    let total: Int

    // Note: Using JSONDecoder with .convertFromSnakeCase strategy

    var hasNextPage: Bool {
        currentPage < lastPage
    }
}
