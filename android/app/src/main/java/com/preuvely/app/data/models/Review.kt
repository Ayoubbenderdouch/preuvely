package com.preuvely.app.data.models

import com.google.gson.annotations.SerializedName
import java.text.SimpleDateFormat
import java.util.*

enum class ReviewStatus(val value: String) {
    @SerializedName("pending") PENDING("pending"),
    @SerializedName("approved") APPROVED("approved"),
    @SerializedName("rejected") REJECTED("rejected")
}

enum class ProofStatus(val value: String) {
    @SerializedName("pending") PENDING("pending"),
    @SerializedName("approved") APPROVED("approved"),
    @SerializedName("rejected") REJECTED("rejected")
}

data class Proof(
    @SerializedName("id") val id: Int,
    @SerializedName("url") val url: String,
    @SerializedName("status") val status: ProofStatus,
    @SerializedName("created_at") val createdAt: String?
)

data class StoreReply(
    @SerializedName("id") val id: Int,
    @SerializedName("reply_text") val replyText: String,
    @SerializedName("user") val user: ReviewUser,
    @SerializedName("created_at") val createdAt: String?
) {
    val userName: String
        get() = user.name
}

data class ReviewUser(
    @SerializedName("id") val id: Int,
    @SerializedName("name") val name: String,
    @SerializedName("avatar") val avatar: String?
) {
    val initials: String
        get() {
            val parts = name.trim().split(" ")
            return when {
                parts.size >= 2 -> "${parts[0].firstOrNull()?.uppercase() ?: ""}${parts[1].firstOrNull()?.uppercase() ?: ""}"
                parts.isNotEmpty() -> parts[0].take(2).uppercase()
                else -> "??"
            }
        }
}

data class ReviewStore(
    @SerializedName("id") val id: Int,
    @SerializedName("name") val name: String,
    @SerializedName("slug") val slug: String
)

data class Review(
    @SerializedName("id") val id: Int,
    @SerializedName("stars") val stars: Int,
    @SerializedName("comment") val comment: String,
    @SerializedName("status") val status: ReviewStatus,
    @SerializedName("is_high_risk") val isHighRisk: Boolean = false,
    @SerializedName("user") val user: ReviewUser,
    @SerializedName("proof") val proof: Proof?,
    @SerializedName("reply") val reply: StoreReply?,
    @SerializedName("store") val store: ReviewStore?,
    @SerializedName("created_at") val createdAt: String?
) {
    val userId: Int
        get() = user.id

    val userName: String
        get() = user.name

    val userAvatar: String?
        get() = user.avatar

    val hasProof: Boolean
        get() = proof != null

    val hasVerifiedProof: Boolean
        get() = proof?.status == ProofStatus.APPROVED

    val formattedDate: String
        get() {
            createdAt ?: return ""
            return try {
                val inputFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
                val outputFormat = SimpleDateFormat("MMM d, yyyy", Locale.getDefault())
                val date = inputFormat.parse(createdAt)
                date?.let { outputFormat.format(it) } ?: ""
            } catch (e: Exception) {
                ""
            }
        }

    val relativeDate: String
        get() {
            createdAt ?: return ""
            return try {
                val inputFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
                val date = inputFormat.parse(createdAt) ?: return ""
                val now = Date()
                val diffMs = now.time - date.time
                val diffDays = diffMs / (1000 * 60 * 60 * 24)

                when {
                    diffDays == 0L -> "Today"
                    diffDays == 1L -> "Yesterday"
                    diffDays < 7 -> "$diffDays days ago"
                    diffDays < 30 -> "${diffDays / 7} weeks ago"
                    diffDays < 365 -> "${diffDays / 30} months ago"
                    else -> "${diffDays / 365} years ago"
                }
            } catch (e: Exception) {
                ""
            }
        }
}

data class ReviewListResponse(
    @SerializedName("data") val data: List<Review>,
    @SerializedName("meta") val meta: PaginationMeta?
)

data class ReviewResponse(
    @SerializedName("message") val message: String?,
    @SerializedName("requires_proof") val requiresProof: Boolean?,
    @SerializedName("data") val data: Review
)

data class UserReviewResponse(
    @SerializedName("has_reviewed") val hasReviewed: Boolean,
    @SerializedName("data") val data: Review?
)

data class ProofUploadResponse(
    @SerializedName("message") val message: String,
    @SerializedName("data") val data: Proof
)

data class ReplyResponse(
    @SerializedName("message") val message: String,
    @SerializedName("data") val data: StoreReply
)
