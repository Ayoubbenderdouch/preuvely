import SwiftUI
import PhotosUI
import Combine

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EditProfileViewModel
    @State private var appearAnimation = false

    init(user: User) {
        self._viewModel = StateObject(wrappedValue: EditProfileViewModel(user: user))
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Profile Picture Section
                    profilePictureSection
                        .offset(y: appearAnimation ? 0 : 20)
                        .opacity(appearAnimation ? 1 : 0)

                    // Name Section
                    nameSection
                        .offset(y: appearAnimation ? 0 : 20)
                        .opacity(appearAnimation ? 1 : 0)

                    // Email Section (read-only)
                    emailSection
                        .offset(y: appearAnimation ? 0 : 20)
                        .opacity(appearAnimation ? 1 : 0)

                    // Phone Section
                    phoneSection
                        .offset(y: appearAnimation ? 0 : 20)
                        .opacity(appearAnimation ? 1 : 0)

                    Spacer(minLength: 100)
                }
                .padding(20)
            }
            .background(
                LinearGradient(
                    colors: [Color(.systemGray6), Color(.systemGray5).opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationTitle("profile_edit".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel.localized) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await viewModel.saveProfile()
                            if viewModel.saveSuccess {
                                dismiss()
                            }
                        }
                    } label: {
                        if viewModel.isSaving {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text(L10n.Common.save.localized)
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!viewModel.hasChanges || viewModel.isSaving)
                    .foregroundColor(viewModel.hasChanges ? .primaryGreen : .secondary)
                }
            }
            .alert(L10n.Common.error.localized, isPresented: $viewModel.showError) {
                Button(L10n.Common.ok.localized, role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    appearAnimation = true
                }
            }
        }
    }

    // MARK: - Profile Picture Section

    private var profilePictureSection: some View {
        VStack(spacing: 16) {
            ZStack {
                // Profile image or initials
                if let image = viewModel.profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.primaryGreen.opacity(0.5), Color.primaryGreen.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                        )
                } else {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.primaryGreen.opacity(0.2), Color.primaryGreen.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .overlay(
                            Text(viewModel.initials)
                                .font(.system(size: 44, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.7)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.primaryGreen.opacity(0.3), Color.primaryGreen.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                        )
                }

                // Camera button overlay
                PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                    ZStack {
                        Circle()
                            .fill(Color.primaryGreen)
                            .frame(width: 40, height: 40)
                            .shadow(color: Color.primaryGreen.opacity(0.4), radius: 8, x: 0, y: 4)

                        Image(systemName: "camera.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .offset(x: 42, y: 42)
            }

            Text("profile_tap_to_change_photo".localized)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
        .onChange(of: viewModel.selectedPhoto) { _, _ in
            Task {
                await viewModel.loadImage()
            }
        }
    }

    // MARK: - Name Section

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "person.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primaryGreen)

                Text(L10n.Auth.name.localized)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
            }

            TextField(L10n.Auth.namePlaceholder.localized, text: $viewModel.name)
                .font(.body)
                .padding(16)
                .background(Color(.systemGray6))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(viewModel.name.isEmpty ? Color.red.opacity(0.5) : Color.clear, lineWidth: 1)
                )

            if viewModel.name.isEmpty {
                Text("profile_name_required".localized)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }

    // MARK: - Email Section

    private var emailSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)

                Text(L10n.Auth.email.localized)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)

                Spacer()

                // Verified badge
                if viewModel.user.isEmailVerified {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                        Text(L10n.Common.verified.localized)
                            .font(.caption.weight(.medium))
                    }
                    .foregroundColor(.primaryGreen)
                }
            }

            HStack {
                Text(viewModel.user.email ?? "")
                    .font(.body)
                    .foregroundColor(.secondary)

                Spacer()

                Image(systemName: "lock.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(14)

            Text("profile_email_cannot_change".localized)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(18)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }

    // MARK: - Phone Section

    private var phoneSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.orange)

                Text(L10n.Claim.phone.localized)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)

                Text("(\(L10n.Common.optional.localized))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            TextField("profile_phone_placeholder".localized, text: $viewModel.phone)
                .font(.body)
                .keyboardType(.phonePad)
                .padding(16)
                .background(Color(.systemGray6))
                .cornerRadius(14)
        }
        .padding(18)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Edit Profile ViewModel

@MainActor
final class EditProfileViewModel: ObservableObject {
    let user: User

    @Published var name: String
    @Published var phone: String
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var profileImage: UIImage?

    @Published var isSaving = false
    @Published var saveSuccess = false
    @Published var showError = false
    @Published var errorMessage = ""

    private let originalName: String
    private let originalPhone: String
    private var originalImage: UIImage?

    private let apiClient: APIClient

    var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    var hasChanges: Bool {
        name != originalName ||
        phone != originalPhone ||
        profileImage != originalImage
    }

    init(user: User, apiClient: APIClient = .shared) {
        self.user = user
        self.apiClient = apiClient
        self.name = user.name
        self.phone = user.phone ?? ""
        self.originalName = user.name
        self.originalPhone = user.phone ?? ""
    }

    func loadImage() async {
        guard let item = selectedPhoto else { return }

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                profileImage = image
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func saveProfile() async {
        guard !name.isEmpty else {
            errorMessage = "profile_name_required".localized
            showError = true
            return
        }

        isSaving = true

        do {
            // Update profile (name and phone) first
            _ = try await apiClient.updateProfile(
                name: name,
                phone: phone.isEmpty ? nil : phone
            )

            // Upload avatar LAST so the final currentUser has the avatar URL
            if profileImage != nil && profileImage != originalImage {
                if let image = profileImage {
                    let updatedUser = try await apiClient.uploadAvatar(image: image)
                    apiClient.currentUser = updatedUser
                }
            }

            isSaving = false
            saveSuccess = true
        } catch {
            isSaving = false
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - Preview

#Preview {
    EditProfileView(user: User.sample)
        .environmentObject(LocalizationManager.shared)
}
