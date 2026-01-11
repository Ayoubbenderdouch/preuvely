import SwiftUI
import Combine

struct ClaimStoreSheet: View {
    let store: Store
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ClaimStoreViewModel

    init(store: Store) {
        self.store = store
        self._viewModel = StateObject(wrappedValue: ClaimStoreViewModel(store: store))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.showSuccess {
                    successView
                } else {
                    formContent
                }
            }
            .background(Color(.secondarySystemBackground))
            .navigationTitle(viewModel.showSuccess ? "" : L10n.Claim.title.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if !viewModel.showSuccess {
                        Button(L10n.Common.cancel.localized) {
                            dismiss()
                        }
                    }
                }
            }
            .loadingOverlay(viewModel.isSubmitting)
            .alert(
                L10n.Common.error.localized,
                isPresented: Binding(
                    get: { viewModel.error != nil },
                    set: { if !$0 { viewModel.error = nil } }
                ),
                presenting: viewModel.error
            ) { _ in
                Button(L10n.Common.ok.localized, role: .cancel) {
                    viewModel.error = nil
                }
            } message: { error in
                Text(error.localizedDescription)
            }
        }
    }

    // MARK: - Form Content

    private var formContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                // Info banner
                infoBanner

                // Form fields
                formFields

                // Submit button
                submitButton
            }
            .padding(Spacing.screenPadding)
        }
    }

    // MARK: - Success View

    private var successView: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // Success icon
            ZStack {
                Circle()
                    .fill(Color.primaryGreen.opacity(0.15))
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(Color.primaryGreen.opacity(0.3))
                    .frame(width: 90, height: 90)

                Image(systemName: "checkmark.message.fill")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundColor(.primaryGreen)
            }
            .padding(.bottom, Spacing.lg)

            // Success title
            Text(L10n.Claim.successTitle.localized)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            // Success message
            Text(L10n.Claim.successMessage.localized)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)

            Spacer()

            // Got it button
            Button {
                dismiss()
            } label: {
                Text(L10n.Claim.gotIt.localized)
            }
            .primaryButtonStyle()
            .padding(.horizontal, Spacing.screenPadding)
            .padding(.bottom, Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color.primaryGreen.opacity(0.05),
                    Color(.secondarySystemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    // MARK: - Info Banner

    private var infoBanner: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.primaryGreen)

                Text(L10n.Claim.claimStoreName.localized(with: store.name))
                    .font(.headline)
                    .foregroundColor(.primary)
            }

            Text(L10n.Claim.ownerBenefits.localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(Spacing.lg)
        .background(Color.primaryGreen.opacity(0.1))
        .cornerRadius(Spacing.radiusMedium)
    }

    // MARK: - Form Fields

    private var formFields: some View {
        VStack(spacing: Spacing.lg) {
            PreuvelyTextField(
                title: L10n.Claim.ownerName.localized,
                text: $viewModel.fullName,
                placeholder: L10n.Claim.ownerNamePlaceholder.localized,
                icon: "person.fill"
            )

            PreuvelyTextField(
                title: L10n.Claim.whatsapp.localized,
                text: $viewModel.whatsappNumber,
                placeholder: L10n.Claim.whatsappPlaceholder.localized,
                icon: "message.fill",
                keyboardType: .phonePad
            )
        }
    }

    // MARK: - Submit Button

    private var submitButton: some View {
        Button {
            Task {
                await viewModel.submitClaim()
            }
        } label: {
            Text(L10n.Claim.submit.localized)
        }
        .primaryButtonStyle()
        .disabled(!viewModel.isValid)
    }
}

// MARK: - Claim Store ViewModel

@MainActor
final class ClaimStoreViewModel: ObservableObject {
    let store: Store

    @Published var fullName = ""
    @Published var whatsappNumber = ""

    @Published var isSubmitting = false
    @Published var showSuccess = false
    @Published var error: Error?

    private let apiClient: APIClient

    var isValid: Bool {
        !fullName.isEmpty && whatsappNumber.count >= 10
    }

    init(store: Store, apiClient: APIClient = .shared) {
        self.store = store
        self.apiClient = apiClient
    }

    func submitClaim() async {
        isSubmitting = true
        error = nil

        do {
            let request = CreateClaimRequest(
                requesterName: fullName,
                requesterPhone: whatsappNumber
            )
            _ = try await apiClient.submitClaim(storeId: store.id, request: request)
            withAnimation(.easeInOut(duration: 0.3)) {
                showSuccess = true
            }
        } catch {
            self.error = error
        }

        isSubmitting = false
    }
}

// MARK: - Preview

#Preview {
    ClaimStoreSheet(store: Store.sample)
        .environmentObject(LocalizationManager.shared)
}
