import Foundation

// MARK: - Category Service Protocol

protocol CategoryServiceProtocol {
    /// Get all categories
    func getCategories() async throws -> [Category]

    /// Get category by slug
    func getCategory(slug: String) async throws -> Category
}
