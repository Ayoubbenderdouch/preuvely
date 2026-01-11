import SwiftUI
import PhotosUI
import Combine

// MARK: - My Store ViewModel

@MainActor
final class MyStoreViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var ownedStores: [OwnedStore] = []
    @Published var isLoading = false
    @Published var isLoadingStore = false
    @Published var isSaving = false
    @Published var isUploadingLogo = false

    @Published var errorMessage: String?
    @Published var showError = false
    @Published var saveSuccess = false

    // Store being edited
    @Published var editingStore: Store?

    // Edit form fields
    @Published var storeName: String = ""
    @Published var storeDescription: String = ""
    @Published var storeCity: String = ""
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var logoImage: UIImage?

    // Links editing
    @Published var storeLinks: [EditableStoreLink] = []

    // MARK: - Private Properties

    private let apiClient: APIClient
    private var originalName: String = ""
    private var originalDescription: String = ""
    private var originalCity: String = ""
    private var originalLogoImage: UIImage?

    // MARK: - Computed Properties

    var hasStoreChanges: Bool {
        storeName != originalName ||
        storeDescription != originalDescription ||
        storeCity != originalCity ||
        logoImage != originalLogoImage
    }

    var hasLinkChanges: Bool {
        // Check if links have been modified
        guard let store = editingStore else { return false }

        let originalLinks = store.links
        let currentLinks = storeLinks.filter { !$0.url.isEmpty }

        if originalLinks.count != currentLinks.count { return true }

        for (index, originalLink) in originalLinks.enumerated() {
            guard index < currentLinks.count else { return true }
            let currentLink = currentLinks[index]
            if originalLink.platform != currentLink.platform || originalLink.url != currentLink.url {
                return true
            }
        }

        return false
    }

    var isFormValid: Bool {
        !storeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Initialization

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    // MARK: - Public Methods

    /// Fetch all stores owned by the current user
    func fetchOwnedStores() async {
        guard apiClient.isAuthenticated else {
            ownedStores = []
            return
        }

        isLoading = true

        do {
            let stores = try await apiClient.getMyStores()
            ownedStores = stores
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    /// Load a specific store for editing
    func loadStore(_ store: Store) async {
        isLoadingStore = true
        editingStore = store

        // Pre-populate form fields
        storeName = store.name
        storeDescription = store.description ?? ""
        storeCity = store.city ?? ""

        // Store original values for change detection
        originalName = store.name
        originalDescription = store.description ?? ""
        originalCity = store.city ?? ""
        originalLogoImage = nil
        logoImage = nil

        // Load store links
        storeLinks = store.links.map { EditableStoreLink(from: $0) }

        // Add empty link slots for missing platforms
        for platform in Platform.allCases {
            if !storeLinks.contains(where: { $0.platform == platform }) {
                storeLinks.append(EditableStoreLink(platform: platform, url: ""))
            }
        }

        // Sort links by platform order
        storeLinks.sort { $0.platform.sortOrder < $1.platform.sortOrder }

        isLoadingStore = false
    }

    /// Load image from PhotosPicker selection
    func loadImage() async {
        guard let item = selectedPhoto else { return }

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                logoImage = image
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    /// Update store information
    func updateStoreInfo() async {
        guard let store = editingStore, isFormValid else { return }

        isSaving = true
        saveSuccess = false

        do {
            // Upload logo if changed
            if let newLogo = logoImage, newLogo != originalLogoImage {
                _ = try await apiClient.uploadStoreLogo(storeId: store.id, image: newLogo)
            }

            // Update store info
            let request = UpdateStoreRequest(
                name: storeName.trimmingCharacters(in: .whitespacesAndNewlines),
                description: storeDescription.isEmpty ? nil : storeDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                city: storeCity.isEmpty ? nil : storeCity.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            let updatedStore = try await apiClient.updateStore(storeId: store.id, request: request)

            // Update local state
            editingStore = updatedStore
            originalName = updatedStore.name
            originalDescription = updatedStore.description ?? ""
            originalCity = updatedStore.city ?? ""
            originalLogoImage = logoImage

            saveSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isSaving = false
    }

    /// Update store social links
    func updateStoreLinks() async {
        guard let store = editingStore else { return }

        isSaving = true
        saveSuccess = false

        do {
            // Filter out empty links and convert to StoreLink format
            let linksToUpdate = storeLinks
                .filter { !$0.url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                .enumerated()
                .map { index, link in
                    StoreLink(
                        id: index + 1,
                        platform: link.platform,
                        url: link.url.trimmingCharacters(in: .whitespacesAndNewlines),
                        handle: nil
                    )
                }

            let updatedLinks = try await apiClient.updateStoreLinks(storeId: store.id, links: linksToUpdate)

            // Update local state with new links
            storeLinks = updatedLinks.map { EditableStoreLink(from: $0) }

            // Add empty link slots for missing platforms
            for platform in Platform.allCases {
                if !storeLinks.contains(where: { $0.platform == platform }) {
                    storeLinks.append(EditableStoreLink(platform: platform, url: ""))
                }
            }
            storeLinks.sort { $0.platform.sortOrder < $1.platform.sortOrder }

            // Update the editingStore links
            if let currentStore = editingStore {
                editingStore = Store(
                    id: currentStore.id,
                    name: currentStore.name,
                    slug: currentStore.slug,
                    description: currentStore.description,
                    city: currentStore.city,
                    logo: currentStore.logo,
                    isVerified: currentStore.isVerified,
                    avgRating: currentStore.avgRating,
                    reviewsCount: currentStore.reviewsCount,
                    categories: currentStore.categories,
                    links: updatedLinks,
                    contacts: currentStore.contacts,
                    createdAt: currentStore.createdAt
                )
            }

            saveSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isSaving = false
    }

    /// Reset form to original values
    func resetForm() {
        storeName = originalName
        storeDescription = originalDescription
        storeCity = originalCity
        logoImage = originalLogoImage
        selectedPhoto = nil
    }
}

// MARK: - Editable Store Link

struct EditableStoreLink: Identifiable {
    let id = UUID()
    var platform: Platform
    var url: String

    init(platform: Platform, url: String) {
        self.platform = platform
        self.url = url
    }

    init(from storeLink: StoreLink) {
        self.platform = storeLink.platform
        self.url = storeLink.url
    }
}

// MARK: - Platform Extension

extension Platform {
    var sortOrder: Int {
        switch self {
        case .website: return 0
        case .instagram: return 1
        case .facebook: return 2
        case .tiktok: return 3
        case .whatsapp: return 4
        }
    }

    var placeholder: String {
        switch self {
        case .website: return "https://example.com"
        case .instagram: return "@username"
        case .facebook: return "facebook.com/page or @page"
        case .tiktok: return "@username"
        case .whatsapp: return "+213 555 123 456"
        }
    }

    var keyboardType: UIKeyboardType {
        switch self {
        case .website: return .URL
        case .whatsapp: return .phonePad
        default: return .default
        }
    }

    var iconColor: Color {
        switch self {
        case .website: return .primaryGreen
        case .instagram: return .instagramPink
        case .facebook: return .facebookBlue
        case .tiktok: return .black
        case .whatsapp: return .whatsappGreen
        }
    }
}

