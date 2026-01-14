import SwiftUI
import PhotosUI
import Combine

struct WriteReviewSheet: View {
    let store: Store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject private var viewModel: WriteReviewViewModel
    @State private var appearAnimation = false
    @State private var showThankYou = false
    @State private var isButtonPressed = false
    @State private var showAuthSheet = false
    @State private var showEmailAuth = false
    @State private var pendingSubmit = false
    @State private var showSocialLoginNotAvailable = false

    /// Maximum content width for iPad sheets
    private var maxContentWidth: CGFloat {
        horizontalSizeClass == .regular ? 550 : .infinity
    }

    init(store: Store) {
        self.store = store
        self._viewModel = StateObject(wrappedValue: WriteReviewViewModel(store: store))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Main Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Store info
                        storeHeader
                            .offset(y: appearAnimation ? 0 : -20)
                            .opacity(appearAnimation ? 1 : 0)

                        // Star rating
                        starRatingSection
                            .offset(y: appearAnimation ? 0 : 20)
                            .opacity(appearAnimation ? 1 : 0)

                        // Comment
                        commentSection
                            .offset(y: appearAnimation ? 0 : 20)
                            .opacity(appearAnimation ? 1 : 0)

                        // Proof section (always available - required for high-risk, optional for others)
                        proofSection
                            .offset(y: appearAnimation ? 0 : 20)
                            .opacity(appearAnimation ? 1 : 0)

                        // Submit button
                        submitButton
                            .offset(y: appearAnimation ? 0 : 20)
                            .opacity(appearAnimation ? 1 : 0)

                        Spacer(minLength: 100)
                    }
                    .padding(20)
                    .frame(maxWidth: maxContentWidth)
                    .frame(maxWidth: .infinity)
                }
                .background(
                    LinearGradient(
                        colors: [Color(.systemGray6), Color(.systemGray5).opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                // Thank You Overlay
                if showThankYou {
                    thankYouOverlay
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .navigationTitle(L10n.Store.writeReview.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel.localized) {
                        dismiss()
                    }
                }
            }
            .alert(L10n.Common.error.localized, isPresented: $viewModel.showError) {
                Button(L10n.Common.ok.localized, role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .sheet(isPresented: $showAuthSheet) {
                ReviewAuthSheet(
                    store: store,
                    onGoogleSignIn: {
                        handleSocialLogin(provider: .google)
                    },
                    onAppleSignIn: {
                        handleSocialLogin(provider: .apple)
                    },
                    onEmailSignIn: {
                        showAuthSheet = false
                        showEmailAuth = true
                    }
                )
                .presentationDetents([.large])
            }
            .sheet(isPresented: $showEmailAuth) {
                AuthView()
                    .onDisappear {
                        // Check if user is now authenticated and auto-submit
                        if APIClient.shared.isAuthenticated && pendingSubmit {
                            pendingSubmit = false
                            Task {
                                await performSubmit()
                            }
                        }
                    }
            }
            .alert("social_login_not_available_title".localized, isPresented: $showSocialLoginNotAvailable) {
                Button(L10n.Common.ok.localized, role: .cancel) {}
            } message: {
                Text("social_login_not_available_message".localized)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    appearAnimation = true
                }
            }
            .environment(\.layoutDirection, .leftToRight)
        }
    }

    // MARK: - Auth Handlers

    /// Handles social login for Google and Apple Sign-In.
    ///
    /// - Important: Social login is not yet fully implemented. This function currently shows
    ///   an alert informing the user to use email sign-in instead.
    ///
    /// - TODO: Implement proper OAuth token retrieval:
    ///   - For Google Sign-In:
    ///     1. Add GoogleSignIn SDK via Swift Package Manager
    ///     2. Configure GIDSignIn with your client ID in App Delegate
    ///     3. Use `GIDSignIn.sharedInstance.signIn(withPresenting:)` to get credentials
    ///     4. Extract the ID token: `user.idToken?.tokenString`
    ///   - For Apple Sign-In:
    ///     1. Import AuthenticationServices framework
    ///     2. Create ASAuthorizationController with ASAuthorizationAppleIDProvider
    ///     3. Implement ASAuthorizationControllerDelegate
    ///     4. Extract identity token from ASAuthorizationAppleIDCredential.identityToken
    ///
    /// - Parameter provider: The social provider (.google or .apple)
    private func handleSocialLogin(provider: SocialProvider) {
        // TODO: Implement real OAuth token retrieval
        // Currently, the OAuth SDKs (GoogleSignIn, AuthenticationServices) are not integrated.
        // Show an alert to the user instead of silently failing with a mock token.
        showAuthSheet = false
        showSocialLoginNotAvailable = true
    }

    private func performSubmit() async {
        await viewModel.submitReview()
        if viewModel.showSuccess {
            withAnimation(.spring(response: 0.4)) {
                showThankYou = true
            }

            // Dismiss after 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                dismiss()
            }
        }
    }

    // MARK: - Store Header

    private var storeHeader: some View {
        HStack(spacing: 14) {
            // Store Logo or Initial
            if let logoURL = store.logo, let url = URL(string: logoURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    case .failure:
                        storeInitialView
                    case .empty:
                        ProgressView()
                            .frame(width: 56, height: 56)
                    @unknown default:
                        storeInitialView
                    }
                }
            } else {
                storeInitialView
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(store.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    if store.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.primaryGreen)
                    }
                }

                if let city = store.city {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 10))
                        Text(city)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Rating badge
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.starYellow)

                Text(String(format: "%.1f", store.avgRating))
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.starYellow.opacity(0.15))
            .cornerRadius(10)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }

    /// Fallback view showing store initial when no logo is available
    private var storeInitialView: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.primaryGreen.opacity(0.2), Color.primaryGreen.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 56, height: 56)

            Text(store.name.prefix(1).uppercased())
                .font(.title2.weight(.bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }

    // MARK: - Star Rating Section

    private var starRatingSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.starYellow)

                Text(L10n.Review.yourRating.localized)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Star Rating
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            viewModel.rating = star
                        }
                    } label: {
                        Image(systemName: star <= viewModel.rating ? "star.fill" : "star")
                            .font(.system(size: 40))
                            .foregroundColor(star <= viewModel.rating ? .starYellow : Color(.systemGray4))
                            .scaleEffect(star <= viewModel.rating ? 1.1 : 1.0)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 8)

            // Rating description
            if viewModel.rating > 0 {
                Text(ratingDescription)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(ratingColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(ratingColor.opacity(0.1))
                    .cornerRadius(10)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }

    private var ratingDescription: String {
        switch viewModel.rating {
        case 1: return "review_rating_1".localized
        case 2: return "review_rating_2".localized
        case 3: return "review_rating_3".localized
        case 4: return "review_rating_4".localized
        case 5: return "review_rating_5".localized
        default: return ""
        }
    }

    private var ratingColor: Color {
        switch viewModel.rating {
        case 1, 2: return .red
        case 3: return .orange
        case 4, 5: return .primaryGreen
        default: return .gray
        }
    }

    // MARK: - Comment Section

    private var commentSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "text.bubble.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.primaryGreen)

                Text(L10n.Review.writeComment.localized)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Text("\(viewModel.comment.count)/500")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Text Editor
            ZStack(alignment: .topLeading) {
                if viewModel.comment.isEmpty {
                    Text(L10n.Review.commentPlaceholder.localized)
                        .font(.body)
                        .foregroundColor(Color(.systemGray3))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                }

                TextEditor(text: $viewModel.comment)
                    .font(.body)
                    .frame(minHeight: 120)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .scrollContentBackground(.hidden)
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
            }

            // Character count warning
            if viewModel.comment.count < 8 && !viewModel.comment.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                    Text(L10n.Review.minCharactersRequired.localized)
                        .font(.caption)
                }
                .foregroundColor(.red)
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }

    // MARK: - Proof Section

    private var proofSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(viewModel.requiresProof ? Color.orange.opacity(0.15) : Color.primaryGreen.opacity(0.15))
                        .frame(width: 32, height: 32)

                    Image(systemName: viewModel.requiresProof ? "exclamationmark.triangle.fill" : "checkmark.shield.fill")
                        .font(.system(size: 14))
                        .foregroundColor(viewModel.requiresProof ? .orange : .primaryGreen)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(viewModel.requiresProof ? L10n.Review.proofRequired.localized : "review_add_proof".localized)
                            .font(.headline)
                            .foregroundColor(.primary)

                        if !viewModel.requiresProof {
                            Text("(\(L10n.Common.optional.localized))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Text(viewModel.requiresProof ? L10n.Review.highRiskProofExplanation.localized : "review_proof_boost_message".localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            // Photo picker
            PhotosPicker(
                selection: $viewModel.selectedPhoto,
                matching: .images
            ) {
                if let proofImage = viewModel.proofImage {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: proofImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 150)
                            .clipped()
                            .cornerRadius(14)

                        Button {
                            viewModel.proofImage = nil
                            viewModel.selectedPhoto = nil
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.6))
                                    .frame(width: 30, height: 30)

                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(8)
                    }
                } else {
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color.primaryGreen.opacity(0.15))
                                .frame(width: 56, height: 56)

                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 24))
                                .foregroundColor(.primaryGreen)
                        }

                        Text(L10n.Review.uploadProof.localized)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.primaryGreen)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 130)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.primaryGreen.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.primaryGreen.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8]))
                            )
                    )
                }
            }
            .onChange(of: viewModel.selectedPhoto) { _, newValue in
                Task {
                    await viewModel.loadImage()
                }
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }

    // MARK: - Submit Button

    private var submitButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isButtonPressed = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isButtonPressed = false
                }
            }

            // Check if user is authenticated
            if !APIClient.shared.isAuthenticated {
                // Show auth sheet and mark as pending submit
                pendingSubmit = true
                showAuthSheet = true
            } else {
                // User is authenticated, submit directly
                Task {
                    await performSubmit()
                }
            }
        } label: {
            HStack(spacing: 10) {
                if viewModel.isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18))
                }

                Text(viewModel.isSubmitting ? "review_submitting".localized : L10n.Review.submitReview.localized)
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: viewModel.isValid && !viewModel.isSubmitting
                        ? [Color.primaryGreen, Color.primaryGreen.opacity(0.8)]
                        : [Color(.systemGray4), Color(.systemGray4)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(
                color: viewModel.isValid ? Color.primaryGreen.opacity(0.3) : .clear,
                radius: 10, x: 0, y: 5
            )
            .scaleEffect(isButtonPressed ? 0.95 : 1.0)
        }
        .disabled(!viewModel.isValid || viewModel.isSubmitting)
    }

    // MARK: - Thank You Overlay

    private var thankYouOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.primaryGreen.opacity(0.2), Color.primaryGreen.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }

                Text("review_thank_you_title".localized)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.primary)

                Text("review_thank_you_message".localized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                // Stars animation
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= viewModel.rating ? "star.fill" : "star")
                            .font(.system(size: 24))
                            .foregroundColor(star <= viewModel.rating ? .starYellow : Color(.systemGray4))
                    }
                }
                .padding(.top, 8)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Write Review ViewModel

@MainActor
final class WriteReviewViewModel: ObservableObject {
    let store: Store

    @Published var rating: Int = 0
    @Published var comment: String = ""
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var proofImage: UIImage?

    @Published var isSubmitting = false
    @Published var showSuccess = false
    @Published var showError = false
    @Published var errorMessage = ""

    private let apiClient: APIClient

    var requiresProof: Bool {
        store.categories.contains { $0.isHighRisk }
    }

    var isValid: Bool {
        rating > 0 && comment.count >= 8
    }

    init(store: Store, apiClient: APIClient = .shared) {
        self.store = store
        self.apiClient = apiClient
    }

    func loadImage() async {
        guard let item = selectedPhoto else { return }

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                proofImage = image
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func submitReview() async {
        isSubmitting = true
        showError = false

        do {
            let request = CreateReviewRequest(stars: rating, comment: comment)
            let review = try await apiClient.createReview(storeId: store.id, request: request)

            // Upload proof if available
            if let image = proofImage {
                _ = try await apiClient.uploadProof(reviewId: review.id, image: image)
            }

            showSuccess = true
        } catch let error as APIError {
            switch error {
            case .unauthorized:
                errorMessage = "auth_required_review".localized
            case .conflict:
                errorMessage = "review_already_exists".localized
            case .validation(let message):
                errorMessage = message
            default:
                errorMessage = error.localizedDescription ?? "An error occurred"
            }
            showError = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isSubmitting = false
    }
}

// MARK: - Preview

#Preview {
    WriteReviewSheet(store: Store.sample)
        .environmentObject(LocalizationManager.shared)
}
