import SwiftUI
import Combine

struct ReportSheet: View {
    let reportableType: ReportableType
    let reportableId: Int
    let reportableName: String

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ReportViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.showSuccess {
                    reportSuccessView
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else {
                    reportFormView
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.showSuccess)
            .background(Color(.secondarySystemBackground))
            .navigationTitle(viewModel.showSuccess ? "" : L10n.Report.title.localized)
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

    // MARK: - Report Form View

    private var reportFormView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                // What are you reporting
                reportingHeader

                // Reason selection
                reasonSection

                // Note
                noteSection

                // Submit button
                submitButton
            }
            .padding(Spacing.screenPadding)
        }
    }

    // MARK: - Success View

    private var reportSuccessView: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // Animated checkmark with green gradient
            ReportSuccessCheckmark()

            VStack(spacing: Spacing.md) {
                Text(L10n.Report.submittedTitle.localized)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text(L10n.Report.thankYouMessage.localized)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Text(L10n.Common.done.localized)
            }
            .primaryButtonStyle()
            .padding(.horizontal, Spacing.screenPadding)
            .padding(.bottom, Spacing.xl)
        }
    }

    // MARK: - Reporting Header

    private var reportingHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(L10n.Report.reporting.localized)
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: Spacing.sm) {
                Image(systemName: reportableType == .store ? "storefront.fill" : "text.bubble.fill")
                    .foregroundColor(.red)

                Text(reportableName)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .cornerRadius(Spacing.radiusMedium)
        }
    }

    // MARK: - Reason Section

    private var reasonSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(L10n.Report.reason.localized)
                .font(.headline)
                .foregroundColor(.primary)

            VStack(spacing: Spacing.sm) {
                ForEach(ReportReason.allCases) { reason in
                    ReasonRow(
                        reason: reason,
                        isSelected: viewModel.selectedReason == reason
                    ) {
                        viewModel.selectedReason = reason
                    }
                }
            }
        }
    }

    // MARK: - Note Section

    private var noteSection: some View {
        PreuvelyTextEditor(
            title: L10n.Report.note.localized + " (" + L10n.Common.optional.localized + ")",
            text: $viewModel.note,
            placeholder: L10n.Report.notePlaceholder.localized,
            minHeight: 100,
            maxLength: 500
        )
    }

    // MARK: - Submit Button

    private var submitButton: some View {
        Button {
            Task {
                await viewModel.submitReport(
                    type: reportableType,
                    id: reportableId
                )
            }
        } label: {
            Text(L10n.Report.submit.localized)
        }
        .primaryButtonStyle()
        .disabled(viewModel.selectedReason == nil)
    }
}

// MARK: - Reason Row

struct ReasonRow: View {
    let reason: ReportReason
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                // Reason icon
                Image(systemName: reason.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .primaryGreen : .secondary)
                    .frame(width: 28, height: 28)

                Text(reason.localizedDisplayName)
                    .font(.body)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .primaryGreen : Color(.systemGray3))
            }
            .padding(Spacing.md)
            .background(Color(.systemBackground))
            .cornerRadius(Spacing.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.radiusMedium)
                    .stroke(isSelected ? Color.primaryGreen : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Report Success Checkmark

struct ReportSuccessCheckmark: View {
    @State private var isAnimating = false
    @State private var checkmarkScale: CGFloat = 0
    @State private var circleScale: CGFloat = 0

    private let greenGradient = LinearGradient(
        colors: [
            Color(red: 0.2, green: 0.8, blue: 0.4),
            Color(red: 0.1, green: 0.6, blue: 0.3)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        ZStack {
            // Outer glow circle
            Circle()
                .fill(greenGradient.opacity(0.15))
                .frame(width: 140, height: 140)
                .scaleEffect(circleScale)

            // Main circle with gradient
            Circle()
                .fill(greenGradient)
                .frame(width: 100, height: 100)
                .shadow(color: Color.green.opacity(0.3), radius: 15, x: 0, y: 5)
                .scaleEffect(circleScale)

            // Checkmark
            Image(systemName: "checkmark")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(.white)
                .scaleEffect(checkmarkScale)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                circleScale = 1.0
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.2)) {
                checkmarkScale = 1.0
            }
        }
    }
}

// MARK: - Report ViewModel

@MainActor
final class ReportViewModel: ObservableObject {
    @Published var selectedReason: ReportReason?
    @Published var note = ""

    @Published var isSubmitting = false
    @Published var showSuccess = false
    @Published var error: Error?

    private let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func submitReport(type: ReportableType, id: Int) async {
        guard let reason = selectedReason else { return }

        isSubmitting = true
        error = nil

        do {
            let request = CreateReportRequest(
                reportableType: type,
                reportableId: id,
                reason: reason,
                note: note.isEmpty ? nil : note
            )
            _ = try await apiClient.submitReport(request: request)
            showSuccess = true
        } catch {
            self.error = error
        }

        isSubmitting = false
    }
}

// MARK: - Preview

#Preview {
    ReportSheet(
        reportableType: .store,
        reportableId: 1,
        reportableName: "TechZone DZ"
    )
    .environmentObject(LocalizationManager.shared)
}
