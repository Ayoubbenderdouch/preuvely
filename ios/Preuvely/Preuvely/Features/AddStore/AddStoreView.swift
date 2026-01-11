import SwiftUI
import Combine
import PhotosUI
import UIKit

struct AddStoreView: View {
    @StateObject private var viewModel: AddStoreViewModel
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var apiClient: APIClient
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    @State private var appearAnimation = false
    @State private var showAuthSheet = false
    @State private var pendingSubmit = false
    @State private var categories: [Category] = []
    @State private var isLoadingCategories = true
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var navigateToExistingStore = false

    enum Field {
        case name, link, whatsapp
    }

    init(prefillName: String = "") {
        _viewModel = StateObject(wrappedValue: AddStoreViewModel(prefillName: prefillName))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header
                headerSection
                    .offset(y: appearAnimation ? 0 : -20)
                    .opacity(appearAnimation ? 1 : 0)

                // Store Logo (Optional)
                logoSection
                    .offset(y: appearAnimation ? 0 : 20)
                    .opacity(appearAnimation ? 1 : 0)

                // Store Name
                storeNameSection
                    .offset(y: appearAnimation ? 0 : 20)
                    .opacity(appearAnimation ? 1 : 0)

                // Platform Selection
                platformSection
                    .offset(y: appearAnimation ? 0 : 20)
                    .opacity(appearAnimation ? 1 : 0)

                // Contact Info (Optional)
                contactSection
                    .offset(y: appearAnimation ? 0 : 20)
                    .opacity(appearAnimation ? 1 : 0)

                // Categories (Optional)
                detailsSection
                    .offset(y: appearAnimation ? 0 : 20)
                    .opacity(appearAnimation ? 1 : 0)

                // Info Banner
                infoBanner
                    .offset(y: appearAnimation ? 0 : 20)
                    .opacity(appearAnimation ? 1 : 0)

                // Submit
                submitSection
                    .offset(y: appearAnimation ? 0 : 20)
                    .opacity(appearAnimation ? 1 : 0)

                Spacer(minLength: 120)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .background(
            LinearGradient(
                colors: [Color(.systemGray6), Color(.systemGray5).opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationTitle(L10n.AddStore.title.localized)
        .navigationBarTitleDisplayMode(.inline)
        .alert(L10n.AddStore.storeAddedTitle.localized, isPresented: $viewModel.showSuccess) {
            Button(L10n.Common.ok.localized) {
                dismiss()
            }
        } message: {
            Text("add_store_pending_review".localized)
        }
        .alert(L10n.Common.error.localized, isPresented: .init(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Button(L10n.Common.ok.localized, role: .cancel) {
                viewModel.error = nil
            }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "add_store_error_generic".localized)
        }
        .loadingOverlay(viewModel.isSubmitting)
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(L10n.Common.done.localized) {
                    focusedField = nil
                }
                .fontWeight(.semibold)
            }
        }
        .sheet(isPresented: $showAuthSheet) {
            AuthView()
                .onDisappear {
                    // Check if user is now authenticated and auto-submit
                    if APIClient.shared.isAuthenticated && pendingSubmit {
                        pendingSubmit = false
                        Task {
                            await viewModel.submitStore(logo: selectedImage)
                        }
                    }
                }
        }
        .sheet(isPresented: $viewModel.showDuplicateStoreSheet) {
            if let existingStore = viewModel.duplicateStore {
                DuplicateStoreSheet(
                    existingStore: existingStore,
                    onViewStore: {
                        viewModel.showDuplicateStoreSheet = false
                        navigateToExistingStore = true
                    },
                    onDismiss: {
                        viewModel.showDuplicateStoreSheet = false
                        viewModel.duplicateStore = nil
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
        .navigationDestination(isPresented: $navigateToExistingStore) {
            if let store = viewModel.duplicateStore {
                StoreDetailsView(store: store)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appearAnimation = true
            }
            loadCategories()
        }
    }

    private func loadCategories() {
        Task {
            do {
                categories = try await apiClient.getCategories()
            } catch {
                print("Failed to load categories: \(error)")
            }
            isLoadingCategories = false
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
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

                Image(systemName: "storefront.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            Text(L10n.AddStore.addToPreuvely.localized)
                .font(.title3.weight(.bold))
                .foregroundColor(.primary)

            Text(L10n.AddStore.helpOthersDiscover.localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 20)
    }

    // MARK: - Logo Section

    private var logoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(icon: "photo.fill", title: "add_store_logo".localized, required: false)

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.primaryGreen, lineWidth: 2)
                        )
                        .overlay(alignment: .topTrailing) {
                            Button {
                                selectedImage = nil
                                selectedPhotoItem = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.red)
                                    .background(Circle().fill(.white))
                            }
                            .offset(x: 8, y: -8)
                        }
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.primaryGreen)

                        Text("add_store_add_logo".localized)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.primaryGreen)
                    }
                    .frame(width: 100, height: 100)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.primaryGreen.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                                    .foregroundColor(.primaryGreen.opacity(0.5))
                            )
                    )
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .center)
            .onChange(of: selectedPhotoItem) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                    }
                }
            }

            Text("add_store_logo_hint".localized)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(18)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }

    // MARK: - Store Name Section

    private var storeNameSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(icon: "tag.fill", title: L10n.AddStore.storeName.localized, required: true)

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.primaryGreen.opacity(0.1))
                        .frame(width: 36, height: 36)

                    Image(systemName: "character.cursor.ibeam")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primaryGreen)
                }

                TextField(L10n.AddStore.storeNamePlaceholder.localized, text: $viewModel.name)
                    .font(.body)
                    .focused($focusedField, equals: .name)
            }
            .padding(14)
            .background(Color(.systemGray6))
            .cornerRadius(14)
        }
        .padding(18)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }

    // MARK: - Platform Section

    private var platformSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "app.badge.fill", title: L10n.AddStore.platform.localized, required: true)

            // Platform Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Platform.allCases.filter { $0 != .whatsapp }) { platform in
                        PlatformPill(
                            platform: platform,
                            isSelected: viewModel.selectedPlatform == platform,
                            hasLink: viewModel.hasLink(for: platform)
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.selectedPlatform = platform
                            }
                        }
                    }
                }
            }

            // Link Input
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.primaryGreen.opacity(0.1))
                        .frame(width: 36, height: 36)

                    Image(systemName: "link")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primaryGreen)
                }

                TextField(platformPlaceholder, text: Binding(
                    get: { viewModel.currentLink },
                    set: { viewModel.currentLink = $0 }
                ))
                    .font(.body)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: .link)
            }
            .padding(14)
            .background(Color(.systemGray6))
            .cornerRadius(14)
        }
        .padding(18)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }

    // MARK: - Contact Section

    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "message.fill", title: "WhatsApp", required: false)

            // WhatsApp
            HStack(spacing: 12) {
                Image("Whatsapp")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)

                PhoneNumberTextField(
                    text: $viewModel.whatsapp,
                    placeholder: "+213 555 123 456"
                )
                .frame(maxWidth: .infinity, minHeight: 36)
            }
            .padding(14)
            .background(Color.whatsappGreen.opacity(0.08))
            .cornerRadius(14)
            .contentShape(Rectangle())
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.whatsappGreen.opacity(0.2), lineWidth: 1)
                    .allowsHitTesting(false)
            )
        }
        .padding(18)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }

    // MARK: - Categories Section

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "square.grid.2x2.fill", title: L10n.AddStore.categories.localized, required: true)

            // Categories Grid - Direct Selection
            let columns = [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]

            if isLoadingCategories {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding(.vertical, 20)
            } else if categories.isEmpty {
                Text("No categories available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(categories) { category in
                        CategorySelectButton(
                            category: category,
                            isSelected: viewModel.selectedCategories.contains(category)
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                toggleCategory(category)
                            }
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }

    private func toggleCategory(_ category: Category) {
        if let index = viewModel.selectedCategories.firstIndex(of: category) {
            viewModel.selectedCategories.remove(at: index)
        } else {
            viewModel.selectedCategories.append(category)
        }
    }

    // MARK: - Info Banner

    private var infoBanner: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: "info.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("add_store_review_notice_title".localized)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)

                Text("add_store_review_notice_message".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.15), lineWidth: 1)
                )
        )
    }

    // MARK: - Submit Section

    private var submitSection: some View {
        Button {
            // Check if user is authenticated
            if !APIClient.shared.isAuthenticated {
                // Show auth sheet and mark as pending submit
                pendingSubmit = true
                showAuthSheet = true
            } else {
                // User is authenticated, submit directly
                Task {
                    await viewModel.submitStore(logo: selectedImage)
                }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18))
                Text(L10n.AddStore.submit.localized)
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: viewModel.isValid
                        ? [Color.primaryGreen, Color.primaryGreen.opacity(0.8)]
                        : [Color(.systemGray4), Color(.systemGray4)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: viewModel.isValid ? Color.primaryGreen.opacity(0.3) : .clear, radius: 10, x: 0, y: 5)
        }
        .disabled(!viewModel.isValid)
        .scaleEffect(viewModel.isValid ? 1.0 : 0.98)
        .animation(.spring(response: 0.3), value: viewModel.isValid)
    }

    // MARK: - Helpers

    private func sectionHeader(icon: String, title: String, required: Bool = false) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primaryGreen)

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)

            if !required {
                Text("(\(L10n.Common.optional.localized))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var platformPlaceholder: String {
        switch viewModel.selectedPlatform {
        case .instagram: return "@storename"
        case .facebook: return "facebook.com/storename"
        case .tiktok: return "@storename"
        case .website: return "https://store.com"
        default: return L10n.AddStore.enterLinkOrHandle.localized
        }
    }
}

// MARK: - Platform Pill

struct PlatformPill: View {
    let platform: Platform
    let isSelected: Bool
    var hasLink: Bool = false
    let action: () -> Void

    private var iconName: String? {
        switch platform {
        case .instagram: return "Instagram"
        case .facebook: return "facebook"
        case .tiktok: return "Tiktok"
        case .whatsapp: return "Whatsapp"
        case .website: return nil
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let iconName = iconName {
                    Image(iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                } else {
                    Image(systemName: "globe")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isSelected ? .white : .primaryGreen)
                }

                if isSelected {
                    Text(platform.displayName)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white)
                }

                // Checkmark indicator when platform has a link
                if hasLink && !isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.primaryGreen)
                }
            }
            .padding(.horizontal, isSelected ? 14 : 12)
            .padding(.vertical, 10)
            .background(
                isSelected
                    ? AnyView(LinearGradient(
                        colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    : AnyView(hasLink ? Color.primaryGreen.opacity(0.15) : Color(.systemGray6))
            )
            .cornerRadius(25)
            .shadow(color: isSelected ? Color.primaryGreen.opacity(0.3) : .clear, radius: 5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(hasLink && !isSelected ? Color.primaryGreen.opacity(0.3) : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Category Select Button

struct CategorySelectButton: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void

    @EnvironmentObject private var localizationManager: LocalizationManager

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.sfSymbol)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primaryGreen)

                Text(category.localizedName(for: localizationManager.currentLanguage))
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                isSelected
                    ? AnyView(LinearGradient(
                        colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    : AnyView(Color(.systemGray6))
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color(.systemGray5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
    }
}

// MARK: - Add Store ViewModel

@MainActor
final class AddStoreViewModel: ObservableObject {
    @Published var name = ""
    @Published var selectedPlatform: Platform = .instagram
    @Published var platformLinks: [Platform: String] = [:] // Each platform has its own URL
    @Published var whatsapp = ""
    @Published var selectedCategories: [Category] = []

    @Published var isSubmitting = false
    @Published var showSuccess = false
    @Published var error: Error?
    @Published var duplicateStore: Store?
    @Published var showDuplicateStoreSheet = false

    private let apiClient: APIClient

    /// Current link for the selected platform
    var currentLink: String {
        get { platformLinks[selectedPlatform] ?? "" }
        set { platformLinks[selectedPlatform] = newValue }
    }

    /// All non-empty links
    var allLinks: [CreateStoreLinkRequest] {
        platformLinks.compactMap { platform, url in
            guard !url.isEmpty else { return nil }
            return CreateStoreLinkRequest(
                platform: platform,
                url: url,
                handle: extractHandle(from: url, platform: platform)
            )
        }
    }

    var isValid: Bool {
        !name.isEmpty && !allLinks.isEmpty && !selectedCategories.isEmpty
    }

    /// Check if a platform has a link entered
    func hasLink(for platform: Platform) -> Bool {
        guard let link = platformLinks[platform] else { return false }
        return !link.isEmpty
    }

    init(prefillName: String = "", apiClient: APIClient = .shared) {
        self.name = prefillName
        self.apiClient = apiClient
    }

    func submitStore(logo: UIImage? = nil) async {
        isSubmitting = true
        error = nil
        duplicateStore = nil

        do {
            let request = CreateStoreRequest(
                name: name,
                description: nil,
                city: nil,
                categoryIds: selectedCategories.map { $0.id },
                links: allLinks,
                contacts: CreateStoreContactRequest(
                    whatsapp: whatsapp.isEmpty ? nil : whatsapp,
                    phone: nil
                )
            )

            _ = try await apiClient.createStore(request: request, logo: logo)
            showSuccess = true
        } catch let apiError as APIError {
            // Handle duplicate store error specially
            if case .duplicateStore(let existingStore) = apiError {
                self.duplicateStore = existingStore
                self.showDuplicateStoreSheet = true
            } else {
                self.error = apiError
            }
        } catch {
            self.error = error
        }

        isSubmitting = false
    }

    func reset() {
        name = ""
        selectedPlatform = .instagram
        platformLinks = [:]
        whatsapp = ""
        selectedCategories = []
    }

    private func extractHandle(from url: String, platform: Platform) -> String? {
        // Only extract handle for social platforms
        guard platform == .instagram || platform == .tiktok || platform == .facebook else {
            return nil
        }

        if url.starts(with: "@") {
            return url
        }
        if let lastComponent = url.split(separator: "/").last, !lastComponent.isEmpty {
            let handle = String(lastComponent)
            return handle.starts(with: "@") ? handle : "@\(handle)"
        }
        return nil
    }
}

// MARK: - Duplicate Store Sheet

struct DuplicateStoreSheet: View {
    let existingStore: Store
    let onViewStore: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Warning Icon
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.orange)
            }
            .padding(.top, 20)

            // Title & Message
            VStack(spacing: 12) {
                Text("duplicate_store_title".localized)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                Text("duplicate_store_message".localized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Existing Store Card
            existingStoreCard

            Spacer()

            // Action Buttons
            VStack(spacing: 12) {
                // View Existing Store Button
                Button {
                    onViewStore()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "storefront.fill")
                            .font(.system(size: 16))
                        Text("duplicate_store_view_existing".localized)
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }

                // Cancel Button
                Button {
                    onDismiss()
                } label: {
                    Text("common_cancel".localized)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color(.systemBackground))
    }

    private var existingStoreCard: some View {
        HStack(spacing: 16) {
            // Store Logo or Initial
            ZStack {
                if let logoURL = existingStore.logo, let url = URL(string: logoURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        default:
                            storeInitialView
                        }
                    }
                } else {
                    storeInitialView
                }
            }

            // Store Info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(existingStore.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    if existingStore.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.primaryGreen)
                    }
                }

                // Rating
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.starYellow)

                    Text(String(format: "%.1f", existingStore.avgRating))
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.primary)

                    Text("(\(existingStore.reviewsCount))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Platform badges
                if !existingStore.platformBadges.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(existingStore.platformBadges.prefix(3), id: \.self) { platform in
                            platformIcon(for: platform)
                        }
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
    }

    private var storeInitialView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [Color.primaryGreen.opacity(0.2), Color.primaryGreen.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)

            Text(existingStore.name.prefix(1).uppercased())
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primaryGreen)
        }
    }

    @ViewBuilder
    private func platformIcon(for platform: Platform) -> some View {
        switch platform {
        case .instagram:
            Image("Instagram")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
        case .facebook:
            Image("facebook")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
        case .tiktok:
            Image("Tiktok")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
        case .whatsapp:
            Image("Whatsapp")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
        case .website:
            Image(systemName: "globe")
                .font(.system(size: 14))
                .foregroundColor(.primaryGreen)
                .frame(width: 20, height: 20)
        }
    }
}

// MARK: - Phone Number TextField (UIKit-based)

/// A UIKit-based TextField specifically for phone numbers.
/// This bypasses SwiftUI text rendering to avoid encoding issues.
struct PhoneNumberTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        textField.keyboardType = .phonePad
        textField.textContentType = .telephoneNumber
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.textColor = UIColor.label
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.semanticContentAttribute = .forceLeftToRight
        textField.textAlignment = .left
        textField.isUserInteractionEnabled = true
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange(_:)), for: .editingChanged)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        @objc func textFieldDidChange(_ textField: UITextField) {
            // Only allow digits and + symbol
            let filtered = textField.text?.filter { $0.isNumber || $0 == "+" } ?? ""
            if textField.text != filtered {
                textField.text = filtered
            }
            text = filtered
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // Allow backspace
            if string.isEmpty { return true }
            // Only allow digits and +
            let allowedCharacters = CharacterSet(charactersIn: "0123456789+")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AddStoreView(prefillName: "Test Store")
            .environmentObject(LocalizationManager.shared)
    }
}

#Preview("Duplicate Store Sheet") {
    DuplicateStoreSheet(
        existingStore: Store.sample,
        onViewStore: {},
        onDismiss: {}
    )
}
