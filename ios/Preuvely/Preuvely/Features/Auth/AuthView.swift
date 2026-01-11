import SwiftUI
import Combine

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Logo
                    logoSection

                    // Tab selector
                    authTabSelector

                    // Form
                    if viewModel.isLogin {
                        loginForm
                    } else {
                        registerForm
                    }

                    // Divider
                    dividerSection

                    // Social buttons
                    socialButtons

                    // Switch mode
                    switchModeButton
                }
                .padding(Spacing.screenPadding)
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .alert(L10n.Common.error.localized, isPresented: $viewModel.showError) {
                Button(L10n.Common.ok.localized, role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .loadingOverlay(viewModel.isLoading)
            .onChange(of: viewModel.isAuthenticated) { _, isAuth in
                if isAuth {
                    dismiss()
                }
            }
        }
    }

    // MARK: - Logo Section

    private var logoSection: some View {
        VStack(spacing: Spacing.sm) {
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .cornerRadius(Spacing.radiusMedium)

            Text("Preuvely")
                .font(.title.weight(.bold))
                .foregroundColor(.primary)

            Text(L10n.Auth.trustThroughProof.localized)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, Spacing.lg)
    }

    // MARK: - Tab Selector

    private var authTabSelector: some View {
        HStack(spacing: 0) {
            AuthTabButton(
                title: L10n.Auth.signIn.localized,
                isSelected: viewModel.isLogin
            ) {
                withAnimation {
                    viewModel.isLogin = true
                }
            }

            AuthTabButton(
                title: L10n.Auth.signUp.localized,
                isSelected: !viewModel.isLogin
            ) {
                withAnimation {
                    viewModel.isLogin = false
                }
            }
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(Spacing.radiusMedium)
    }

    // MARK: - Login Form

    private var loginForm: some View {
        VStack(spacing: Spacing.lg) {
            PreuvelyTextField(
                title: L10n.Auth.email.localized,
                text: $viewModel.email,
                placeholder: "you@example.com",
                icon: "envelope.fill",
                keyboardType: .emailAddress,
                autocapitalization: .never
            )

            PreuvelyTextField(
                title: L10n.Auth.password.localized,
                text: $viewModel.password,
                placeholder: "••••••••",
                icon: "lock.fill",
                isSecure: true
            )

            HStack {
                Spacer()
                Button(L10n.Auth.forgotPassword.localized) {
                    // Handle forgot password
                }
                .font(.footnote)
                .foregroundColor(.primaryGreen)
            }

            Button {
                Task {
                    await viewModel.login()
                }
            } label: {
                Text(L10n.Auth.signIn.localized)
            }
            .primaryButtonStyle()
            .disabled(!viewModel.isLoginValid)
        }
    }

    // MARK: - Register Form

    private var registerForm: some View {
        VStack(spacing: Spacing.lg) {
            PreuvelyTextField(
                title: L10n.Auth.name.localized,
                text: $viewModel.name,
                placeholder: L10n.Auth.namePlaceholder.localized,
                icon: "person.fill"
            )

            PreuvelyTextField(
                title: L10n.Auth.email.localized,
                text: $viewModel.email,
                placeholder: "you@example.com",
                icon: "envelope.fill",
                keyboardType: .emailAddress,
                autocapitalization: .never
            )

            PreuvelyTextField(
                title: L10n.Auth.password.localized,
                text: $viewModel.password,
                placeholder: L10n.Auth.passwordMinCharacters.localized,
                icon: "lock.fill",
                isSecure: true
            )

            PreuvelyTextField(
                title: L10n.Auth.confirmPassword.localized,
                text: $viewModel.confirmPassword,
                placeholder: "••••••••",
                icon: "lock.fill",
                isSecure: true
            )

            if viewModel.password != viewModel.confirmPassword && !viewModel.confirmPassword.isEmpty {
                Text(L10n.Auth.passwordsDoNotMatch.localized)
                    .font(.caption)
                    .foregroundColor(.red)
            }

            Button {
                Task {
                    await viewModel.register()
                }
            } label: {
                Text(L10n.Auth.signUp.localized)
            }
            .primaryButtonStyle()
            .disabled(!viewModel.isRegisterValid)
        }
    }

    // MARK: - Divider

    private var dividerSection: some View {
        HStack {
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 1)

            Text(L10n.Auth.orContinueWith.localized)
                .font(.caption)
                .foregroundColor(.secondary)

            Rectangle()
                .fill(Color(.separator))
                .frame(height: 1)
        }
    }

    // MARK: - Social Buttons

    private var socialButtons: some View {
        VStack(spacing: Spacing.md) {
            // Google
            Button {
                Task {
                    await viewModel.socialLogin(provider: .google)
                }
            } label: {
                HStack(spacing: Spacing.sm) {
                    Image("google")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    Text(L10n.Auth.signInWithGoogle.localized)
                        .font(.subheadline.weight(.medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(Color(.secondarySystemBackground))
                .foregroundColor(.primary)
                .cornerRadius(Spacing.radiusMedium)
            }
            .buttonStyle(.plain)

            // Apple
            Button {
                Task {
                    await viewModel.socialLogin(provider: .apple)
                }
            } label: {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 20))
                    Text(L10n.Auth.signInWithApple.localized)
                        .font(.subheadline.weight(.medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(Color.primary)
                .foregroundColor(Color(.systemBackground))
                .cornerRadius(Spacing.radiusMedium)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Switch Mode Button

    private var switchModeButton: some View {
        HStack {
            Text(viewModel.isLogin ? L10n.Auth.noAccount.localized : L10n.Auth.haveAccount.localized)
                .font(.footnote)
                .foregroundColor(.secondary)

            Button {
                withAnimation {
                    viewModel.isLogin.toggle()
                }
            } label: {
                Text(viewModel.isLogin ? L10n.Auth.signUp.localized : L10n.Auth.signIn.localized)
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.primaryGreen)
            }
        }
        .padding(.top, Spacing.md)
    }
}

// MARK: - Auth Tab Button

struct AuthTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(isSelected ? Color.primaryGreen : Color.clear)
                .cornerRadius(Spacing.radiusMedium)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Auth ViewModel

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isLogin = true
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""

    @Published var isLoading = false
    @Published var isAuthenticated = false
    @Published var showError = false
    @Published var errorMessage = ""

    private let apiClient: APIClient

    var isLoginValid: Bool {
        !email.isEmpty && password.count >= 6
    }

    var isRegisterValid: Bool {
        !name.isEmpty && !email.isEmpty && password.count >= 8 && password == confirmPassword
    }

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func login() async {
        isLoading = true

        do {
            _ = try await apiClient.login(email: email, password: password)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    func register() async {
        isLoading = true

        do {
            let request = RegisterRequest(
                name: name,
                email: email,
                password: password,
                passwordConfirmation: confirmPassword
            )
            _ = try await apiClient.register(request: request)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    /// Handles social login for Google and Apple Sign-In.
    /// - Parameter provider: The social provider (.google or .apple)
    func socialLogin(provider: SocialProvider) async {
        isLoading = true

        do {
            let idToken: String

            switch provider {
            case .google:
                // Get the current window for presenting Google Sign-In
                let window = await MainActor.run {
                    UIApplication.shared.connectedScenes
                        .compactMap { $0 as? UIWindowScene }
                        .flatMap { $0.windows }
                        .first { $0.isKeyWindow }
                }
                idToken = try await SocialAuthManager.shared.signInWithGoogle(presentingWindow: window)

            case .apple:
                idToken = try await SocialAuthManager.shared.signInWithApple()
            }

            // Send ID token to backend for verification
            _ = try await apiClient.socialLogin(provider: provider, idToken: idToken)
            isAuthenticated = true

        } catch let error as SocialAuthError {
            if case .userCancelled = error {
                // User cancelled - don't show error
            } else {
                errorMessage = error.localizedDescription
                showError = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }
}

// MARK: - Preview

#Preview {
    AuthView()
        .environmentObject(LocalizationManager.shared)
}
