import Foundation

/// Service for caching API responses locally for offline support
final class CacheService {
    static let shared = CacheService()

    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    // Cache keys
    enum CacheKey: String {
        case categories = "cached_categories"
        case banners = "cached_banners"
        case trendingStores = "cached_trending_stores"
        case topRatedStores = "cached_top_rated_stores"
    }

    private init() {
        // Get cache directory
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("PreuvelyCache")

        // Create cache directory if needed
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Generic Save/Load

    /// Save data to cache
    func save<T: Encodable>(_ data: T, for key: CacheKey) {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601

        do {
            let jsonData = try encoder.encode(data)
            let fileURL = cacheDirectory.appendingPathComponent("\(key.rawValue).json")
            try jsonData.write(to: fileURL)

            #if DEBUG
            print("[Cache] Saved \(key.rawValue)")
            #endif
        } catch {
            #if DEBUG
            print("[Cache] Failed to save \(key.rawValue): \(error)")
            #endif
        }
    }

    /// Load data from cache
    func load<T: Decodable>(_ type: T.Type, for key: CacheKey) -> T? {
        let fileURL = cacheDirectory.appendingPathComponent("\(key.rawValue).json")

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601

            let result = try decoder.decode(T.self, from: data)

            #if DEBUG
            print("[Cache] Loaded \(key.rawValue)")
            #endif

            return result
        } catch {
            #if DEBUG
            print("[Cache] Failed to load \(key.rawValue): \(error)")
            #endif
            return nil
        }
    }

    /// Check if cache exists for key
    func hasCache(for key: CacheKey) -> Bool {
        let fileURL = cacheDirectory.appendingPathComponent("\(key.rawValue).json")
        return fileManager.fileExists(atPath: fileURL.path)
    }

    /// Clear specific cache
    func clear(for key: CacheKey) {
        let fileURL = cacheDirectory.appendingPathComponent("\(key.rawValue).json")
        try? fileManager.removeItem(at: fileURL)
    }

    /// Clear all cache
    func clearAll() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Convenience Methods

    // Categories
    func saveCategories(_ categories: [Category]) {
        save(categories, for: .categories)
    }

    func loadCategories() -> [Category]? {
        load([Category].self, for: .categories)
    }

    // Banners
    func saveBanners(_ banners: [Banner]) {
        save(banners, for: .banners)
    }

    func loadBanners() -> [Banner]? {
        load([Banner].self, for: .banners)
    }

    // Trending Stores
    func saveTrendingStores(_ stores: [Store]) {
        save(stores, for: .trendingStores)
    }

    func loadTrendingStores() -> [Store]? {
        load([Store].self, for: .trendingStores)
    }

    // Top Rated Stores
    func saveTopRatedStores(_ stores: [Store]) {
        save(stores, for: .topRatedStores)
    }

    func loadTopRatedStores() -> [Store]? {
        load([Store].self, for: .topRatedStores)
    }
}
