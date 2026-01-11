package com.preuvely.app.data.models

import com.google.gson.annotations.SerializedName

// Pagination metadata
data class PaginationMeta(
    @SerializedName("current_page") val currentPage: Int,
    @SerializedName("last_page") val lastPage: Int,
    @SerializedName("per_page") val perPage: Int,
    @SerializedName("total") val total: Int
) {
    val hasNextPage: Boolean
        get() = currentPage < lastPage

    val hasPreviousPage: Boolean
        get() = currentPage > 1
}

// Generic API response wrapper
data class ApiResponse<T>(
    @SerializedName("message") val message: String?,
    @SerializedName("data") val data: T?,
    @SerializedName("errors") val errors: Map<String, List<String>>?
)

// Message only response
data class MessageResponse(
    @SerializedName("message") val message: String
)

// Error response
data class ErrorResponse(
    @SerializedName("message") val message: String,
    @SerializedName("errors") val errors: Map<String, List<String>>?
) {
    val firstError: String
        get() = errors?.values?.flatten()?.firstOrNull() ?: message
}

// Sort options for store search
enum class StoreSortOption(val value: String) {
    BEST_RATED("best_rated"),
    MOST_REVIEWED("most_reviewed"),
    NEWEST("newest");

    val displayName: String
        get() = when (this) {
            BEST_RATED -> "Best Rated"
            MOST_REVIEWED -> "Most Reviewed"
            NEWEST -> "Newest"
        }
}

// Request bodies
data class LoginRequest(
    @SerializedName("email") val email: String? = null,
    @SerializedName("phone") val phone: String? = null,
    @SerializedName("password") val password: String
)

data class RegisterRequest(
    @SerializedName("name") val name: String,
    @SerializedName("email") val email: String?,
    @SerializedName("phone") val phone: String?,
    @SerializedName("password") val password: String,
    @SerializedName("password_confirmation") val passwordConfirmation: String
)

data class UpdateProfileRequest(
    @SerializedName("name") val name: String?,
    @SerializedName("phone") val phone: String?
)

data class CreateStoreRequest(
    @SerializedName("name") val name: String,
    @SerializedName("description") val description: String?,
    @SerializedName("city") val city: String?,
    @SerializedName("category_ids") val categoryIds: List<Int>,
    @SerializedName("links") val links: List<StoreLinkInput>?,
    @SerializedName("contacts") val contacts: StoreContactInput?
)

data class StoreLinkInput(
    @SerializedName("id") val id: Int? = null,
    @SerializedName("platform") val platform: String,
    @SerializedName("url") val url: String,
    @SerializedName("handle") val handle: String?
)

data class StoreContactInput(
    @SerializedName("whatsapp") val whatsapp: String?,
    @SerializedName("phone") val phone: String?
)

data class UpdateStoreRequest(
    @SerializedName("name") val name: String?,
    @SerializedName("description") val description: String?,
    @SerializedName("city") val city: String?
)

data class UpdateStoreLinksRequest(
    @SerializedName("links") val links: List<StoreLinkInput>
)

data class CreateReviewRequest(
    @SerializedName("stars") val stars: Int,
    @SerializedName("comment") val comment: String
)

data class CreateClaimRequest(
    @SerializedName("requester_name") val requesterName: String,
    @SerializedName("requester_phone") val requesterPhone: String,
    @SerializedName("note") val note: String?
)

data class CreateReportRequest(
    @SerializedName("reportable_type") val reportableType: String,
    @SerializedName("reportable_id") val reportableId: Int,
    @SerializedName("reason") val reason: String,
    @SerializedName("note") val note: String?
)

data class CreateReplyRequest(
    @SerializedName("reply_text") val replyText: String
)

data class SocialAuthRequest(
    @SerializedName("code") val code: String? = null,
    @SerializedName("id_token") val idToken: String? = null
)

data class VerifyEmailRequest(
    @SerializedName("code") val code: String
)
