import Foundation
import Security

// MARK: - Keychain Service

/// A service that provides secure storage for sensitive data using iOS Keychain
/// This replaces insecure UserDefaults storage for auth tokens and other credentials
final class KeychainService {
    static let shared = KeychainService()

    private let service = Bundle.main.bundleIdentifier ?? "com.preuvely.app"

    // Keychain keys
    private enum Keys {
        static let authToken = "auth_token"
        static let refreshToken = "refresh_token"
        static let userData = "user_data"
    }

    private init() {}

    // MARK: - Auth Token Methods

    /// Saves the authentication token securely in the Keychain
    /// - Parameter token: The auth token to store
    /// - Returns: Boolean indicating success
    @discardableResult
    func saveToken(_ token: String) -> Bool {
        return save(key: Keys.authToken, data: Data(token.utf8))
    }

    /// Retrieves the authentication token from Keychain
    /// - Returns: The stored auth token, or nil if not found
    func getToken() -> String? {
        guard let data = load(key: Keys.authToken) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Deletes the authentication token from Keychain
    @discardableResult
    func deleteToken() -> Bool {
        return delete(key: Keys.authToken)
    }

    // MARK: - Refresh Token Methods (for future use)

    /// Saves the refresh token securely in the Keychain
    /// - Parameter token: The refresh token to store
    /// - Returns: Boolean indicating success
    @discardableResult
    func saveRefreshToken(_ token: String) -> Bool {
        return save(key: Keys.refreshToken, data: Data(token.utf8))
    }

    /// Retrieves the refresh token from Keychain
    /// - Returns: The stored refresh token, or nil if not found
    func getRefreshToken() -> String? {
        guard let data = load(key: Keys.refreshToken) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Deletes the refresh token from Keychain
    @discardableResult
    func deleteRefreshToken() -> Bool {
        return delete(key: Keys.refreshToken)
    }

    // MARK: - User Data Methods

    /// Saves user data securely in the Keychain
    /// - Parameter userData: Encodable user data to store
    /// - Returns: Boolean indicating success
    @discardableResult
    func saveUserData<T: Encodable>(_ userData: T) -> Bool {
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let data = try encoder.encode(userData)
            return save(key: Keys.userData, data: data)
        } catch {
            #if DEBUG
            print("[Keychain] Failed to encode user data: \(error)")
            #endif
            return false
        }
    }

    /// Retrieves user data from Keychain
    /// - Returns: The decoded user data, or nil if not found
    func getUserData<T: Decodable>(_ type: T.Type) -> T? {
        guard let data = load(key: Keys.userData) else { return nil }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(type, from: data)
        } catch {
            #if DEBUG
            print("[Keychain] Failed to decode user data: \(error)")
            #endif
            return nil
        }
    }

    /// Deletes user data from Keychain
    @discardableResult
    func deleteUserData() -> Bool {
        return delete(key: Keys.userData)
    }

    // MARK: - Clear All

    /// Clears all stored credentials and user data from Keychain
    /// Use this for complete logout
    func clearAll() {
        deleteToken()
        deleteRefreshToken()
        deleteUserData()

        // Also clean up any legacy UserDefaults token storage
        migrateFromUserDefaults()
    }

    // MARK: - Migration

    /// Migrates token from UserDefaults to Keychain (one-time migration)
    /// Call this once on app startup to migrate existing users
    func migrateFromUserDefaults() {
        let userDefaults = UserDefaults.standard

        // Migrate auth token if it exists in UserDefaults
        if let legacyToken = userDefaults.string(forKey: "auth_token") {
            // Save to Keychain
            if saveToken(legacyToken) {
                // Remove from UserDefaults after successful migration
                userDefaults.removeObject(forKey: "auth_token")
                #if DEBUG
                print("[Keychain] Successfully migrated auth token from UserDefaults to Keychain")
                #endif
            }
        }
    }

    // MARK: - Private Keychain Operations

    private func save(key: String, data: Data) -> Bool {
        // Delete any existing item first
        delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        #if DEBUG
        if status != errSecSuccess {
            print("[Keychain] Save failed for key '\(key)' with status: \(status)")
        }
        #endif

        return status == errSecSuccess
    }

    private func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            #if DEBUG
            if status != errSecItemNotFound {
                print("[Keychain] Load failed for key '\(key)' with status: \(status)")
            }
            #endif
            return nil
        }

        return result as? Data
    }

    @discardableResult
    private func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        // errSecItemNotFound is acceptable - item may not exist
        return status == errSecSuccess || status == errSecItemNotFound
    }
}

// MARK: - Keychain Error

enum KeychainError: LocalizedError {
    case saveFailed(OSStatus)
    case loadFailed(OSStatus)
    case deleteFailed(OSStatus)
    case dataConversionFailed

    var errorDescription: String? {
        switch self {
        case .saveFailed(let status):
            return "Failed to save to Keychain (status: \(status))"
        case .loadFailed(let status):
            return "Failed to load from Keychain (status: \(status))"
        case .deleteFailed(let status):
            return "Failed to delete from Keychain (status: \(status))"
        case .dataConversionFailed:
            return "Failed to convert data"
        }
    }
}
