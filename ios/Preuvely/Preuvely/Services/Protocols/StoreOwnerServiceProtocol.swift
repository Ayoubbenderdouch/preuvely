import Foundation
import UIKit

// MARK: - Store Owner Service Protocol

/// Protocol defining store owner management operations
protocol StoreOwnerServiceProtocol {
    /// Get all stores owned by the current user
    /// - Returns: Array of owned stores
    func getMyStores() async throws -> [OwnedStore]

    /// Update store information
    /// - Parameters:
    ///   - storeId: The store ID to update
    ///   - request: The update request containing new store data
    /// - Returns: The updated store
    func updateStore(storeId: Int, request: UpdateStoreRequest) async throws -> Store

    /// Upload or update store logo
    /// - Parameters:
    ///   - storeId: The store ID
    ///   - image: The new logo image
    /// - Returns: The updated store with new logo URL
    func uploadStoreLogo(storeId: Int, image: UIImage) async throws -> Store

    /// Get links for a specific store
    /// - Parameter storeId: The store ID
    /// - Returns: Array of store links
    func getStoreLinks(storeId: Int) async throws -> [StoreLink]

    /// Update store links
    /// - Parameters:
    ///   - storeId: The store ID
    ///   - links: Array of links to set
    /// - Returns: The updated array of store links
    func updateStoreLinks(storeId: Int, links: [StoreLink]) async throws -> [StoreLink]
}
