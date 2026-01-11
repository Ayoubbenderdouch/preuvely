import SwiftUI
import Combine

struct EditStoreLinksView: View {
    @ObservedObject var viewModel: MyStoreViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var appearAnimation = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Spacing.lg) {
                // Header info
                headerInfo
                    .offset(y: appearAnimation ? 0 : 20)
                    .opacity(appearAnimation ? 1 : 0)

                // Links list
                linksSection
                    .offset(y: appearAnimation ? 0 : 20)
                    .opacity(appearAnimation ? 1 : 0)

                Spacer(minLength: 100)
            }
            .padding(Spacing.screenPadding)
        }
        .background(
            LinearGradient(
                colors: [Color(.systemGray6), Color(.systemGray5).opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationTitle("edit_store_links_title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task {
                        await viewModel.updateStoreLinks()
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
                .disabled(!viewModel.hasLinkChanges || viewModel.isSaving)
                .foregroundColor(viewModel.hasLinkChanges ? .primaryGreen : .secondary)
            }
        }
        .alert(L10n.Common.error.localized, isPresented: $viewModel.showError) {
            Button(L10n.Common.ok.localized, role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appearAnimation = true
            }
        }
    }

    // MARK: - Header Info

    private var headerInfo: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.primaryGreen.opacity(0.12))
                    .frame(width: 48, height: 48)

                Image(systemName: "link.badge.plus")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primaryGreen)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("edit_store_links_header".localized)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)

                Text("edit_store_links_description".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }

    // MARK: - Links Section

    private var linksSection: some View {
        VStack(spacing: 0) {
            ForEach(Array(viewModel.storeLinks.enumerated()), id: \.element.id) { index, link in
                VStack(spacing: 0) {
                    LinkRow(
                        link: Binding(
                            get: { viewModel.storeLinks[index] },
                            set: { viewModel.storeLinks[index] = $0 }
                        )
                    )

                    if index < viewModel.storeLinks.count - 1 {
                        Divider()
                            .padding(.leading, 66)
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Link Row

struct LinkRow: View {
    @Binding var link: EditableStoreLink
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Platform icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(link.platform.iconColor.opacity(0.12))
                    .frame(width: 44, height: 44)

                platformIcon
            }

            // URL field
            VStack(alignment: .leading, spacing: 4) {
                Text(link.platform.displayName)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)

                TextField(link.platform.placeholder, text: $link.url)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .keyboardType(link.platform.keyboardType)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .focused($isFocused)
            }

            Spacer()

            // Clear button if URL is not empty
            if !link.url.isEmpty {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        link.url = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(.systemGray3))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(isFocused ? Color.primaryGreen.opacity(0.03) : Color.clear)
        )
    }

    @ViewBuilder
    private var platformIcon: some View {
        switch link.platform {
        case .website:
            Image(systemName: "globe")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(link.platform.iconColor)
        case .instagram:
            Image("Instagram")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
        case .facebook:
            Image("facebook")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
        case .tiktok:
            Image("Tiktok")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
        case .whatsapp:
            Image("Whatsapp")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        EditStoreLinksView(viewModel: {
            let vm = MyStoreViewModel()
            vm.storeLinks = [
                EditableStoreLink(platform: .website, url: "https://example.com"),
                EditableStoreLink(platform: .instagram, url: "@example"),
                EditableStoreLink(platform: .facebook, url: ""),
                EditableStoreLink(platform: .tiktok, url: ""),
                EditableStoreLink(platform: .whatsapp, url: "+213555123456")
            ]
            return vm
        }())
        .environmentObject(LocalizationManager.shared)
    }
}
