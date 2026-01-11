package com.preuvely.app.data.models

import androidx.compose.ui.graphics.Color
import com.google.gson.annotations.SerializedName

enum class BannerLinkType(val value: String) {
    @SerializedName("none") NONE("none"),
    @SerializedName("store") STORE("store"),
    @SerializedName("category") CATEGORY("category"),
    @SerializedName("url") URL("url")
}

data class Banner(
    @SerializedName("id") val id: Int,
    @SerializedName("title") val title: String?,
    @SerializedName("subtitle") val subtitle: String?,
    @SerializedName("image_url") val imageUrl: String,
    @SerializedName("background_color") val backgroundColor: String,
    @SerializedName("link_type") val linkType: BannerLinkType,
    @SerializedName("link_value") val linkValue: String?
) {
    val color: Color
        get() = try {
            Color(android.graphics.Color.parseColor(backgroundColor))
        } catch (e: Exception) {
            Color(0xFF007359) // Default to primary green
        }

    val hasLink: Boolean
        get() = linkType != BannerLinkType.NONE && !linkValue.isNullOrBlank()
}

data class BannerListResponse(
    @SerializedName("data") val data: List<Banner>
)
