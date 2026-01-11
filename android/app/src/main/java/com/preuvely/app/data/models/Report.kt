package com.preuvely.app.data.models

import com.google.gson.annotations.SerializedName
import java.text.SimpleDateFormat
import java.util.*

enum class ReportableType(val value: String) {
    @SerializedName("store") STORE("store"),
    @SerializedName("review") REVIEW("review"),
    @SerializedName("reply") REPLY("reply")
}

enum class ReportReason(val value: String) {
    @SerializedName("spam") SPAM("spam"),
    @SerializedName("abuse") ABUSE("abuse"),
    @SerializedName("fake") FAKE("fake"),
    @SerializedName("inappropriate") INAPPROPRIATE("inappropriate"),
    @SerializedName("other") OTHER("other");

    val displayName: String
        get() = when (this) {
            SPAM -> "Spam"
            ABUSE -> "Abusive Content"
            FAKE -> "Fake Store/Review"
            INAPPROPRIATE -> "Inappropriate Content"
            OTHER -> "Other Issue"
        }

    val description: String
        get() = when (this) {
            SPAM -> "This content is promotional or spam"
            ABUSE -> "Contains harassment or hate speech"
            FAKE -> "Fake or misleading information"
            INAPPROPRIATE -> "Contains adult or offensive content"
            OTHER -> "Other issue not listed above"
        }

    val iconName: String
        get() = when (this) {
            SPAM -> "exclamationmark_triangle"
            ABUSE -> "hand_raised"
            FAKE -> "doc_badge_ellipsis"
            INAPPROPRIATE -> "eye_slash"
            OTHER -> "questionmark_circle"
        }
}

enum class ReportStatus(val value: String) {
    @SerializedName("open") OPEN("open"),
    @SerializedName("under_review") UNDER_REVIEW("under_review"),
    @SerializedName("resolved") RESOLVED("resolved"),
    @SerializedName("dismissed") DISMISSED("dismissed")
}

data class Report(
    @SerializedName("id") val id: Int,
    @SerializedName("reportable_type") val reportableType: String,
    @SerializedName("reportable_id") val reportableId: Int,
    @SerializedName("reportable_name") val reportableName: String?,
    @SerializedName("reason") val reason: ReportReason,
    @SerializedName("note") val note: String?,
    @SerializedName("status") val status: ReportStatus,
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

    val displayableType: String
        get() = when (reportableType) {
            "store" -> "Store"
            "review" -> "Review"
            "reply" -> "Reply"
            else -> reportableType.replaceFirstChar { it.uppercase() }
        }

    val displayReportableName: String
        get() = reportableName ?: "Unknown"
}

data class ReportListResponse(
    @SerializedName("data") val data: List<Report>
)

data class ReportResponse(
    @SerializedName("message") val message: String,
    @SerializedName("data") val data: Report
)
