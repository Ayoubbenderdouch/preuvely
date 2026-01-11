import SwiftUI
import Combine

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search..."
    var onSubmit: (() -> Void)? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.body)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(.body)
                .focused($isFocused)
                .onSubmit {
                    onSubmit?()
                }
                .submitLabel(.search)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.md)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(Spacing.radiusMedium)
    }
}

// MARK: - Custom Text Field

struct PreuvelyTextField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var icon: String? = nil
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(.secondary)
                        .frame(width: 20)
                }

                if isSecure {
                    SecureField(placeholder, text: $text)
                        .textFieldStyle(.plain)
                } else {
                    TextField(placeholder, text: $text)
                        .textFieldStyle(.plain)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(autocapitalization)
                }
            }
            .padding(Spacing.md)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(Spacing.radiusMedium)
        }
    }
}

// MARK: - Text Editor Field

struct PreuvelyTextEditor: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var minHeight: CGFloat = 100
    var maxLength: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if let maxLength = maxLength {
                    Text("\(text.count)/\(maxLength)")
                        .font(.caption2)
                        .foregroundColor(text.count > maxLength ? .red : .secondary)
                }
            }

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(Color(.placeholderText))
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, Spacing.sm)
                }

                TextEditor(text: $text)
                    .frame(minHeight: minHeight)
                    .scrollContentBackground(.hidden)
                    .onChange(of: text) { _, newValue in
                        if let maxLength = maxLength, newValue.count > maxLength {
                            text = String(newValue.prefix(maxLength))
                        }
                    }
            }
            .padding(Spacing.sm)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(Spacing.radiusMedium)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        SearchBar(text: .constant(""), placeholder: "Search stores...")

        SearchBar(text: .constant("Electronics"), placeholder: "Search stores...")

        PreuvelyTextField(
            title: "Email",
            text: .constant(""),
            placeholder: "Enter your email",
            icon: "envelope"
        )

        PreuvelyTextField(
            title: "Password",
            text: .constant(""),
            placeholder: "Enter password",
            icon: "lock",
            isSecure: true
        )

        PreuvelyTextEditor(
            title: "Comment",
            text: .constant("This is a great store!"),
            placeholder: "Write your review...",
            maxLength: 500
        )
    }
    .padding()
}
