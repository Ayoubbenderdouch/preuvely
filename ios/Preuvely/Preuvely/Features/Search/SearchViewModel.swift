import Foundation
import Combine

// MARK: - Search Type

enum SearchType: Equatable {
    case storeName
    case socialHandle(platform: SocialPlatform)
    case phoneNumber
    case url

    enum SocialPlatform: String {
        case tiktok
        case instagram
        case facebook
        case whatsapp
    }
}

@MainActor
final class SearchViewModel: ObservableObject {
    // Search
    @Published var searchQuery = ""
    @Published var stores: [Store] = []
    @Published private(set) var detectedSearchType: SearchType = .storeName

    // Filters
    @Published var selectedCategory: Category?
    @Published var verifiedOnly = false
    @Published var sortOption: StoreSortOption = .bestRated

    // State
    @Published var isLoading = false
    @Published var error: Error?

    private let apiClient: APIClient
    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    var hasActiveFilters: Bool {
        selectedCategory != nil || verifiedOnly || sortOption != .bestRated
    }

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
        setupSearchDebounce()
        setupSearchTypeDetection()
    }

    private func setupSearchDebounce() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                Task {
                    await self?.search()
                }
            }
            .store(in: &cancellables)
    }

    private func setupSearchTypeDetection() {
        $searchQuery
            .removeDuplicates()
            .sink { [weak self] query in
                self?.detectedSearchType = self?.detectSearchType(from: query) ?? .storeName
            }
            .store(in: &cancellables)
    }

    // MARK: - Search Type Detection

    /// Detects the type of search based on the query pattern
    func detectSearchType(from query: String) -> SearchType {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // Check for URL patterns
        if isURL(trimmedQuery) {
            return .url
        }

        // Check for phone number patterns (Algerian numbers)
        if isPhoneNumber(trimmedQuery) {
            // Check if it might be a WhatsApp number
            if trimmedQuery.hasPrefix("+213") || trimmedQuery.hasPrefix("00213") {
                return .socialHandle(platform: .whatsapp)
            }
            return .phoneNumber
        }

        // Check for social media handle patterns
        if trimmedQuery.hasPrefix("@") {
            // Try to detect platform based on context
            // Default to Instagram as it's most common for @ handles
            return .socialHandle(platform: .instagram)
        }

        // Check for TikTok-specific patterns
        if trimmedQuery.contains("tiktok.com") || trimmedQuery.hasPrefix("tiktok:") {
            return .socialHandle(platform: .tiktok)
        }

        // Check for Instagram-specific patterns
        if trimmedQuery.contains("instagram.com") || trimmedQuery.hasPrefix("ig:") {
            return .socialHandle(platform: .instagram)
        }

        // Check for Facebook-specific patterns
        if trimmedQuery.contains("facebook.com") || trimmedQuery.contains("fb.com") || trimmedQuery.hasPrefix("fb:") {
            return .socialHandle(platform: .facebook)
        }

        // Default to store name search
        return .storeName
    }

    /// Checks if the query looks like a URL
    private func isURL(_ query: String) -> Bool {
        if query.hasPrefix("http://") || query.hasPrefix("https://") || query.hasPrefix("www.") {
            return true
        }
        // Check for domain-like patterns
        let domainPattern = #"^[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(\/.*)?$"#
        if let regex = try? NSRegularExpression(pattern: domainPattern),
           regex.firstMatch(in: query, range: NSRange(query.startIndex..., in: query)) != nil {
            return true
        }
        return false
    }

    /// Checks if the query looks like a phone number
    private func isPhoneNumber(_ query: String) -> Bool {
        // Remove common phone number formatting characters
        let digitsOnly = query.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)

        // Algerian phone patterns
        // International: +213 followed by 9 digits
        // Local: 0 followed by 9 digits
        if digitsOnly.hasPrefix("+213") && digitsOnly.count >= 12 {
            return true
        }
        if digitsOnly.hasPrefix("00213") && digitsOnly.count >= 13 {
            return true
        }
        if digitsOnly.hasPrefix("0") && digitsOnly.count >= 10 {
            return true
        }
        // Generic phone number check (mostly digits)
        let digitRatio = Double(digitsOnly.count) / Double(max(query.count, 1))
        return digitRatio > 0.7 && digitsOnly.count >= 8
    }

    /// Normalizes the search query based on detected type for better matching
    func normalizedQuery() -> String {
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        switch detectedSearchType {
        case .socialHandle:
            // Remove @ prefix for handle searches
            return trimmedQuery.hasPrefix("@") ? String(trimmedQuery.dropFirst()) : trimmedQuery

        case .phoneNumber, .socialHandle(platform: .whatsapp):
            // Normalize phone numbers by removing formatting
            return trimmedQuery.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)

        case .url:
            // Remove protocol prefixes for URL searches
            var normalized = trimmedQuery
            normalized = normalized.replacingOccurrences(of: "https://", with: "")
            normalized = normalized.replacingOccurrences(of: "http://", with: "")
            normalized = normalized.replacingOccurrences(of: "www.", with: "")
            return normalized

        case .storeName:
            return trimmedQuery
        }
    }

    func search() async {
        searchTask?.cancel()

        guard !searchQuery.isEmpty || hasActiveFilters else {
            stores = []
            return
        }

        isLoading = true
        error = nil

        searchTask = Task {
            do {
                // Use the normalized query for better search results
                let queryToSearch = searchQuery.isEmpty ? nil : normalizedQuery()

                let response = try await apiClient.searchStores(
                    query: queryToSearch,
                    category: selectedCategory?.slug,
                    verifiedOnly: verifiedOnly,
                    sortBy: sortOption,
                    page: 1,
                    perPage: 20
                )

                if !Task.isCancelled {
                    stores = response.data
                }
            } catch {
                if !Task.isCancelled {
                    self.error = error
                }
            }

            if !Task.isCancelled {
                isLoading = false
            }
        }

        await searchTask?.value
    }

    func resetFilters() {
        selectedCategory = nil
        verifiedOnly = false
        sortOption = .bestRated
    }
}
