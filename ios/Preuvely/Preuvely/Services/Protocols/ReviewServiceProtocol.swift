import Foundation
import UIKit

// MARK: - Review Service Protocol

protocol ReviewServiceProtocol {
    /// Create a review for a store
    func createReview(storeId: Int, request: CreateReviewRequest) async throws -> Review

    /// Upload proof for a review
    func uploadProof(reviewId: Int, image: UIImage) async throws -> Proof

    /// Get user's review for a store
    func getUserReview(storeId: Int) async throws -> Review?

    /// Reply to a review (store owner only)
    func replyToReview(reviewId: Int, text: String) async throws -> StoreReply
}

// MARK: - Create Review Request

struct CreateReviewRequest: Encodable {
    let stars: Int
    let comment: String
}
