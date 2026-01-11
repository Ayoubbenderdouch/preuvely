import Foundation
import UIKit
import Combine

// MARK: - Mock Service

/// Mock service that simulates API calls with local data
@MainActor
final class MockService: ObservableObject {
    static let shared = MockService()

    // Simulated network delay
    private let networkDelay: UInt64 = 500_000_000 // 0.5 seconds

    // Mock user state
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false

    private init() {}

    private func simulateNetworkDelay() async {
        try? await Task.sleep(nanoseconds: networkDelay)
    }
}

// MARK: - Banner Service

extension MockService {
    func getBanners() async throws -> [Banner] {
        await simulateNetworkDelay()
        return [] // No mock data - use real API
    }
}

// MARK: - Category Service

extension MockService: CategoryServiceProtocol {
    func getCategories() async throws -> [Category] {
        await simulateNetworkDelay()
        return [] // No mock data - use real API
    }

    func getCategory(slug: String) async throws -> Category {
        await simulateNetworkDelay()
        throw ServiceError.notFound // No mock data - use real API
    }
}

// MARK: - Store Service

extension MockService: StoreServiceProtocol {
    func searchStores(
        query: String?,
        category: String?,
        verifiedOnly: Bool,
        sortBy: StoreSortOption,
        page: Int,
        perPage: Int
    ) async throws -> PaginatedResponse<Store> {
        await simulateNetworkDelay()

        let meta = PaginationMeta(
            currentPage: page,
            lastPage: 1,
            perPage: perPage,
            total: 0
        )

        return PaginatedResponse(data: [], meta: meta) // No mock data - use real API
    }

    func getStore(slug: String) async throws -> Store {
        await simulateNetworkDelay()
        throw ServiceError.notFound // No mock data - use real API
    }

    func getStoreSummary(slug: String) async throws -> StoreSummary {
        await simulateNetworkDelay()
        throw ServiceError.notFound // No mock data - use real API
    }

    func getStoreReviews(storeId: Int, page: Int, perPage: Int) async throws -> PaginatedResponse<Review> {
        await simulateNetworkDelay()

        let meta = PaginationMeta(
            currentPage: page,
            lastPage: 1,
            perPage: perPage,
            total: 0
        )

        return PaginatedResponse(data: [], meta: meta) // No mock data - use real API
    }

    func createStore(request: CreateStoreRequest, logo: UIImage?) async throws -> Store {
        await simulateNetworkDelay()
        throw ServiceError.unauthorized // No mock data - use real API
    }

    func getTrendingStores() async throws -> [Store] {
        await simulateNetworkDelay()
        return [] // No mock data - use real API
    }

    func getTopRatedStores() async throws -> [Store] {
        await simulateNetworkDelay()
        return [] // No mock data - use real API
    }

    func getMyReviews(page: Int, perPage: Int) async throws -> PaginatedResponse<Review> {
        await simulateNetworkDelay()

        guard currentUser != nil else {
            throw ServiceError.unauthorized
        }

        let meta = PaginationMeta(
            currentPage: page,
            lastPage: 1,
            perPage: perPage,
            total: 0
        )

        return PaginatedResponse(data: [], meta: meta)
    }
}


extension MockService: ReviewServiceProtocol {
    func createReview(storeId: Int, request: CreateReviewRequest) async throws -> Review {
        await simulateNetworkDelay()

        guard let user = currentUser else {
            throw ServiceError.unauthorized
        }

        let store = Store.samples.first { $0.id == storeId }
        let isHighRisk = store?.categories.contains { $0.isHighRisk } ?? false

        return Review(
            id: Int.random(in: 100...999),
            stars: request.stars,
            comment: request.comment,
            status: isHighRisk ? .pending : .approved,
            isHighRisk: isHighRisk,
            user: ReviewUser(id: user.id, name: user.name, avatar: user.avatar),
            proof: nil,
            reply: nil,
            store: store.map { ReviewStore(id: $0.id, name: $0.name, slug: $0.slug) },
            createdAt: Date()
        )
    }

    func uploadProof(reviewId: Int, image: UIImage) async throws -> Proof {
        await simulateNetworkDelay()

        return Proof(
            id: Int.random(in: 100...999),
            url: "https://example.com/proof/\(reviewId).jpg",
            status: .pending,
            createdAt: Date()
        )
    }

    func getUserReview(storeId: Int) async throws -> Review? {
        await simulateNetworkDelay()

        guard let user = currentUser else {
            return nil
        }

        return Review.samples.first { $0.userId == user.id }
    }

    func replyToReview(reviewId: Int, text: String) async throws -> StoreReply {
        await simulateNetworkDelay()

        guard let user = currentUser else {
            throw ServiceError.unauthorized
        }

        return StoreReply(
            id: Int.random(in: 100...999),
            replyText: text,
            user: ReviewUser(id: user.id, name: user.name, avatar: user.avatar),
            createdAt: Date()
        )
    }
}

// MARK: - Auth Service

extension MockService: AuthServiceProtocol {
    var authState: AuthState {
        if let user = currentUser {
            if user.isEmailVerified {
                return .authenticated(user)
            } else {
                return .emailVerificationPending(user)
            }
        }
        return .guest
    }

    func register(request: RegisterRequest) async throws -> User {
        await simulateNetworkDelay()

        let user = User(
            id: Int.random(in: 100...999),
            name: request.name,
            email: request.email,
            phone: nil,
            emailVerified: false,
            avatar: nil,
            createdAt: Date()
        )

        currentUser = user
        isAuthenticated = true
        return user
    }

    func login(email: String, password: String) async throws -> User {
        await simulateNetworkDelay()

        // Simulate login - accept any credentials for demo
        if email.isEmpty || password.isEmpty {
            throw AuthError.invalidCredentials
        }

        let user = User.sample
        currentUser = user
        isAuthenticated = true
        return user
    }

    func logout() async throws {
        await simulateNetworkDelay()
        currentUser = nil
        isAuthenticated = false
    }

    func getCurrentUser() async throws -> User? {
        await simulateNetworkDelay()
        return currentUser
    }

    func resendVerificationEmail() async throws {
        await simulateNetworkDelay()
        // Simulate sending email
    }

    func socialLogin(provider: SocialProvider, idToken: String) async throws -> User {
        await simulateNetworkDelay()

        let user = User.sample
        currentUser = user
        isAuthenticated = true
        return user
    }
}

// MARK: - Claim Service

extension MockService: ClaimServiceProtocol {
    func getMyClaims() async throws -> [Claim] {
        await simulateNetworkDelay()

        guard currentUser != nil else {
            throw ServiceError.unauthorized
        }

        return Claim.samples
    }

    func submitClaim(storeId: Int, request: CreateClaimRequest) async throws -> Claim {
        await simulateNetworkDelay()

        guard currentUser != nil else {
            throw ServiceError.unauthorized
        }

        let store = Store.samples.first { $0.id == storeId }

        return Claim(
            id: Int.random(in: 100...999),
            storeId: storeId,
            storeName: store?.name,
            storeSlug: store?.slug,
            requesterName: request.requesterName,
            requesterPhone: request.requesterPhone,
            note: request.note,
            status: .pending,
            rejectReason: nil,
            createdAt: Date()
        )
    }
}

// MARK: - Report Service

extension MockService: ReportServiceProtocol {
    func getMyReports() async throws -> [Report] {
        await simulateNetworkDelay()

        guard currentUser != nil else {
            throw ServiceError.unauthorized
        }

        return Report.samples
    }

    func submitReport(request: CreateReportRequest) async throws -> Report {
        await simulateNetworkDelay()

        guard currentUser != nil else {
            throw ServiceError.unauthorized
        }

        return Report(
            id: Int.random(in: 100...999),
            reportableType: request.reportableType.rawValue,
            reportableId: request.reportableId,
            reportableName: "Reported Item",
            reason: request.reason,
            note: request.note,
            status: .open,
            createdAt: Date()
        )
    }
}

// MARK: - Notification Service

extension MockService: NotificationServiceProtocol {
    /// Mock notification storage - in real app this would be stored on server
    private static var mockNotifications: [AppNotification] = AppNotification.samples

    func getNotifications() async throws -> [AppNotification] {
        await simulateNetworkDelay()

        guard currentUser != nil else {
            throw ServiceError.unauthorized
        }

        // Return sorted by date (newest first)
        return MockService.mockNotifications.sorted { $0.createdAt > $1.createdAt }
    }

    func getUnreadCount() async throws -> Int {
        await simulateNetworkDelay()

        guard currentUser != nil else {
            return 0
        }

        return MockService.mockNotifications.filter { !$0.isRead }.count
    }

    func markAsRead(notificationId: Int) async throws {
        await simulateNetworkDelay()

        guard currentUser != nil else {
            throw ServiceError.unauthorized
        }

        if let index = MockService.mockNotifications.firstIndex(where: { $0.id == notificationId }) {
            MockService.mockNotifications[index].isRead = true
        }
    }

    func markAllAsRead() async throws {
        await simulateNetworkDelay()

        guard currentUser != nil else {
            throw ServiceError.unauthorized
        }

        for index in MockService.mockNotifications.indices {
            MockService.mockNotifications[index].isRead = true
        }
    }

    func deleteNotification(notificationId: Int) async throws {
        await simulateNetworkDelay()

        guard currentUser != nil else {
            throw ServiceError.unauthorized
        }

        MockService.mockNotifications.removeAll { $0.id == notificationId }
    }
}

// MARK: - Store Owner Service

extension MockService: StoreOwnerServiceProtocol {
    func getMyStores() async throws -> [OwnedStore] {
        await simulateNetworkDelay()

        guard currentUser != nil else {
            throw ServiceError.unauthorized
        }

        return OwnedStore.samples
    }

    func updateStore(storeId: Int, request: UpdateStoreRequest) async throws -> Store {
        await simulateNetworkDelay()

        guard currentUser != nil else {
            throw ServiceError.unauthorized
        }

        // Return an updated store based on the request
        let existingStore = Store.sample
        return Store(
            id: storeId,
            name: request.name ?? existingStore.name,
            slug: existingStore.slug,
            description: request.description ?? existingStore.description,
            city: request.city ?? existingStore.city,
            logo: existingStore.logo,
            isVerified: existingStore.isVerified,
            avgRating: existingStore.avgRating,
            reviewsCount: existingStore.reviewsCount,
            categories: existingStore.categories,
            links: existingStore.links,
            contacts: existingStore.contacts,
            createdAt: existingStore.createdAt
        )
    }

    func uploadStoreLogo(storeId: Int, image: UIImage) async throws -> Store {
        await simulateNetworkDelay()

        guard currentUser != nil else {
            throw ServiceError.unauthorized
        }

        // Return a store with an updated mock logo URL
        let existingStore = Store.sample
        return Store(
            id: storeId,
            name: existingStore.name,
            slug: existingStore.slug,
            description: existingStore.description,
            city: existingStore.city,
            logo: "https://example.com/logos/\(storeId).jpg",
            isVerified: existingStore.isVerified,
            avgRating: existingStore.avgRating,
            reviewsCount: existingStore.reviewsCount,
            categories: existingStore.categories,
            links: existingStore.links,
            contacts: existingStore.contacts,
            createdAt: existingStore.createdAt
        )
    }

    func getStoreLinks(storeId: Int) async throws -> [StoreLink] {
        await simulateNetworkDelay()

        guard currentUser != nil else {
            throw ServiceError.unauthorized
        }

        // Return sample links
        return [
            StoreLink(id: 1, platform: .instagram, url: "https://instagram.com/sample", handle: "@sample"),
            StoreLink(id: 2, platform: .facebook, url: "https://facebook.com/sample", handle: nil),
            StoreLink(id: 3, platform: .website, url: "https://example.com", handle: nil)
        ]
    }

    func updateStoreLinks(storeId: Int, links: [StoreLink]) async throws -> [StoreLink] {
        await simulateNetworkDelay()

        guard currentUser != nil else {
            throw ServiceError.unauthorized
        }

        // Return the updated links (in a real implementation, these would be persisted)
        return links
    }
}

// MARK: - Service Error

enum ServiceError: LocalizedError {
    case notFound
    case unauthorized
    case networkError
    case validationError(String)
    case serverError
    case conflict

    var errorDescription: String? {
        switch self {
        case .notFound: return "Resource not found"
        case .unauthorized: return "Please sign in to continue"
        case .networkError: return "Network error. Please try again."
        case .validationError(let message): return message
        case .serverError: return "Server error. Please try again later."
        case .conflict: return "This action has already been performed"
        }
    }
}
