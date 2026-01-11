package com.preuvely.app.data.models

import com.google.gson.annotations.SerializedName
import java.text.SimpleDateFormat
import java.util.*

enum class NotificationType(val value: String) {
    @SerializedName("review_received") REVIEW_RECEIVED("review_received"),
    @SerializedName("review_approved") REVIEW_APPROVED("review_approved"),
    @SerializedName("review_rejected") REVIEW_REJECTED("review_rejected"),
    @SerializedName("claim_approved") CLAIM_APPROVED("claim_approved"),
    @SerializedName("claim_rejected") CLAIM_REJECTED("claim_rejected"),
    @SerializedName("new_reply") NEW_REPLY("new_reply"),
    @SerializedName("store_verified") STORE_VERIFIED("store_verified");

    val iconName: String
        get() = when (this) {
            REVIEW_RECEIVED -> "star"
            REVIEW_APPROVED -> "checkmark_circle"
            REVIEW_REJECTED -> "xmark_circle"
            CLAIM_APPROVED -> "checkmark_seal"
            CLAIM_REJECTED -> "xmark_seal"
            NEW_REPLY -> "bubble_left"
            STORE_VERIFIED -> "shield_check"
        }
}

data class AppNotification(
    @SerializedName("id") val id: Int,
    @SerializedName("type") val type: NotificationType,
    @SerializedName("title") val title: String,
    @SerializedName("message") val message: String,
    @SerializedName("is_read") var isRead: Boolean,
    @SerializedName("created_at") val createdAt: String,
    @SerializedName("related_id") val relatedId: Int?,
    @SerializedName("user_name") val userName: String?
) {
    val formattedDate: String
        get() {
            return try {
                val inputFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
                val date = inputFormat.parse(createdAt) ?: return ""
                val now = Date()
                val diffMs = now.time - date.time
                val diffMinutes = diffMs / (1000 * 60)
                val diffHours = diffMs / (1000 * 60 * 60)
                val diffDays = diffMs / (1000 * 60 * 60 * 24)

                when {
                    diffMinutes < 1 -> "Just now"
                    diffMinutes < 60 -> "${diffMinutes}m ago"
                    diffHours < 24 -> "${diffHours}h ago"
                    diffDays == 1L -> "Yesterday"
                    diffDays < 7 -> "${diffDays}d ago"
                    else -> {
                        val outputFormat = SimpleDateFormat("MMM d", Locale.getDefault())
                        outputFormat.format(date)
                    }
                }
            } catch (e: Exception) {
                ""
            }
        }

    val fullFormattedDate: String
        get() {
            return try {
                val inputFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
                val outputFormat = SimpleDateFormat("MMMM d, yyyy 'at' h:mm a", Locale.getDefault())
                val date = inputFormat.parse(createdAt)
                date?.let { outputFormat.format(it) } ?: ""
            } catch (e: Exception) {
                ""
            }
        }

    val dateGroup: String
        get() {
            return try {
                val inputFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
                val date = inputFormat.parse(createdAt) ?: return "Older"
                val now = Calendar.getInstance()
                val notifDate = Calendar.getInstance().apply { time = date }

                val todayStart = Calendar.getInstance().apply {
                    set(Calendar.HOUR_OF_DAY, 0)
                    set(Calendar.MINUTE, 0)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                }

                val yesterdayStart = Calendar.getInstance().apply {
                    add(Calendar.DAY_OF_YEAR, -1)
                    set(Calendar.HOUR_OF_DAY, 0)
                    set(Calendar.MINUTE, 0)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                }

                val weekStart = Calendar.getInstance().apply {
                    add(Calendar.DAY_OF_YEAR, -7)
                    set(Calendar.HOUR_OF_DAY, 0)
                    set(Calendar.MINUTE, 0)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                }

                when {
                    date.after(todayStart.time) -> "Today"
                    date.after(yesterdayStart.time) -> "Yesterday"
                    date.after(weekStart.time) -> "This Week"
                    else -> "Older"
                }
            } catch (e: Exception) {
                "Older"
            }
        }
}

data class NotificationListResponse(
    @SerializedName("data") val data: List<AppNotification>,
    @SerializedName("meta") val meta: PaginationMeta?
)

data class UnreadCountResponse(
    @SerializedName("unread_count") val unreadCount: Int
)

data class MarkReadResponse(
    @SerializedName("message") val message: String
)

data class MarkAllReadResponse(
    @SerializedName("message") val message: String,
    @SerializedName("count") val count: Int
)
