import Foundation
import UIKit
import Combine

// MARK: - API Client

/// Main API client for making network requests to the Preuvely backend
@MainActor
final class APIClient: ObservableObject {
    static let shared = APIClient()

    // Auth state
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false

    private let session: URLSession
    private var authToken: String?

    private let keychain = KeychainService.shared

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = APIConfig.timeoutInterval
        config.timeoutIntervalForResource = APIConfig.timeoutInterval
        self.session = URLSession(configuration: config)

        // Migrate any existing tokens from UserDefaults to Keychain (one-time)
        keychain.migrateFromUserDefaults()

        // Load saved token on init
        loadAuthToken()
    }

    // MARK: - Token Management

    private func loadAuthToken() {
        authToken = keychain.getToken()
        isAuthenticated = authToken != nil
    }

    private func saveAuthToken(_ token: String) {
        authToken = token
        keychain.saveToken(token)
        isAuthenticated = true
    }

    private func clearAuthToken() {
        authToken = nil
        keychain.deleteToken()
        keychain.deleteUserData()
        isAuthenticated = false
        currentUser = nil
    }

    // MARK: - Request Building

    private func buildRequest(
        endpoint: APIEndpoint,
        method: HTTPMethod,
        body: Encodable? = nil,
        queryItems: [URLQueryItem]? = nil
    ) throws -> URLRequest {
        var urlComponents = URLComponents(url: endpoint.url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = queryItems

        guard let url = urlComponents?.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        // Add default headers
        for (key, value) in APIConfig.defaultHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Add auth token if available
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Add body if present
        if let body = body {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            request.httpBody = try encoder.encode(body)
        }

        return request
    }

    // MARK: - Response Handling

    private func handleResponse<T: Decodable>(_ data: Data, _ response: URLResponse) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Debug logging
        #if DEBUG
        print("[API] Response status: \(httpResponse.statusCode)")
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
            print("[API] Response body: \(json)")
        }
        #endif

        switch httpResponse.statusCode {
        case 200...299:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                #if DEBUG
                print("[API] Decode error: \(error)")
                if let json = String(data: data, encoding: .utf8) {
                    print("[API] Raw JSON: \(json.prefix(1000))")
                }
                #endif
                throw error
            }

        case 401:
            clearAuthToken()
            throw APIError.unauthorized

        case 403:
            throw APIError.forbidden

        case 404:
            throw APIError.notFound

        case 409:
            // Check if this is a duplicate store error with existing store data
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            if let duplicateResponse = try? decoder.decode(DuplicateStoreErrorResponse.self, from: data) {
                throw APIError.duplicateStore(existingStore: duplicateResponse.existingStore)
            }
            throw APIError.conflict

        case 422:
            // Validation error - try to parse message
            if let errorResponse = try? JSONDecoder().decode(ValidationErrorResponse.self, from: data) {
                throw APIError.validation(errorResponse.message)
            }
            throw APIError.validation("Validation failed")

        case 500...599:
            throw APIError.serverError

        default:
            throw APIError.unknown(httpResponse.statusCode)
        }
    }

    // MARK: - Generic Request Methods

    func get<T: Decodable>(
        _ endpoint: APIEndpoint,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        let request = try buildRequest(endpoint: endpoint, method: .get, queryItems: queryItems)

        #if DEBUG
        print("[API] GET \(request.url?.absoluteString ?? "")")
        #endif

        let (data, response) = try await session.data(for: request)
        return try handleResponse(data, response)
    }

    func post<T: Decodable, B: Encodable>(
        _ endpoint: APIEndpoint,
        body: B
    ) async throws -> T {
        let request = try buildRequest(endpoint: endpoint, method: .post, body: body)

        #if DEBUG
        print("[API] POST \(request.url?.absoluteString ?? "")")
        #endif

        let (data, response) = try await session.data(for: request)
        return try handleResponse(data, response)
    }

    func post<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let request = try buildRequest(endpoint: endpoint, method: .post)

        #if DEBUG
        print("[API] POST \(request.url?.absoluteString ?? "")")
        #endif

        let (data, response) = try await session.data(for: request)
        return try handleResponse(data, response)
    }

    func postEmpty<B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws {
        let request = try buildRequest(endpoint: endpoint, method: .post, body: body)

        #if DEBUG
        print("[API] POST \(request.url?.absoluteString ?? "")")
        #endif

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            if let httpResponse = response as? HTTPURLResponse {
                throw APIError.unknown(httpResponse.statusCode)
            }
            throw APIError.invalidResponse
        }
    }

    func postEmpty(_ endpoint: APIEndpoint) async throws {
        let request = try buildRequest(endpoint: endpoint, method: .post)

        #if DEBUG
        print("[API] POST \(request.url?.absoluteString ?? "")")
        #endif

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            if let httpResponse = response as? HTTPURLResponse {
                throw APIError.unknown(httpResponse.statusCode)
            }
            throw APIError.invalidResponse
        }
    }

    func patch<T: Decodable, B: Encodable>(
        _ endpoint: APIEndpoint,
        body: B
    ) async throws -> T {
        let request = try buildRequest(endpoint: endpoint, method: .patch, body: body)

        #if DEBUG
        print("[API] PATCH \(request.url?.absoluteString ?? "")")
        #endif

        let (data, response) = try await session.data(for: request)
        return try handleResponse(data, response)
    }

    func delete(_ endpoint: APIEndpoint) async throws {
        let request = try buildRequest(endpoint: endpoint, method: .delete)

        #if DEBUG
        print("[API] DELETE \(request.url?.absoluteString ?? "")")
        #endif

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            if let httpResponse = response as? HTTPURLResponse {
                throw APIError.unknown(httpResponse.statusCode)
            }
            throw APIError.invalidResponse
        }
    }

    func put<T: Decodable, B: Encodable>(
        _ endpoint: APIEndpoint,
        body: B
    ) async throws -> T {
        let request = try buildRequest(endpoint: endpoint, method: .put, body: body)

        #if DEBUG
        print("[API] PUT \(request.url?.absoluteString ?? "")")
        #endif

        let (data, response) = try await session.data(for: request)
        return try handleResponse(data, response)
    }

    // MARK: - Multipart Upload

    /// Dedicated session for uploads with longer timeouts
    private static let uploadSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120
        config.timeoutIntervalForResource = 300
        // Use HTTP/1.1 for more reliable uploads
        config.httpAdditionalHeaders = ["Connection": "keep-alive"]
        return URLSession(configuration: config)
    }()

    func uploadImage<T: Decodable>(
        _ endpoint: APIEndpoint,
        image: UIImage,
        fieldName: String = "image",
        maxRetries: Int = 3
    ) async throws -> T {
        // Resize image aggressively (max 512px for avatars to keep under 500KB)
        let resizedImage = image.resizedForUpload(maxDimension: 512)

        // Use aggressive compression for reliable upload
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.5) else {
            throw APIError.invalidData
        }

        #if DEBUG
        print("[API] Image size for upload: \(imageData.count / 1024) KB")
        #endif

        let boundary = UUID().uuidString

        var request = URLRequest(url: endpoint.url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 120 // 2 minute timeout for uploads

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        #if DEBUG
        print("[API] UPLOAD \(request.url?.absoluteString ?? "") (using HTTP/1.1)")
        #endif

        // Retry logic for network issues - use dedicated upload session without HTTP/3
        var lastError: Error?
        for attempt in 1...maxRetries {
            do {
                let (data, response) = try await Self.uploadSession.data(for: request)
                return try handleResponse(data, response)
            } catch {
                lastError = error
                let nsError = error as NSError
                // Retry on network connection errors (-1005, -1009, -1017, etc.)
                let retryableCodes = [
                    NSURLErrorNetworkConnectionLost,
                    NSURLErrorNotConnectedToInternet,
                    NSURLErrorTimedOut,
                    NSURLErrorCannotParseResponse
                ]
                if nsError.domain == NSURLErrorDomain && retryableCodes.contains(nsError.code) {
                    #if DEBUG
                    print("[API] Upload attempt \(attempt) failed, retrying... Error: \(error.localizedDescription)")
                    #endif
                    // Wait before retrying (exponential backoff)
                    try? await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt))) * 1_000_000_000)
                    continue
                }
                throw error
            }
        }
        throw lastError ?? APIError.serverError
    }
}

// MARK: - UIImage Extension for Resizing

extension UIImage {
    func resizedForUpload(maxDimension: CGFloat) -> UIImage {
        let currentMax = max(size.width, size.height)
        guard currentMax > maxDimension else { return self }

        let scale = maxDimension / currentMax
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

// MARK: - Category Service

extension APIClient: CategoryServiceProtocol {
    func getCategories() async throws -> [Category] {
        let response: APIListResponse<Category> = try await get(.categories)
        return response.data
    }

    func getCategory(slug: String) async throws -> Category {
        let response: APISingleResponse<Category> = try await get(.category(slug: slug))
        return response.data
    }
}

// MARK: - Store Service

extension APIClient: StoreServiceProtocol {
    func searchStores(
        query: String?,
        category: String?,
        verifiedOnly: Bool,
        sortBy: StoreSortOption,
        page: Int,
        perPage: Int
    ) async throws -> PaginatedResponse<Store> {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]

        if let query = query, !query.isEmpty {
            queryItems.append(URLQueryItem(name: "q", value: query))
        }

        if let category = category, !category.isEmpty {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }

        if verifiedOnly {
            queryItems.append(URLQueryItem(name: "verified", value: "true"))
        }

        // Note: Backend sorts by rating/reviews_count by default.
        // Sort option is handled via default ordering in the API.
        return try await get(.storeSearch, queryItems: queryItems)
    }

    func getStore(slug: String) async throws -> Store {
        let response: APISingleResponse<Store> = try await get(.store(slug: slug))
        return response.data
    }

    func getStoreSummary(slug: String) async throws -> StoreSummary {
        let response: APISingleResponse<StoreSummary> = try await get(.storeSummary(slug: slug))
        return response.data
    }

    func getStoreReviews(storeId: Int, page: Int, perPage: Int) async throws -> PaginatedResponse<Review> {
        let queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]
        return try await get(.storeReviews(storeId: storeId), queryItems: queryItems)
    }

    func getMyReviews(page: Int = 1, perPage: Int = 15) async throws -> PaginatedResponse<Review> {
        let queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]
        return try await get(.myReviews, queryItems: queryItems)
    }

    func createStore(request: CreateStoreRequest, logo: UIImage?) async throws -> Store {
        if let logo = logo {
            // Use multipart form data when logo is provided
            let response: CreateStoreResponse = try await uploadStoreWithLogo(request: request, logo: logo)
            return response.data
        } else {
            // Regular JSON POST when no logo
            let response: CreateStoreResponse = try await post(.createStore, body: request)
            return response.data
        }
    }

    private func uploadStoreWithLogo(request: CreateStoreRequest, logo: UIImage) async throws -> CreateStoreResponse {
        let boundary = UUID().uuidString

        var urlRequest = URLRequest(url: APIEndpoint.createStore.url)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = authToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        var body = Data()

        // Add text fields
        body.appendMultipartField(name: "name", value: request.name, boundary: boundary)

        if let description = request.description {
            body.appendMultipartField(name: "description", value: description, boundary: boundary)
        }

        if let city = request.city {
            body.appendMultipartField(name: "city", value: city, boundary: boundary)
        }

        // Add category IDs
        for (index, categoryId) in request.categoryIds.enumerated() {
            body.appendMultipartField(name: "category_ids[\(index)]", value: String(categoryId), boundary: boundary)
        }

        // Add links
        for (index, link) in request.links.enumerated() {
            body.appendMultipartField(name: "links[\(index)][platform]", value: link.platform.rawValue, boundary: boundary)
            body.appendMultipartField(name: "links[\(index)][url]", value: link.url, boundary: boundary)
            if let handle = link.handle {
                body.appendMultipartField(name: "links[\(index)][handle]", value: handle, boundary: boundary)
            }
        }

        // Add contacts
        if let contacts = request.contacts {
            if let whatsapp = contacts.whatsapp {
                body.appendMultipartField(name: "contacts[whatsapp]", value: whatsapp, boundary: boundary)
            }
            if let phone = contacts.phone {
                body.appendMultipartField(name: "contacts[phone]", value: phone, boundary: boundary)
            }
        }

        // Add logo image
        if let imageData = logo.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"logo\"; filename=\"logo.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        urlRequest.httpBody = body

        #if DEBUG
        print("[API] UPLOAD STORE \(urlRequest.url?.absoluteString ?? "")")
        #endif

        let (data, response) = try await session.data(for: urlRequest)
        return try handleResponse(data, response)
    }

    func getTrendingStores() async throws -> [Store] {
        // Use search endpoint with most_reviewed sorting
        let queryItems = [
            URLQueryItem(name: "sort_by", value: "most_reviewed"),
            URLQueryItem(name: "per_page", value: "5")
        ]
        let response: PaginatedResponse<Store> = try await get(.storeSearch, queryItems: queryItems)
        return response.data
    }

    func getTopRatedStores() async throws -> [Store] {
        // Use search endpoint with best_rated sorting
        let queryItems = [
            URLQueryItem(name: "sort_by", value: "best_rated"),
            URLQueryItem(name: "per_page", value: "6")
        ]
        let response: PaginatedResponse<Store> = try await get(.storeSearch, queryItems: queryItems)
        return response.data
    }
}

// MARK: - Review Service

extension APIClient: ReviewServiceProtocol {
    func createReview(storeId: Int, request: CreateReviewRequest) async throws -> Review {
        let response: CreateReviewResponse = try await post(.createReview(storeId: storeId), body: request)
        return response.data
    }

    func uploadProof(reviewId: Int, image: UIImage) async throws -> Proof {
        let response: UploadProofResponse = try await uploadImage(.uploadProof(reviewId: reviewId), image: image, fieldName: "proof")
        return response.data
    }

    func getUserReview(storeId: Int) async throws -> Review? {
        let response: UserReviewResponse = try await get(.userReview(storeId: storeId))
        return response.data
    }

    func replyToReview(reviewId: Int, text: String) async throws -> StoreReply {
        struct ReplyRequest: Encodable {
            let replyText: String
        }
        let response: APISingleResponse<StoreReply> = try await post(.replyToReview(reviewId: reviewId), body: ReplyRequest(replyText: text))
        return response.data
    }
}

// MARK: - Review API Response Types

/// Response for creating a review
struct CreateReviewResponse: Decodable {
    let message: String
    let requiresProof: Bool
    let data: Review
}

/// Response for getting user's review for a store
struct UserReviewResponse: Decodable {
    let hasReviewed: Bool
    let data: Review?
}

/// Response for uploading proof
struct UploadProofResponse: Decodable {
    let message: String
    let data: Proof
}

// MARK: - Store API Response Types

/// Response for creating a store
struct CreateStoreResponse: Decodable {
    let message: String
    let data: Store
}

// MARK: - Auth Service

extension APIClient: AuthServiceProtocol {
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
        let response: AuthResponse = try await post(.register, body: request)
        saveAuthToken(response.token)
        currentUser = response.user
        return response.user
    }

    func login(email: String, password: String) async throws -> User {
        struct LoginRequest: Encodable {
            let email: String
            let password: String
        }
        let response: AuthResponse = try await post(.login, body: LoginRequest(email: email, password: password))
        saveAuthToken(response.token)
        currentUser = response.user
        return response.user
    }

    func logout() async throws {
        try await postEmpty(.logout)
        clearAuthToken()
    }

    func getCurrentUser() async throws -> User? {
        guard authToken != nil else { return nil }

        do {
            // Backend returns {"user": {...}} not {"data": {...}}
            struct MeResponse: Decodable {
                let user: User
            }
            let response: MeResponse = try await get(.currentUser)
            currentUser = response.user
            return response.user
        } catch APIError.unauthorized {
            clearAuthToken()
            return nil
        }
    }

    func resendVerificationEmail() async throws {
        try await postEmpty(.resendVerification)
    }

    func verifyEmailWithCode(_ code: String) async throws -> User {
        struct VerifyCodeRequest: Encodable {
            let code: String
        }
        struct VerifyCodeResponse: Decodable {
            let message: String
            let user: User
        }
        let response: VerifyCodeResponse = try await post(.verifyEmailCode, body: VerifyCodeRequest(code: code))
        currentUser = response.user
        return response.user
    }

    func socialLogin(provider: SocialProvider, idToken: String) async throws -> User {
        struct SocialLoginRequest: Encodable {
            let idToken: String
        }
        let response: AuthResponse = try await post(.socialLogin(provider: provider.rawValue), body: SocialLoginRequest(idToken: idToken))
        saveAuthToken(response.token)
        currentUser = response.user
        return response.user
    }
}

// MARK: - Claim Service

extension APIClient: ClaimServiceProtocol {
    func getMyClaims() async throws -> [Claim] {
        let response: APIListResponse<Claim> = try await get(.claims)
        return response.data
    }

    func submitClaim(storeId: Int, request: CreateClaimRequest) async throws -> Claim {
        let response: APISingleResponse<Claim> = try await post(.submitClaim(storeId: storeId), body: request)
        return response.data
    }
}

// MARK: - Report Service

extension APIClient: ReportServiceProtocol {
    func getMyReports() async throws -> [Report] {
        let response: APIListResponse<Report> = try await get(.reports)
        return response.data
    }

    func submitReport(request: CreateReportRequest) async throws -> Report {
        let response: APISingleResponse<Report> = try await post(.submitReport, body: request)
        return response.data
    }
}

// MARK: - Notification Service

extension APIClient: NotificationServiceProtocol {
    func getNotifications() async throws -> [AppNotification] {
        let response: APIListResponse<AppNotification> = try await get(.notifications)
        return response.data
    }

    func getUnreadCount() async throws -> Int {
        struct UnreadCountResponse: Decodable {
            let unreadCount: Int
        }
        let response: UnreadCountResponse = try await get(.unreadCount)
        return response.unreadCount
    }

    func markAsRead(notificationId: Int) async throws {
        try await postEmpty(.markAsRead(notificationId: notificationId))
    }

    func markAllAsRead() async throws {
        try await postEmpty(.markAllAsRead)
    }

    func deleteNotification(notificationId: Int) async throws {
        try await delete(.deleteNotification(notificationId: notificationId))
    }
}

// MARK: - Banner Service

extension APIClient {
    func getBanners() async throws -> [Banner] {
        let response: APIListResponse<Banner> = try await get(.banners)
        return response.data
    }
}

// MARK: - Store Owner Service

extension APIClient: StoreOwnerServiceProtocol {
    func getMyStores() async throws -> [OwnedStore] {
        let response: APIListResponse<OwnedStore> = try await get(.myStores)
        return response.data
    }

    func updateStore(storeId: Int, request: UpdateStoreRequest) async throws -> Store {
        let response: APISingleResponse<Store> = try await patch(.updateStore(storeId: storeId), body: request)
        return response.data
    }

    func uploadStoreLogo(storeId: Int, image: UIImage) async throws -> Store {
        let response: APISingleResponse<Store> = try await uploadImage(.uploadStoreLogo(storeId: storeId), image: image, fieldName: "logo")
        return response.data
    }

    func getStoreLinks(storeId: Int) async throws -> [StoreLink] {
        let response: APIListResponse<StoreLink> = try await get(.storeLinks(storeId: storeId))
        return response.data
    }

    func updateStoreLinks(storeId: Int, links: [StoreLink]) async throws -> [StoreLink] {
        let request = UpdateStoreLinksRequest(storeLinks: links)
        let response: APIListResponse<StoreLink> = try await put(.updateStoreLinks(storeId: storeId), body: request)
        return response.data
    }
}

// MARK: - Profile Service

extension APIClient {
    /// Update user profile (name and/or phone)
    /// - Parameters:
    ///   - name: The new name (optional)
    ///   - phone: The new phone number (optional)
    /// - Returns: The updated User object
    func updateProfile(name: String?, phone: String?) async throws -> User {
        struct UpdateProfileRequest: Encodable {
            let name: String?
            let phone: String?
        }

        // Backend returns {"message": "...", "user": {...}}
        struct ProfileResponse: Decodable {
            let message: String
            let user: User
        }

        let request = UpdateProfileRequest(name: name, phone: phone)
        let response: ProfileResponse = try await patch(.updateProfile, body: request)
        currentUser = response.user
        return response.user
    }

    /// Upload avatar image
    /// - Parameter image: The UIImage to upload as avatar
    /// - Returns: The updated User object with avatar URL
    func uploadAvatar(image: UIImage) async throws -> User {
        // Backend returns {"message": "...", "user": {...}}
        struct AvatarResponse: Decodable {
            let message: String
            let user: User
        }

        let response: AvatarResponse = try await uploadImage(.uploadAvatar, image: image, fieldName: "avatar")
        currentUser = response.user
        return response.user
    }
}

// MARK: - User Profile Service

extension APIClient {
    /// Get user profile by ID
    /// - Parameter userId: The user ID to fetch
    /// - Returns: The user profile with stats, stores, and reviews
    func getUserProfile(userId: Int) async throws -> UserProfile {
        let response: APISingleResponse<UserProfile> = try await get(.userProfile(userId: userId))
        return response.data
    }

    /// Get stores submitted by a user with pagination
    /// - Parameters:
    ///   - userId: The user ID
    ///   - page: Page number (1-based)
    /// - Returns: Paginated response of stores
    func getUserStores(userId: Int, page: Int) async throws -> PaginatedResponse<Store> {
        let queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: "15")
        ]
        return try await get(.userStores(userId: userId), queryItems: queryItems)
    }

    /// Get reviews written by a user with pagination
    /// - Parameters:
    ///   - userId: The user ID
    ///   - page: Page number (1-based)
    /// - Returns: Paginated response of reviews
    func getUserReviews(userId: Int, page: Int) async throws -> PaginatedResponse<Review> {
        let queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: "15")
        ]
        return try await get(.userReviews(userId: userId), queryItems: queryItems)
    }
}

// MARK: - API Response Types

struct APISingleResponse<T: Decodable>: Decodable {
    let data: T
}

struct APIListResponse<T: Decodable>: Decodable {
    let data: [T]
}

struct AuthResponse: Decodable {
    let user: User
    let token: String
}

struct ValidationErrorResponse: Decodable {
    let message: String
    let errors: [String: [String]]?
}

/// Response for duplicate store error (HTTP 409)
struct DuplicateStoreErrorResponse: Decodable {
    let message: String
    let existingStore: Store
}

// MARK: - API Error

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    case unauthorized
    case forbidden
    case notFound
    case conflict
    case duplicateStore(existingStore: Store)
    case validation(String)
    case serverError
    case networkError(Error)
    case unknown(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .invalidData:
            return "Invalid data"
        case .unauthorized:
            return "Please sign in to continue"
        case .forbidden:
            return "You don't have permission to perform this action"
        case .notFound:
            return "Resource not found"
        case .conflict:
            return "This action has already been performed"
        case .duplicateStore(let store):
            return "A store with similar name or social handle already exists: \(store.name)"
        case .validation(let message):
            return message
        case .serverError:
            return "Server error. Please try again later."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown(let code):
            return "Unknown error (code: \(code))"
        }
    }
}

// MARK: - Data Extension for Multipart

extension Data {
    mutating func appendMultipartField(name: String, value: String, boundary: String) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
        append("\(value)\r\n".data(using: .utf8)!)
    }
}
