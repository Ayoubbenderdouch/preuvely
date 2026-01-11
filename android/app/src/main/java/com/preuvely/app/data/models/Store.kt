package com.preuvely.app.data.models

import com.google.gson.annotations.SerializedName

enum class Platform(val value: String) {
    @SerializedName("instagram") INSTAGRAM("instagram"),
    @SerializedName("facebook") FACEBOOK("facebook"),
    @SerializedName("tiktok") TIKTOK("tiktok"),
    @SerializedName("website") WEBSITE("website"),
    @SerializedName("whatsapp") WHATSAPP("whatsapp");

    val displayName: String
        get() = when (this) {
            INSTAGRAM -> "Instagram"
            FACEBOOK -> "Facebook"
            TIKTOK -> "TikTok"
            WEBSITE -> "Website"
            WHATSAPP -> "WhatsApp"
        }

    val sortOrder: Int
        get() = when (this) {
            INSTAGRAM -> 0
            FACEBOOK -> 1
            TIKTOK -> 2
            WEBSITE -> 3
            WHATSAPP -> 4
        }

    companion object {
        fun fromValue(value: String): Platform? = entries.find { it.value == value }
    }
}

enum class StoreStatus(val value: String) {
    @SerializedName("active") ACTIVE("active"),
    @SerializedName("pending") PENDING("pending"),
    @SerializedName("suspended") SUSPENDED("suspended");

    companion object {
        fun fromValue(value: String?): StoreStatus = entries.find { it.value == value } ?: PENDING
    }
}

data class StoreLink(
    @SerializedName("id") val id: Int,
    @SerializedName("platform") val platform: Platform,
    @SerializedName("url") val url: String,
    @SerializedName("handle") val handle: String?
)

data class StoreContact(
    @SerializedName("whatsapp") val whatsapp: String?,
    @SerializedName("phone") val phone: String?
)

data class StoreSubmitter(
    @SerializedName("id") val id: Int,
    @SerializedName("name") val name: String,
    @SerializedName("avatar") val avatar: String?,
    @SerializedName("stores_count") val storesCount: Int,
    @SerializedName("reviews_count") val reviewsCount: Int
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

data class Store(
    @SerializedName("id") val id: Int,
    @SerializedName("name") val name: String,
    @SerializedName("slug") val slug: String,
    @SerializedName("description") val description: String?,
    @SerializedName("city") val city: String?,
    @SerializedName("logo") val logo: String?,
    @SerializedName("status") val status: String? = null,
    @SerializedName("is_verified") val isVerified: Boolean = false,
    @SerializedName("avg_rating") val avgRating: Double = 0.0,
    @SerializedName("reviews_count") val reviewsCount: Int = 0,
    @SerializedName("is_high_risk") val isHighRisk: Boolean = false,
    @SerializedName("categories") val categories: List<Category> = emptyList(),
    @SerializedName("links") val links: List<StoreLink> = emptyList(),
    @SerializedName("contacts") val contacts: StoreContact? = null,
    @SerializedName("created_at") val createdAt: String? = null,
    @SerializedName("submitter") val submitter: StoreSubmitter? = null
) {
    val formattedRating: String
        get() = String.format("%.1f", avgRating)

    val formattedReviewsCount: String
        get() = when {
            reviewsCount >= 1000 -> String.format("%.1fK", reviewsCount / 1000.0)
            else -> reviewsCount.toString()
        }

    val primaryPlatform: Platform?
        get() = links.minByOrNull { it.platform.sortOrder }?.platform

    val platformBadges: List<Platform>
        get() = links.map { it.platform }.distinct().sortedBy { it.sortOrder }

    val nameInitial: String
        get() = name.firstOrNull()?.uppercase() ?: "?"
}

data class StoreSummary(
    @SerializedName("avg_rating") val avgRating: Double,
    @SerializedName("reviews_count") val reviewsCount: Int,
    @SerializedName("is_verified") val isVerified: Boolean,
    @SerializedName("rating_breakdown") val ratingBreakdown: RatingBreakdown,
    @SerializedName("proof_badge") val proofBadge: Boolean
)

data class RatingBreakdown(
    @SerializedName("1") val one: Int = 0,
    @SerializedName("2") val two: Int = 0,
    @SerializedName("3") val three: Int = 0,
    @SerializedName("4") val four: Int = 0,
    @SerializedName("5") val five: Int = 0
) {
    val total: Int
        get() = one + two + three + four + five

    fun percentage(stars: Int): Float {
        if (total == 0) return 0f
        val count = when (stars) {
            1 -> one
            2 -> two
            3 -> three
            4 -> four
            5 -> five
            else -> 0
        }
        return count.toFloat() / total.toFloat()
    }
}

data class OwnedStore(
    @SerializedName("id") val id: Int,
    @SerializedName("name") val name: String,
    @SerializedName("slug") val slug: String,
    @SerializedName("description") val description: String?,
    @SerializedName("city") val city: String?,
    @SerializedName("logo") val logo: String?,
    @SerializedName("status") val status: String?,
    @SerializedName("is_verified") val isVerified: Boolean = false,
    @SerializedName("avg_rating") val avgRating: Double = 0.0,
    @SerializedName("reviews_count") val reviewsCount: Int = 0,
    @SerializedName("owner_role") val ownerRole: String?,
    @SerializedName("claim_status") val claimStatus: String?,
    @SerializedName("pending_reviews_count") val pendingReviewsCount: Int = 0,
    @SerializedName("is_high_risk") val isHighRisk: Boolean = false,
    @SerializedName("categories") val categories: List<Category> = emptyList(),
    @SerializedName("links") val links: List<StoreLink> = emptyList(),
    @SerializedName("contacts") val contacts: StoreContact? = null,
    @SerializedName("created_at") val createdAt: String?,
    @SerializedName("updated_at") val updatedAt: String?
) {
    fun toStore(): Store = Store(
        id = id,
        name = name,
        slug = slug,
        description = description,
        city = city,
        logo = logo,
        status = status,
        isVerified = isVerified,
        avgRating = avgRating,
        reviewsCount = reviewsCount,
        isHighRisk = isHighRisk,
        categories = categories,
        links = links,
        contacts = contacts,
        createdAt = createdAt
    )

    val formattedRating: String
        get() = String.format("%.1f", avgRating)

    val formattedReviewsCount: String
        get() = reviewsCount.toString()

    val nameInitial: String
        get() = name.firstOrNull()?.uppercase() ?: "?"
}

// API Response wrappers
data class StoreResponse(
    @SerializedName("data") val data: Store
)

data class StoreListResponse(
    @SerializedName("data") val data: List<Store>,
    @SerializedName("meta") val meta: PaginationMeta?
)

data class StoreSummaryResponse(
    @SerializedName("data") val data: StoreSummary
)

data class OwnedStoreListResponse(
    @SerializedName("data") val data: List<OwnedStore>
)

data class CreateStoreResponse(
    @SerializedName("message") val message: String,
    @SerializedName("data") val data: Store
)

data class UpdateStoreResponse(
    @SerializedName("message") val message: String,
    @SerializedName("data") val data: OwnedStore
)

data class StoreLinkListResponse(
    @SerializedName("data") val data: List<StoreLink>
)

data class LogoUploadResponse(
    @SerializedName("message") val message: String,
    @SerializedName("data") val data: LogoData
)

data class LogoData(
    @SerializedName("logo") val logo: String
)
