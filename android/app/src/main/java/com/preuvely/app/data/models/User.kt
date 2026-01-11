package com.preuvely.app.data.models

import com.google.gson.annotations.SerializedName

data class User(
    @SerializedName("id") val id: Int,
    @SerializedName("name") val name: String,
    @SerializedName("email") val email: String?,
    @SerializedName("phone") val phone: String?,
    @SerializedName("email_verified") val emailVerified: Boolean = false,
    @SerializedName("avatar") val avatar: String?,
    @SerializedName("created_at") val createdAt: String?
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

    val displayEmail: String
        get() = email ?: "No email"
}

sealed class AuthState {
    object Guest : AuthState()
    data class Authenticated(val user: User) : AuthState()
    data class EmailVerificationPending(val user: User) : AuthState()

    val isAuthenticated: Boolean
        get() = this is Authenticated || this is EmailVerificationPending

    val currentUser: User?
        get() = when (this) {
            is Authenticated -> this.user
            is EmailVerificationPending -> this.user
            is Guest -> null
        }

    val needsEmailVerification: Boolean
        get() = this is EmailVerificationPending
}

data class AuthResponse(
    @SerializedName("message") val message: String,
    @SerializedName("user") val user: User,
    @SerializedName("token") val token: String,
    @SerializedName("email_verified") val emailVerified: Boolean? = null,
    @SerializedName("is_new_user") val isNewUser: Boolean? = null
)

data class UserResponse(
    @SerializedName("user") val user: User
)

data class UserProfile(
    @SerializedName("id") val id: Int,
    @SerializedName("name") val name: String,
    @SerializedName("avatar") val avatar: String?,
    @SerializedName("member_since") val memberSince: String?,
    @SerializedName("stats") val stats: UserStats,
    @SerializedName("submitted_stores") val submittedStores: List<Store>,
    @SerializedName("reviews") val reviews: List<Review>
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

data class UserStats(
    @SerializedName("stores_count") val storesCount: Int,
    @SerializedName("reviews_count") val reviewsCount: Int
)

data class UserProfileResponse(
    @SerializedName("data") val data: UserProfile
)
