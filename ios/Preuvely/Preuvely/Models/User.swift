import Foundation

// MARK: - User

struct User: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let email: String?
    let phone: String?
    let emailVerified: Bool
    let avatar: String?
    let createdAt: Date?

    // Note: Using JSONDecoder with .convertFromSnakeCase strategy

    /// Alias for backward compatibility
    var isEmailVerified: Bool { emailVerified }

    var initials: String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            let first = components[0].prefix(1)
            let last = components[1].prefix(1)
            return "\(first)\(last)".uppercased()
        }
        return name.prefix(2).uppercased()
    }

    var displayEmail: String {
        email ?? "No email"
    }
}

// MARK: - Auth State

enum AuthState: Equatable {
    case guest
    case authenticated(User)
    case emailVerificationPending(User)

    var isAuthenticated: Bool {
        switch self {
        case .authenticated, .emailVerificationPending:
            return true
        case .guest:
            return false
        }
    }

    var user: User? {
        switch self {
        case .authenticated(let user), .emailVerificationPending(let user):
            return user
        case .guest:
            return nil
        }
    }

    var needsEmailVerification: Bool {
        if case .emailVerificationPending = self {
            return true
        }
        return false
    }
}

// MARK: - Preview Data

extension User {
    static let sample = User(
        id: 1,
        name: "Preview User",
        email: "preview@example.com",
        phone: nil,
        emailVerified: true,
        avatar: nil,
        createdAt: Date()
    )
}
