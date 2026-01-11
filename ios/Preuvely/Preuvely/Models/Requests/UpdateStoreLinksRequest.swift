import Foundation

// MARK: - Update Store Links Request

/// Request model for updating store links
struct UpdateStoreLinksRequest: Encodable {
    let links: [StoreLinkInput]

    /// Creates an update store links request
    /// - Parameter links: Array of store link inputs
    init(links: [StoreLinkInput]) {
        self.links = links
    }

    /// Convenience initializer from StoreLink array
    /// - Parameter storeLinks: Array of StoreLink models
    init(storeLinks: [StoreLink]) {
        self.links = storeLinks.map { StoreLinkInput(from: $0) }
    }
}

// MARK: - Store Link Input

/// Input model for creating or updating a store link
struct StoreLinkInput: Encodable {
    let id: Int?
    let platform: Platform
    let url: String
    let handle: String?

    /// Creates a new store link input
    /// - Parameters:
    ///   - id: The link ID (nil for new links)
    ///   - platform: The platform type
    ///   - url: The link URL
    ///   - handle: Optional handle/username
    init(id: Int? = nil, platform: Platform, url: String, handle: String? = nil) {
        self.id = id
        self.platform = platform
        self.url = url
        self.handle = handle
    }

    /// Creates a store link input from an existing StoreLink
    /// - Parameter storeLink: The existing store link
    init(from storeLink: StoreLink) {
        self.id = storeLink.id
        self.platform = storeLink.platform
        self.url = storeLink.url
        self.handle = storeLink.handle
    }
}
