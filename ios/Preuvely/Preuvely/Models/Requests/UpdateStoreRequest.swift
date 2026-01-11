import Foundation

// MARK: - Update Store Request

/// Request model for updating store information
struct UpdateStoreRequest: Encodable {
    let name: String?
    let description: String?
    let city: String?

    /// Creates an update store request with optional fields
    /// - Parameters:
    ///   - name: The new store name (optional)
    ///   - description: The new store description (optional)
    ///   - city: The new store city (optional)
    init(name: String? = nil, description: String? = nil, city: String? = nil) {
        self.name = name
        self.description = description
        self.city = city
    }
}
