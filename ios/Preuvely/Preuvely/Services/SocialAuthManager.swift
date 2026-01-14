import SwiftUI
import UIKit
import AuthenticationServices
import CryptoKit
import Combine

// MARK: - Social Auth Manager

/// Manages Google and Apple Sign-In authentication flows.
/// Retrieves ID tokens that can be sent to the backend for verification.
@MainActor
final class SocialAuthManager: NSObject, ObservableObject {

    static let shared = SocialAuthManager()

    // MARK: - Published Properties

    @Published var isLoading = false
    @Published var error: Error?

    // MARK: - Private Properties

    private var currentNonce: String?
    private var appleSignInContinuation: CheckedContinuation<String, Error>?

    // MARK: - Google Sign-In Configuration

    /// Your Google iOS Client ID from Google Cloud Console
    /// TODO: Replace with your actual iOS Client ID
    static let googleClientID = "YOUR_GOOGLE_IOS_CLIENT_ID.apps.googleusercontent.com"

    // MARK: - Initialization

    private override init() {
        super.init()
    }

    // MARK: - Google Sign-In

    /// Initiates Google Sign-In flow and returns the ID token.
    ///
    /// **IMPORTANT: GoogleSignIn SDK Setup Required**
    ///
    /// 1. Open Xcode
    /// 2. File → Add Package Dependencies
    /// 3. Enter URL: https://github.com/google/GoogleSignIn-iOS
    /// 4. Add GoogleSignIn to your target
    /// 5. Update `googleClientID` above with your iOS Client ID
    /// 6. Add URL Scheme to Info.plist (reversed client ID)
    ///
    /// - Parameter presentingWindow: The window to present the sign-in UI.
    /// - Returns: The Google ID token string.
    /// - Throws: SocialAuthError if sign-in fails.
    func signInWithGoogle(presentingWindow: UIWindow?) async throws -> String {
        // GoogleSignIn SDK integration
        // Since GoogleSignIn is not installed yet, we throw an informative error
        //
        // When you install GoogleSignIn SDK, uncomment and use this code:
        //
        // import GoogleSignIn
        //
        // guard let presentingViewController = presentingWindow?.rootViewController else {
        //     throw SocialAuthError.noPresentingViewController
        // }
        //
        // let config = GIDConfiguration(clientID: Self.googleClientID)
        // GIDSignIn.sharedInstance.configuration = config
        //
        // let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
        //
        // guard let idToken = result.user.idToken?.tokenString else {
        //     throw SocialAuthError.noIdToken
        // }
        //
        // return idToken

        throw SocialAuthError.sdkNotInstalled(
            message: "Google Sign-In SDK is not installed yet.\n\n" +
            "To enable Google Sign-In:\n" +
            "1. Open Xcode\n" +
            "2. File → Add Package Dependencies\n" +
            "3. Enter: https://github.com/google/GoogleSignIn-iOS\n" +
            "4. Add GoogleSignIn to your target\n" +
            "5. Update googleClientID in SocialAuthManager.swift"
        )
    }

    // MARK: - Apple Sign-In

    /// Initiates Apple Sign-In flow and returns the identity token.
    /// - Returns: The Apple identity token string.
    /// - Throws: SocialAuthError if sign-in fails.
    func signInWithApple() async throws -> String {
        let nonce = try randomNonceString()
        currentNonce = nonce

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self

        return try await withCheckedThrowingContinuation { continuation in
            self.appleSignInContinuation = continuation
            authorizationController.performRequests()
        }
    }

    // MARK: - Helper Methods

    /// Generates a random nonce string for Apple Sign-In.
    /// - Throws: SocialAuthError.nonceGenerationFailed if SecRandomCopyBytes fails
    private func randomNonceString(length: Int = 32) throws -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            throw SocialAuthError.nonceGenerationFailed(status: errorCode)
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }

    /// SHA256 hashes the input string.
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension SocialAuthManager: ASAuthorizationControllerDelegate {

    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                appleSignInContinuation?.resume(throwing: SocialAuthError.invalidCredential)
                appleSignInContinuation = nil
                return
            }

            guard let identityTokenData = appleIDCredential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8) else {
                appleSignInContinuation?.resume(throwing: SocialAuthError.noIdToken)
                appleSignInContinuation = nil
                return
            }

            // Log user info for debugging (optional)
            if let email = appleIDCredential.email {
                print("[Apple Sign-In] Email: \(email)")
            }
            if let fullName = appleIDCredential.fullName {
                print("[Apple Sign-In] Name: \(fullName.givenName ?? "") \(fullName.familyName ?? "")")
            }

            appleSignInContinuation?.resume(returning: identityToken)
            appleSignInContinuation = nil
        }
    }

    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Task { @MainActor in
            if let authError = error as? ASAuthorizationError {
                switch authError.code {
                case .canceled:
                    appleSignInContinuation?.resume(throwing: SocialAuthError.userCancelled)
                case .failed:
                    appleSignInContinuation?.resume(throwing: SocialAuthError.appleSignInFailed(error))
                case .invalidResponse:
                    appleSignInContinuation?.resume(throwing: SocialAuthError.invalidResponse)
                case .notHandled:
                    appleSignInContinuation?.resume(throwing: SocialAuthError.notHandled)
                case .notInteractive:
                    appleSignInContinuation?.resume(throwing: SocialAuthError.notInteractive)
                case .unknown:
                    appleSignInContinuation?.resume(throwing: SocialAuthError.unknown)
                @unknown default:
                    appleSignInContinuation?.resume(throwing: SocialAuthError.appleSignInFailed(error))
                }
            } else {
                appleSignInContinuation?.resume(throwing: SocialAuthError.appleSignInFailed(error))
            }
            appleSignInContinuation = nil
        }
    }
}

// MARK: - Social Auth Error

enum SocialAuthError: LocalizedError {
    case sdkNotInstalled(message: String)
    case noPresentingViewController
    case noIdToken
    case invalidCredential
    case invalidResponse
    case notHandled
    case notInteractive
    case unknown
    case userCancelled
    case googleSignInFailed(Error)
    case appleSignInFailed(Error)
    case nonceGenerationFailed(status: OSStatus)

    var errorDescription: String? {
        switch self {
        case .sdkNotInstalled(let message):
            return message
        case .noPresentingViewController:
            return "No presenting view controller available"
        case .noIdToken:
            return "Could not retrieve ID token"
        case .invalidCredential:
            return "Invalid credential received"
        case .invalidResponse:
            return "Invalid response from authorization"
        case .notHandled:
            return "Authorization request not handled"
        case .notInteractive:
            return "Authorization requires user interaction"
        case .unknown:
            return "An unknown error occurred"
        case .userCancelled:
            return "Sign-in was cancelled"
        case .googleSignInFailed(let error):
            return "Google Sign-In failed: \(error.localizedDescription)"
        case .appleSignInFailed(let error):
            return "Apple Sign-In failed: \(error.localizedDescription)"
        case .nonceGenerationFailed(let status):
            return "Failed to generate secure nonce (OSStatus: \(status))"
        }
    }
}
