import Foundation
import Combine

@MainActor
final class UserProfileViewModel: ObservableObject {
    /// The user profile data
    @Published var profile: UserProfile?

    /// Stores submitted by this user (can be loaded separately with pagination)
    @Published var stores: [Store] = []

    /// Reviews written by this user (can be loaded separately with pagination)
    @Published var reviews: [Review] = []

    /// Loading states
    @Published var isLoadingProfile = false
    @Published var isLoadingStores = false
    @Published var isLoadingReviews = false
    @Published var isLoadingMoreStores = false
    @Published var isLoadingMoreReviews = false

    /// Pagination states
    @Published var hasMoreStores = false
    @Published var hasMoreReviews = false

    /// Error state
    @Published var error: Error?
    @Published var showError = false

    private let userId: Int
    private let apiClient: APIClient

    private var storesPage = 1
    private var reviewsPage = 1
    private let perPage = 15
    private var isRefreshing = false

    // MARK: - Initialization

    /// Initialize with a user ID
    /// - Parameters:
    ///   - userId: The user ID to fetch profile for
    ///   - apiClient: The API client to use (default: shared)
    init(userId: Int, apiClient: APIClient = .shared) {
        self.userId = userId
        self.apiClient = apiClient
    }

    /// Initialize with a StoreSubmitter (convenience)
    /// - Parameters:
    ///   - submitter: The store submitter
    ///   - apiClient: The API client to use (default: shared)
    init(submitter: StoreSubmitter, apiClient: APIClient = .shared) {
        self.userId = submitter.id
        self.apiClient = apiClient
    }

    /// Initialize with a ReviewUser (convenience)
    /// - Parameters:
    ///   - reviewUser: The review user
    ///   - apiClient: The API client to use (default: shared)
    init(reviewUser: ReviewUser, apiClient: APIClient = .shared) {
        self.userId = reviewUser.id
        self.apiClient = apiClient
    }

    // MARK: - Data Loading

    /// Check if an error is a cancellation error (should be ignored)
    private func isCancellationError(_ error: Error) -> Bool {
        if (error as NSError).code == NSURLErrorCancelled {
            return true
        }
        if error is CancellationError {
            return true
        }
        return false
    }

    /// Load all profile data
    func loadData() async {
        await loadProfile()
    }

    /// Load the user profile
    private func loadProfile() async {
        isLoadingProfile = true
        error = nil

        do {
            profile = try await apiClient.getUserProfile(userId: userId)

            // Initialize stores and reviews from the profile response
            if let profile = profile {
                stores = profile.submittedStores
                reviews = profile.reviews

                // Determine if there are more pages based on stats vs loaded count
                hasMoreStores = profile.submittedStores.count < profile.stats.storesCount
                hasMoreReviews = profile.reviews.count < profile.stats.reviewsCount
            }
        } catch {
            // Ignore cancellation errors
            guard !isCancellationError(error) else {
                isLoadingProfile = false
                return
            }
            self.error = error
            showError = true
        }

        isLoadingProfile = false
    }

    /// Refresh all data (pull to refresh)
    func refresh() async {
        // Prevent concurrent refreshes
        guard !isRefreshing else { return }
        isRefreshing = true
        storesPage = 1
        reviewsPage = 1
        await loadProfile()
        isRefreshing = false
    }

    // MARK: - Stores Pagination

    /// Load more stores (pagination)
    func loadMoreStores() async {
        guard !isLoadingMoreStores && hasMoreStores else { return }

        isLoadingMoreStores = true
        storesPage += 1

        do {
            let response = try await apiClient.getUserStores(userId: userId, page: storesPage)
            stores.append(contentsOf: response.data)
            hasMoreStores = response.meta.hasNextPage
        } catch {
            self.error = error
            storesPage -= 1 // Revert on error
        }

        isLoadingMoreStores = false
    }

    // MARK: - Reviews Pagination

    /// Load more reviews (pagination)
    func loadMoreReviews() async {
        guard !isLoadingMoreReviews && hasMoreReviews else { return }

        isLoadingMoreReviews = true
        reviewsPage += 1

        do {
            let response = try await apiClient.getUserReviews(userId: userId, page: reviewsPage)
            reviews.append(contentsOf: response.data)
            hasMoreReviews = response.meta.hasNextPage
        } catch {
            self.error = error
            reviewsPage -= 1 // Revert on error
        }

        isLoadingMoreReviews = false
    }

    // MARK: - Computed Properties

    /// Display name with fallback
    var displayName: String {
        profile?.name ?? "User"
    }

    /// User initials for avatar
    var initials: String {
        profile?.initials ?? "?"
    }

    /// Stats for display
    var storesCount: Int {
        profile?.stats.storesCount ?? 0
    }

    var reviewsCount: Int {
        profile?.stats.reviewsCount ?? 0
    }

    /// Formatted member since date
    var memberSinceText: String? {
        profile?.formattedMemberSince
    }
}
