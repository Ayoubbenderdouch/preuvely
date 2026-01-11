import Foundation

// MARK: - Claim Service Protocol

protocol ClaimServiceProtocol {
    /// Get user's claims
    func getMyClaims() async throws -> [Claim]

    /// Submit a claim for a store
    func submitClaim(storeId: Int, request: CreateClaimRequest) async throws -> Claim
}

// MARK: - Create Claim Request

struct CreateClaimRequest: Encodable {
    let requesterName: String
    let requesterPhone: String
    let note: String?

    init(requesterName: String, requesterPhone: String, note: String? = nil) {
        self.requesterName = requesterName
        self.requesterPhone = requesterPhone
        self.note = note
    }

    enum CodingKeys: String, CodingKey {
        case requesterName = "requester_name"
        case requesterPhone = "requester_phone"
        case note
    }
}
