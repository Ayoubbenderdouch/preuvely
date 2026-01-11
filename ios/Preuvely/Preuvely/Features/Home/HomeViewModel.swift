import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    // Data
    @Published var banners: [Banner] = []
    @Published var categories: [Category] = []
    @Published var trendingStores: [Store] = []
    @Published var topRatedStores: [Store] = []

    // Loading states
    @Published var isLoadingBanners = false
    @Published var isLoadingCategories = false
    @Published var isLoadingTrending = false
    @Published var isLoadingTopRated = false
    @Published var isRefreshing = false

    // Error state
    @Published var error: Error?

    // Navigation
    @Published var selectedCategory: Category?
    @Published var selectedStore: Store?

    private let apiClient: APIClient
    private let cache = CacheService.shared

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
        // Load cached data immediately
        loadFromCache()
    }

    /// Load data from cache (instant, no network)
    private func loadFromCache() {
        if let cachedCategories = cache.loadCategories() {
            categories = cachedCategories
            #if DEBUG
            print("[HomeViewModel] Loaded \(cachedCategories.count) categories from cache")
            #endif
        }
        if let cachedBanners = cache.loadBanners() {
            banners = cachedBanners
            #if DEBUG
            print("[HomeViewModel] Loaded \(cachedBanners.count) banners from cache")
            #endif
        }
        if let cachedTrending = cache.loadTrendingStores() {
            trendingStores = cachedTrending
            #if DEBUG
            print("[HomeViewModel] Loaded \(cachedTrending.count) trending stores from cache")
            #endif
        }
        if let cachedTopRated = cache.loadTopRatedStores() {
            topRatedStores = cachedTopRated
            #if DEBUG
            print("[HomeViewModel] Loaded \(cachedTopRated.count) top rated stores from cache")
            #endif
        }
    }

    func loadData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadBanners() }
            group.addTask { await self.loadCategories() }
            group.addTask { await self.loadTrendingStores() }
            group.addTask { await self.loadTopRatedStores() }
        }
    }

    func refresh() async {
        // Prevent concurrent refreshes
        guard !isRefreshing else { return }
        isRefreshing = true
        await loadData()
        isRefreshing = false
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

    private func loadBanners() async {
        isLoadingBanners = true
        do {
            let loadedBanners = try await apiClient.getBanners()
            banners = loadedBanners
            cache.saveBanners(loadedBanners)
            #if DEBUG
            print("[HomeViewModel] Loaded \(banners.count) banners")
            #endif
        } catch {
            // Ignore cancellation errors (happen during rapid refresh)
            guard !isCancellationError(error) else {
                isLoadingBanners = false
                return
            }
            #if DEBUG
            print("[HomeViewModel] Banner error: \(error)")
            #endif
            // Only set error if no cached data
            if banners.isEmpty {
                self.error = error
            }
        }
        isLoadingBanners = false
    }

    private func loadCategories() async {
        isLoadingCategories = true
        do {
            let loadedCategories = try await apiClient.getCategories()
            categories = loadedCategories
            cache.saveCategories(loadedCategories)
            #if DEBUG
            print("[HomeViewModel] Loaded \(categories.count) categories")
            #endif
        } catch {
            // Ignore cancellation errors (happen during rapid refresh)
            guard !isCancellationError(error) else {
                isLoadingCategories = false
                return
            }
            #if DEBUG
            print("[HomeViewModel] Categories error: \(error)")
            #endif
            // Only set error if no cached data
            if categories.isEmpty {
                self.error = error
            }
        }
        isLoadingCategories = false
    }

    private func loadTrendingStores() async {
        isLoadingTrending = true
        do {
            let loadedStores = try await apiClient.getTrendingStores()
            trendingStores = loadedStores
            cache.saveTrendingStores(loadedStores)
            #if DEBUG
            print("[HomeViewModel] Loaded \(trendingStores.count) trending stores")
            #endif
        } catch {
            // Ignore cancellation errors (happen during rapid refresh)
            guard !isCancellationError(error) else {
                isLoadingTrending = false
                return
            }
            #if DEBUG
            print("[HomeViewModel] Trending stores error: \(error)")
            #endif
            // Only set error if no cached data
            if trendingStores.isEmpty {
                self.error = error
            }
        }
        isLoadingTrending = false
    }

    private func loadTopRatedStores() async {
        isLoadingTopRated = true
        do {
            // Sort by reviews count (most reviewed first)
            let stores = try await apiClient.getTopRatedStores()
            let sortedStores = stores.sorted { $0.reviewsCount > $1.reviewsCount }
            topRatedStores = sortedStores
            cache.saveTopRatedStores(sortedStores)
            #if DEBUG
            print("[HomeViewModel] Loaded \(topRatedStores.count) top rated stores")
            #endif
        } catch {
            // Ignore cancellation errors (happen during rapid refresh)
            guard !isCancellationError(error) else {
                isLoadingTopRated = false
                return
            }
            #if DEBUG
            print("[HomeViewModel] Top rated stores error: \(error)")
            #endif
            // Only set error if no cached data
            if topRatedStores.isEmpty {
                self.error = error
            }
        }
        isLoadingTopRated = false
    }
}
