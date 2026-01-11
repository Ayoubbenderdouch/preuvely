import SwiftUI
import UIKit

struct EmailVerificationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = EmailVerificationViewModel()
    @FocusState private var focusedField: Int?

    let email: String
    let onVerified: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.primaryGreen.opacity(0.2), Color.primaryGreen.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)

                        Image(systemName: "envelope.badge.shield.half.filled")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }

                    Text("Verify Your Email")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)

                    Text("Enter the 6-digit code sent to")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(email)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                }
                .padding(.top, 20)

                // OTP Input Fields
                HStack(spacing: 8) {
                    ForEach(0..<6, id: \.self) { index in
                        OTPDigitField(
                            digit: $viewModel.digits[index],
                            isFocused: focusedField == index
                        )
                        .focused($focusedField, equals: index)
                        .onChange(of: viewModel.digits[index]) { _, newValue in
                            handleDigitChange(at: index, newValue: newValue)
                        }
                    }
                }
                .padding(.horizontal, 20)

                // Error message
                if let errorMessage = viewModel.errorMessage {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 14))
                        Text(errorMessage)
                            .font(.caption)
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal, 20)
                }

                // Verify Button
                Button {
                    Task {
                        let success = await viewModel.verifyCode()
                        if success {
                            onVerified()
                            dismiss()
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 16))
                            Text("Verify Email")
                                .font(.headline)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: viewModel.isCodeComplete
                                ? [Color.primaryGreen, Color.primaryGreen.opacity(0.8)]
                                : [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                }
                .disabled(!viewModel.isCodeComplete || viewModel.isLoading)
                .padding(.horizontal, 20)

                // Resend code section
                VStack(spacing: 8) {
                    Text("Didn't receive the code?")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button {
                        Task {
                            await viewModel.resendCode()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 12, weight: .semibold))
                            Text(viewModel.resendCooldown > 0
                                 ? "Resend in \(viewModel.resendCooldown)s"
                                 : "Resend Code")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundColor(viewModel.resendCooldown > 0 ? .secondary : .primaryGreen)
                    }
                    .disabled(viewModel.resendCooldown > 0 || viewModel.isResending)
                }
                .padding(.top, 8)

                Spacer()

                // Info footer
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text("Code expires in 15 minutes")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
            .onAppear {
                focusedField = 0
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private func handleDigitChange(at index: Int, newValue: String) {
        // Handle paste of full code
        if newValue.count > 1 {
            let digits = Array(newValue.prefix(6))
            for (i, digit) in digits.enumerated() {
                if i < 6 {
                    viewModel.digits[i] = String(digit)
                }
            }
            focusedField = min(digits.count, 5)
            return
        }

        // Move to next field when digit is entered
        if !newValue.isEmpty && index < 5 {
            focusedField = index + 1
        }
    }
}

// MARK: - OTP Digit Field

struct OTPDigitField: View {
    @Binding var digit: String
    let isFocused: Bool

    var body: some View {
        TextField("", text: $digit)
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            .multilineTextAlignment(.center)
            .font(.title.weight(.bold))
            .frame(width: 48, height: 56)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: isFocused ? Color.primaryGreen.opacity(0.3) : Color.black.opacity(0.05),
                        radius: isFocused ? 8 : 4,
                        x: 0,
                        y: 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isFocused ? Color.primaryGreen : Color(.systemGray4),
                        lineWidth: isFocused ? 2 : 1
                    )
            )
            .onChange(of: digit) { _, newValue in
                // Only allow single digit
                if newValue.count > 1 {
                    digit = String(newValue.suffix(1))
                }
                // Only allow numbers
                digit = digit.filter { $0.isNumber }
            }
    }
}

// MARK: - ViewModel

@MainActor
class EmailVerificationViewModel: ObservableObject {
    @Published var digits: [String] = Array(repeating: "", count: 6)
    @Published var isLoading = false
    @Published var isResending = false
    @Published var errorMessage: String?
    @Published var resendCooldown: Int = 0

    private let apiClient: APIClient
    private var cooldownTimer: Timer?

    var isCodeComplete: Bool {
        digits.allSatisfy { !$0.isEmpty }
    }

    var code: String {
        digits.joined()
    }

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func verifyCode() async -> Bool {
        guard isCodeComplete else { return false }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await apiClient.verifyEmailWithCode(code)
            isLoading = false
            return true
        } catch let error as APIError {
            isLoading = false
            switch error {
            case .serverError(let message):
                errorMessage = message
            default:
                errorMessage = "Verification failed. Please try again."
            }
            // Clear the digits on error
            digits = Array(repeating: "", count: 6)
            return false
        } catch {
            isLoading = false
            errorMessage = "An unexpected error occurred."
            return false
        }
    }

    func resendCode() async {
        isResending = true
        errorMessage = nil

        do {
            try await apiClient.resendVerificationEmail()
            isResending = false
            startResendCooldown()
        } catch {
            isResending = false
            errorMessage = "Failed to resend code. Please try again."
        }
    }

    private func startResendCooldown() {
        resendCooldown = 60
        cooldownTimer?.invalidate()
        cooldownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                if self.resendCooldown > 0 {
                    self.resendCooldown -= 1
                } else {
                    timer.invalidate()
                }
            }
        }
    }

    deinit {
        cooldownTimer?.invalidate()
    }
}

#Preview {
    EmailVerificationSheet(email: "test@example.com") {
        print("Verified!")
    }
}
