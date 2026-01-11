import Foundation

// MARK: - Environment Configuration

/// API Environment - Change this single line to switch between localhost and production
enum APIEnvironment {
    /// Local development server
    case localhost
    /// Production server
    case production

    var baseURL: URL {
        switch self {
        case .localhost:
            // Use Mac's IP address for iOS Simulator access
            return URL(string: "http://192.168.1.8:8000/api/v1")!
        case .production:
            // TODO: Replace with actual production URL when ready
            return URL(string: "https://api.preuvely.com/api/v1")!
        }
    }

    var name: String {
        switch self {
        case .localhost:
            return "Localhost"
        case .production:
            return "Production"
        }
    }
}

// MARK: - API Configuration

struct APIConfig {
    /// Current environment - CHANGE THIS LINE TO SWITCH ENVIRONMENTS
    static let environment: APIEnvironment = .localhost

    /// Base URL for all API requests
    static var baseURL: URL {
        environment.baseURL
    }

    /// Request timeout interval in seconds
    static let timeoutInterval: TimeInterval = 30

    /// Default headers for all requests
    static var defaultHeaders: [String: String] {
        [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Accept-Language": Locale.current.language.languageCode?.identifier ?? "en"
        ]
    }
}

// MARK: - API Endpoints

enum APIEndpoint {
    // Auth
    case register
    case login
    case logout
    case currentUser
    case updateProfile
    case uploadAvatar
    case resendVerification
    case socialLogin(provider: String)

    // Categories
    case categories
    case category(slug: String)

    // Stores
    case storeSearch
    case store(slug: String)
    case storeSummary(slug: String)
    case storeReviews(storeId: Int)
    case trendingStores
    case topRatedStores
    case createStore

    // Reviews
    case myReviews
    case createReview(storeId: Int)
    case uploadProof(reviewId: Int)
    case userReview(storeId: Int)
    case replyToReview(reviewId: Int)

    // Claims
    case claims
    case submitClaim(storeId: Int)

    // Reports
    case reports
    case submitReport

    // Notifications
    case notifications
    case unreadCount
    case markAsRead(notificationId: Int)
    case markAllAsRead
    case deleteNotification(notificationId: Int)

    // Banners
    case banners

    // Store Owner Management
    case myStores
    case updateStore(storeId: Int)
    case uploadStoreLogo(storeId: Int)
    case storeLinks(storeId: Int)
    case updateStoreLinks(storeId: Int)

    // User Profiles
    case userProfile(userId: Int)
    case userStores(userId: Int)
    case userReviews(userId: Int)

    var path: String {
        switch self {
        // Auth
        case .register:
            return "/auth/register"
        case .login:
            return "/auth/login"
        case .logout:
            return "/auth/logout"
        case .currentUser:
            return "/auth/me"
        case .updateProfile:
            return "/auth/profile"
        case .uploadAvatar:
            return "/auth/avatar"
        case .resendVerification:
            return "/auth/email/resend"
        case .socialLogin(let provider):
            return "/auth/social/\(provider)/callback"

        // Categories
        case .categories:
            return "/categories"
        case .category(let slug):
            return "/categories/\(slug)"

        // Stores
        case .storeSearch:
            return "/stores/search"
        case .store(let slug):
            return "/stores/\(slug)"
        case .storeSummary(let slug):
            return "/stores/\(slug)/summary"
        case .storeReviews(let storeId):
            return "/stores/\(storeId)/reviews"
        case .trendingStores:
            return "/stores/trending"
        case .topRatedStores:
            return "/stores/top-rated"
        case .createStore:
            return "/stores"

        // Reviews
        case .myReviews:
            return "/reviews/my"
        case .createReview(let storeId):
            return "/stores/\(storeId)/reviews"
        case .uploadProof(let reviewId):
            return "/reviews/\(reviewId)/proof"
        case .userReview(let storeId):
            return "/stores/\(storeId)/my-review"
        case .replyToReview(let reviewId):
            return "/reviews/\(reviewId)/reply"

        // Claims
        case .claims:
            return "/claims"
        case .submitClaim(let storeId):
            return "/stores/\(storeId)/claim"

        // Reports
        case .reports:
            return "/reports"
        case .submitReport:
            return "/reports"

        // Notifications
        case .notifications:
            return "/notifications"
        case .unreadCount:
            return "/notifications/unread-count"
        case .markAsRead(let notificationId):
            return "/notifications/\(notificationId)/read"
        case .markAllAsRead:
            return "/notifications/mark-all-read"
        case .deleteNotification(let notificationId):
            return "/notifications/\(notificationId)"

        // Banners
        case .banners:
            return "/banners"

        // Store Owner Management
        case .myStores:
            return "/my-stores"
        case .updateStore(let storeId):
            return "/my-stores/\(storeId)"
        case .uploadStoreLogo(let storeId):
            return "/my-stores/\(storeId)/logo"
        case .storeLinks(let storeId):
            return "/my-stores/\(storeId)/links"
        case .updateStoreLinks(let storeId):
            return "/my-stores/\(storeId)/links"

        // User Profiles
        case .userProfile(let userId):
            return "/users/\(userId)"
        case .userStores(let userId):
            return "/users/\(userId)/stores"
        case .userReviews(let userId):
            return "/users/\(userId)/reviews"
        }
    }

    var url: URL {
        APIConfig.baseURL.appendingPathComponent(path)
    }
}

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
