import SwiftUI
import PhotosUI
import Combine

struct EditStoreView: View {
    let store: Store
    @ObservedObject var viewModel: MyStoreViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager

    @State private var showEditLinks = false
    @State private var showImagePicker = false
    @State private var showCameraSheet = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var appearAnimation = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Spacing.sectionSpacing) {
                // Logo Section
                logoSection
                    .offset(y: appearAnimation ? 0 : 20)
                    .opacity(appearAnimation ? 1 : 0)

                // Store Info Section
                storeInfoSection
                    .offset(y: appearAnimation ? 0 : 20)
                    .opacity(appearAnimation ? 1 : 0)

                // Links Section
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
        .navigationTitle("edit_store_title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task {
                        await viewModel.updateStoreInfo()
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
                .disabled(!viewModel.hasStoreChanges || viewModel.isSaving || !viewModel.isFormValid)
                .foregroundColor(viewModel.hasStoreChanges && viewModel.isFormValid ? .primaryGreen : .secondary)
            }
        }
        .navigationDestination(isPresented: $showEditLinks) {
            EditStoreLinksView(viewModel: viewModel)
        }
        .confirmationDialog("edit_store_choose_photo".localized, isPresented: $showCameraSheet) {
            Button("edit_store_take_photo".localized) {
                imagePickerSourceType = .camera
                showImagePicker = true
            }

            Button("edit_store_choose_library".localized) {
                imagePickerSourceType = .photoLibrary
                showImagePicker = true
            }

            Button(L10n.Common.cancel.localized, role: .cancel) {}
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $viewModel.logoImage, sourceType: imagePickerSourceType)
        }
        .alert(L10n.Common.error.localized, isPresented: $viewModel.showError) {
            Button(L10n.Common.ok.localized, role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .task {
            await viewModel.loadStore(store)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appearAnimation = true
            }
        }
    }

    // MARK: - Logo Section

    private var logoSection: some View {
        VStack(spacing: Spacing.md) {
            ZStack {
                // Logo or placeholder
                if let image = viewModel.logoImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.primaryGreen.opacity(0.5), Color.primaryGreen.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                        )
                } else if let logoURL = store.logo, let url = URL(string: logoURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure, .empty:
                            logoPlaceholder
                        @unknown default:
                            logoPlaceholder
                        }
                    }
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.primaryGreen.opacity(0.3), Color.primaryGreen.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
                } else {
                    logoPlaceholder
                }

                // Camera button overlay
                Button {
                    showCameraSheet = true
                } label: {
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
                .offset(x: 48, y: 48)
            }

            Text("edit_store_tap_change_logo".localized)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }

    private var logoPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.primaryGreen.opacity(0.2), Color.primaryGreen.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text(store.name.prefix(1).uppercased())
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .frame(width: 120, height: 120)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
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

    // MARK: - Store Info Section

    private var storeInfoSection: some View {
        VStack(spacing: Spacing.lg) {
            // Store Name
            formField(
                icon: "storefront.fill",
                iconColor: .primaryGreen,
                title: "edit_store_name".localized,
                isRequired: true
            ) {
                TextField("edit_store_name_placeholder".localized, text: $viewModel.storeName)
                    .font(.body)
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(viewModel.storeName.isEmpty ? Color.red.opacity(0.5) : Color.clear, lineWidth: 1)
                    )

                if viewModel.storeName.isEmpty {
                    Text("edit_store_name_required".localized)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            // Description
            formField(
                icon: "text.alignleft",
                iconColor: .blue,
                title: "edit_store_description".localized,
                isOptional: true
            ) {
                TextField("edit_store_description_placeholder".localized, text: $viewModel.storeDescription, axis: .vertical)
                    .font(.body)
                    .lineLimit(3...6)
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
            }

            // City
            formField(
                icon: "mappin.circle.fill",
                iconColor: .orange,
                title: "edit_store_city".localized,
                isOptional: true
            ) {
                TextField("edit_store_city_placeholder".localized, text: $viewModel.storeCity)
                    .font(.body)
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }

    // MARK: - Links Section

    private var linksSection: some View {
        Button {
            showEditLinks = true
        } label: {
            HStack(spacing: Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.primaryGreen.opacity(0.12))
                        .frame(width: 36, height: 36)

                    Image(systemName: "link")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primaryGreen)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("edit_store_links".localized)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)

                    Text("edit_store_links_subtitle".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Show count of active links
                if !store.links.isEmpty {
                    Text("\(store.links.count)")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.primaryGreen)
                        .cornerRadius(10)
                }

                Image(systemName: "chevron.forward")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(.systemGray3))
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Form Field Helper

    @ViewBuilder
    private func formField<Content: View>(
        icon: String,
        iconColor: Color,
        title: String,
        isRequired: Bool = false,
        isOptional: Bool = false,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(iconColor)

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)

                if isOptional {
                    Text("(\(L10n.Common.optional.localized))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if isRequired {
                    Text("*")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.red)
                }
            }

            content()
        }
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let edited = info[.editedImage] as? UIImage {
                parent.image = edited
            } else if let original = info[.originalImage] as? UIImage {
                parent.image = original
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        EditStoreView(store: Store.sample, viewModel: MyStoreViewModel())
            .environmentObject(LocalizationManager.shared)
    }
}
