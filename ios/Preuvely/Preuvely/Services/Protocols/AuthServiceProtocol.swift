import Foundation

// MARK: - Auth Service Protocol

protocol AuthServiceProtocol {
    /// Current auth state
    var authState: AuthState { get }

    /// Register with email
    func register(request: RegisterRequest) async throws -> User

    /// Login with email
    func login(email: String, password: String) async throws -> User

    /// Logout
    func logout() async throws

    /// Get current user
    func getCurrentUser() async throws -> User?

    /// Resend verification email
    func resendVerificationEmail() async throws

    /// Social login (Google/Apple) - returns user
    func socialLogin(provider: SocialProvider, idToken: String) async throws -> User
}

// MARK: - Register Request

struct RegisterRequest: Encodable {
    let name: String
    let email: String
    let password: String
    let passwordConfirmation: String

    enum CodingKeys: String, CodingKey {
        case name, email, password
        case passwordConfirmation = "password_confirmation"
    }
}

// MARK: - Social Provider

enum SocialProvider: String {
    case google
    case apple
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case invalidCredentials
    case emailNotVerified
    case networkError
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Invalid email or password"
        case .emailNotVerified: return "Please verify your email"
        case .networkError: return "Network error. Please try again."
        case .unknown: return "An unknown error occurred"
        }
    }
}
