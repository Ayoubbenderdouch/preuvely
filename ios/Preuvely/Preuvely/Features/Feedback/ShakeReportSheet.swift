import SwiftUI
import UIKit

// MARK: - Shake Report Sheet

struct ShakeReportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var appearAnimation = false
    @State private var iconBounce = false

    // WhatsApp contact number
    private let whatsappNumber = "+213555000000" // Change to your actual number

    var body: some View {
        VStack(spacing: 24) {
            // Drag indicator
            Capsule()
                .fill(Color(.systemGray4))
                .frame(width: 40, height: 5)
                .padding(.top, 12)

            // Animated header
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.primaryGreen.opacity(0.2), Color.primaryGreen.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 90, height: 90)

                    Image(systemName: "iphone.gen3.radiowaves.left.and.right")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .rotationEffect(.degrees(iconBounce ? -5 : 5))
                }
                .offset(y: appearAnimation ? 0 : -20)
                .opacity(appearAnimation ? 1 : 0)

                VStack(spacing: 8) {
                    Text("shake_contact_title".localized)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)

                    Text("shake_contact_subtitle".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .offset(y: appearAnimation ? 0 : 10)
                .opacity(appearAnimation ? 1 : 0)
            }

            Spacer()

            // WhatsApp Button
            Button {
                openWhatsApp()
            } label: {
                HStack(spacing: 14) {
                    Image("Whatsapp")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("shake_contact_whatsapp".localized)
                            .font(.headline)
                            .foregroundColor(.white)

                        Text(formattedNumber)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.whatsappGreen, Color.whatsappGreen.opacity(0.85)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color.whatsappGreen.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(.plain)
            .scaleEffect(appearAnimation ? 1 : 0.9)
            .opacity(appearAnimation ? 1 : 0)

            // Close button
            Button {
                dismiss()
            } label: {
                Text("shake_contact_close".localized)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
            }
            .opacity(appearAnimation ? 1 : 0)

            Spacer()
        }
        .padding(.horizontal, 20)
        .background(Color(.systemBackground))
        .presentationDetents([.fraction(0.45)])
        .presentationDragIndicator(.hidden)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appearAnimation = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5).repeatForever(autoreverses: true)) {
                iconBounce = true
            }
        }
    }

    // MARK: - Helpers

    private var formattedNumber: String {
        // Format: +213 555 000 000
        let cleaned = whatsappNumber.replacingOccurrences(of: "+", with: "")
        if cleaned.count >= 12 {
            let country = String(cleaned.prefix(3))
            let rest = String(cleaned.dropFirst(3))
            let formatted = rest.enumerated().map { index, char in
                return index % 3 == 0 && index > 0 ? " \(char)" : String(char)
            }.joined()
            return "+\(country) \(formatted)"
        }
        return whatsappNumber
    }

    private func openWhatsApp() {
        let message = "shake_contact_message".localized
        let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let cleanNumber = whatsappNumber.replacingOccurrences(of: "+", with: "").replacingOccurrences(of: " ", with: "")

        if let url = URL(string: "https://wa.me/\(cleanNumber)?text=\(encodedMessage)") {
            UIApplication.shared.open(url)
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    Text("Shake your device")
        .sheet(isPresented: .constant(true)) {
            ShakeReportSheet()
        }
}
