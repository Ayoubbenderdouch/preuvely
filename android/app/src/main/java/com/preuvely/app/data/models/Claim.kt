package com.preuvely.app.data.models

import com.google.gson.annotations.SerializedName
import java.text.SimpleDateFormat
import java.util.*

enum class ClaimStatus(val value: String) {
    @SerializedName("pending") PENDING("pending"),
    @SerializedName("approved") APPROVED("approved"),
    @SerializedName("rejected") REJECTED("rejected")
}

data class Claim(
    @SerializedName("id") val id: Int,
    @SerializedName("store_id") val storeId: Int,
    @SerializedName("store_name") val storeName: String?,
    @SerializedName("store_slug") val storeSlug: String?,
    @SerializedName("requester_name") val requesterName: String,
    @SerializedName("requester_phone") val requesterPhone: String,
    @SerializedName("note") val note: String?,
    @SerializedName("status") val status: ClaimStatus,
    @SerializedName("reject_reason") val rejectReason: String?,
    @SerializedName("created_at") val createdAt: String?
) {
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

    val displayStoreName: String
        get() = storeName ?: "Unknown Store"
}

data class ClaimListResponse(
    @SerializedName("data") val data: List<Claim>
)

data class ClaimResponse(
    @SerializedName("message") val message: String,
    @SerializedName("data") val data: Claim
)
