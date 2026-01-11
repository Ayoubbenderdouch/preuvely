import Foundation
import Combine

@MainActor
final class StoreDetailsViewModel: ObservableObject {
    /// The full store details (loaded from API for complete data including links/contacts)
    @Published var store: Store
    /// Whether the full store details are still loading
    @Published var isLoadingStore = false

    @Published var summary: StoreSummary?
    @Published var reviews: [Review] = []
    @Published var userReview: Review?

    @Published var isLoadingSummary = false
    @Published var isLoadingReviews = false
    @Published var isLoadingMoreReviews = false
    @Published var hasMoreReviews = false
    @Published var error: Error?

    private let apiClient: APIClient
    private let storeSlug: String
    private var currentPage = 1
    private let perPage = 15
    private var isRefreshing = false

    /// Initialize with a store from search results (may be partial data)
    /// The view model will load the full store details from API
    init(store: Store, apiClient: APIClient = .shared) {
        self.store = store
        self.storeSlug = store.slug
        self.apiClient = apiClient
    }

    /// Initialize with just a slug (for deep links)
    init(slug: String, apiClient: APIClient = .shared) {
        // Create a placeholder store until we load the real one
        self.store = Store(
            id: 0,
            name: "",
            slug: slug,
            description: nil,
            city: nil,
            logo: nil,
            isVerified: false,
            avgRating: 0,
            reviewsCount: 0,
            categories: [],
            links: [],
            contacts: nil,
            createdAt: nil
        )
        self.storeSlug = slug
        self.apiClient = apiClient
    }

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

    func loadData() async {
        // First load store to get the ID, then load other data
        await loadStore()

        // Now load other data in parallel (we have the store ID)
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadSummary() }
            group.addTask { await self.loadReviews() }
            group.addTask { await self.loadUserReview() }
        }
    }

    /// Load full store details from API (includes links, contacts, etc.)
    private func loadStore() async {
        isLoadingStore = true
        do {
            store = try await apiClient.getStore(slug: storeSlug)
        } catch {
            guard !isCancellationError(error) else {
                isLoadingStore = false
                return
            }
            self.error = error
        }
        isLoadingStore = false
    }

    private func loadSummary() async {
        isLoadingSummary = true
        do {
            summary = try await apiClient.getStoreSummary(slug: storeSlug)
        } catch {
            guard !isCancellationError(error) else {
                isLoadingSummary = false
                return
            }
            self.error = error
        }
        isLoadingSummary = false
    }

    private func loadReviews() async {
        guard store.id > 0 else { return }

        isLoadingReviews = true
        currentPage = 1

        do {
            let response = try await apiClient.getStoreReviews(storeId: store.id, page: currentPage, perPage: perPage)
            reviews = response.data
            hasMoreReviews = response.meta.currentPage < response.meta.lastPage
        } catch {
            guard !isCancellationError(error) else {
                isLoadingReviews = false
                return
            }
            self.error = error
        }
        isLoadingReviews = false
    }

    func loadMoreReviews() async {
        guard !isLoadingMoreReviews && hasMoreReviews && store.id > 0 else { return }

        isLoadingMoreReviews = true
        currentPage += 1

        do {
            let response = try await apiClient.getStoreReviews(storeId: store.id, page: currentPage, perPage: perPage)
            reviews.append(contentsOf: response.data)
            hasMoreReviews = response.meta.currentPage < response.meta.lastPage
        } catch {
            guard !isCancellationError(error) else {
                isLoadingMoreReviews = false
                return
            }
            self.error = error
            currentPage -= 1 // Revert on error
        }
        isLoadingMoreReviews = false
    }

    private func loadUserReview() async {
        guard store.id > 0 else { return }

        do {
            userReview = try await apiClient.getUserReview(storeId: store.id)
        } catch {
            // Ignore - user might not have a review or not logged in
        }
    }

    func refreshReviews() async {
        // Prevent concurrent refreshes
        guard !isRefreshing else { return }
        isRefreshing = true
        await loadReviews()
        await loadSummary()
        await loadUserReview()
        isRefreshing = false
    }

    func refreshAll() async {
        // Prevent concurrent refreshes
        guard !isRefreshing else { return }
        isRefreshing = true
        await loadData()
        isRefreshing = false
    }
}
