package com.preuvely.app.data.models

import com.google.gson.annotations.SerializedName

data class Category(
    @SerializedName("id") val id: Int,
    @SerializedName("name") val name: String,
    @SerializedName("name_ar") val nameAr: String?,
    @SerializedName("name_fr") val nameFr: String?,
    @SerializedName("name_en") val nameEn: String?,
    @SerializedName("slug") val slug: String,
    @SerializedName("icon_key") val iconKey: String?,
    @SerializedName("risk_level") val riskLevel: String?,
    @SerializedName("is_high_risk") val isHighRisk: Boolean = false,
    @SerializedName("show_on_home") val showOnHome: Boolean? = true,
    @SerializedName("stores_count") val storesCount: Int? = 0
) {
    fun localizedName(language: String): String {
        return when (language) {
            "ar" -> nameAr ?: name
            "fr" -> nameFr ?: name
            else -> nameEn ?: name
        }
    }

    val displayStoresCount: String
        get() = when {
            (storesCount ?: 0) >= 1000 -> String.format("%.1fK", (storesCount ?: 0) / 1000.0)
            else -> (storesCount ?: 0).toString()
        }

    val shouldShowOnHome: Boolean
        get() = showOnHome ?: true

    // Map slug/name to drawable resource ID
    val categoryDrawableRes: Int
        get() = when {
            slug.contains("beauty", ignoreCase = true) || name.contains("Beauty", ignoreCase = true) || name.contains("Cosmet", ignoreCase = true) -> com.preuvely.app.R.drawable.cat_beauty
            slug.contains("credit", ignoreCase = true) || name.contains("Credit", ignoreCase = true) || name.contains("Balance", ignoreCase = true) || name.contains("Soldes", ignoreCase = true) -> com.preuvely.app.R.drawable.cat_credits
            slug.contains("digital", ignoreCase = true) || name.contains("Digital", ignoreCase = true) || name.contains("Numerique", ignoreCase = true) -> com.preuvely.app.R.drawable.cat_digital
            slug.contains("electronic", ignoreCase = true) || name.contains("Electronic", ignoreCase = true) -> com.preuvely.app.R.drawable.cat_electronics
            slug.contains("fashion", ignoreCase = true) || name.contains("Fashion", ignoreCase = true) || name.contains("Mode", ignoreCase = true) -> com.preuvely.app.R.drawable.cat_fashion
            slug.contains("food", ignoreCase = true) || name.contains("Food", ignoreCase = true) || name.contains("Nourriture", ignoreCase = true) -> com.preuvely.app.R.drawable.cat_food
            slug.contains("kids", ignoreCase = true) || name.contains("Kids", ignoreCase = true) || name.contains("Toys", ignoreCase = true) || name.contains("Enfants", ignoreCase = true) || name.contains("Jouets", ignoreCase = true) -> com.preuvely.app.R.drawable.cat_kids
            slug.contains("supplement", ignoreCase = true) || name.contains("Supplement", ignoreCase = true) || name.contains("Wellness", ignoreCase = true) -> com.preuvely.app.R.drawable.cat_supplements
            slug.contains("travel", ignoreCase = true) || name.contains("Travel", ignoreCase = true) || name.contains("Voyage", ignoreCase = true) || name.contains("Agency", ignoreCase = true) -> com.preuvely.app.R.drawable.cat_travel
            else -> com.preuvely.app.R.drawable.cat_digital // Default fallback
        }
}

data class CategoryListResponse(
    @SerializedName("data") val data: List<Category>
)

data class CategoryResponse(
    @SerializedName("data") val data: Category
)
