package com.preuvely.app.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.preuvely.app.data.models.Platform
import com.preuvely.app.data.models.ReviewStatus
import com.preuvely.app.ui.theme.*

enum class BadgeSize {
    SMALL, MEDIUM, LARGE
}

@Composable
fun VerifiedBadge(
    size: BadgeSize = BadgeSize.MEDIUM,
    modifier: Modifier = Modifier
) {
    val iconSize = when (size) {
        BadgeSize.SMALL -> 12.dp
        BadgeSize.MEDIUM -> 16.dp
        BadgeSize.LARGE -> 20.dp
    }

    Icon(
        imageVector = Icons.Default.Verified,
        contentDescription = "Verified",
        tint = PrimaryGreen,
        modifier = modifier.size(iconSize)
    )
}

@Composable
fun ProofBadge(
    size: BadgeSize = BadgeSize.MEDIUM,
    modifier: Modifier = Modifier
) {
    val iconSize = when (size) {
        BadgeSize.SMALL -> 10.dp
        BadgeSize.MEDIUM -> 14.dp
        BadgeSize.LARGE -> 18.dp
    }

    Row(
        modifier = modifier
            .clip(RoundedCornerShape(Spacing.radiusSmall))
            .background(PrimaryGreen.copy(alpha = 0.1f))
            .padding(horizontal = Spacing.xs, vertical = 2.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = Icons.Default.VerifiedUser,
            contentDescription = "Proof",
            tint = PrimaryGreen,
            modifier = Modifier.size(iconSize)
        )
        Spacer(modifier = Modifier.width(2.dp))
        Text(
            text = "Proof",
            style = PreuvelyTypography.caption2.copy(fontWeight = FontWeight.Medium),
            color = PrimaryGreen
        )
    }
}

@Composable
fun StatusBadge(
    status: ReviewStatus,
    modifier: Modifier = Modifier
) {
    val (backgroundColor, textColor, text) = when (status) {
        ReviewStatus.PENDING -> Triple(WarningOrange.copy(alpha = 0.1f), WarningOrange, "Pending")
        ReviewStatus.APPROVED -> Triple(SuccessGreen.copy(alpha = 0.1f), SuccessGreen, "Approved")
        ReviewStatus.REJECTED -> Triple(ErrorRed.copy(alpha = 0.1f), ErrorRed, "Rejected")
    }

    Box(
        modifier = modifier
            .clip(RoundedCornerShape(Spacing.radiusSmall))
            .background(backgroundColor)
            .padding(horizontal = Spacing.sm, vertical = Spacing.xxs)
    ) {
        Text(
            text = text,
            style = PreuvelyTypography.caption1.copy(fontWeight = FontWeight.Medium),
            color = textColor
        )
    }
}

@Composable
fun RatingBadge(
    rating: Double,
    size: BadgeSize = BadgeSize.MEDIUM,
    modifier: Modifier = Modifier
) {
    val starSize = when (size) {
        BadgeSize.SMALL -> Spacing.starSmall
        BadgeSize.MEDIUM -> Spacing.starMedium
        BadgeSize.LARGE -> Spacing.starLarge
    }

    Row(
        modifier = modifier
            .clip(RoundedCornerShape(Spacing.radiusSmall))
            .background(StarYellow.copy(alpha = 0.15f))
            .padding(horizontal = Spacing.sm, vertical = Spacing.xxs),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = Icons.Default.Star,
            contentDescription = null,
            tint = StarYellow,
            modifier = Modifier.size(starSize)
        )
        Spacer(modifier = Modifier.width(2.dp))
        Text(
            text = String.format("%.1f", rating),
            style = PreuvelyTypography.caption1.copy(fontWeight = FontWeight.SemiBold),
            color = TextPrimary
        )
    }
}

@Composable
fun PlatformBadge(
    platform: Platform,
    size: BadgeSize = BadgeSize.MEDIUM,
    modifier: Modifier = Modifier
) {
    val badgeSize = when (size) {
        BadgeSize.SMALL -> Spacing.platformBadgeSmall
        BadgeSize.MEDIUM -> Spacing.platformBadgeMedium
        BadgeSize.LARGE -> Spacing.platformBadgeLarge
    }

    val iconSize = badgeSize * 0.6f

    val (backgroundColor, icon) = when (platform) {
        Platform.INSTAGRAM -> Pair(InstagramPink.copy(alpha = 0.15f), Icons.Default.CameraAlt)
        Platform.FACEBOOK -> Pair(FacebookBlue.copy(alpha = 0.15f), Icons.Default.Facebook)
        Platform.TIKTOK -> Pair(TikTokBlack.copy(alpha = 0.15f), Icons.Default.MusicNote)
        Platform.WEBSITE -> Pair(PrimaryGreen.copy(alpha = 0.15f), Icons.Default.Language)
        Platform.WHATSAPP -> Pair(WhatsAppGreen.copy(alpha = 0.15f), Icons.Default.Chat)
    }

    val iconColor = when (platform) {
        Platform.INSTAGRAM -> InstagramPink
        Platform.FACEBOOK -> FacebookBlue
        Platform.TIKTOK -> TikTokBlack
        Platform.WEBSITE -> PrimaryGreen
        Platform.WHATSAPP -> WhatsAppGreen
    }

    Box(
        modifier = modifier
            .size(badgeSize)
            .clip(RoundedCornerShape(Spacing.radiusSmall))
            .background(backgroundColor),
        contentAlignment = Alignment.Center
    ) {
        Icon(
            imageVector = icon,
            contentDescription = platform.displayName,
            tint = iconColor,
            modifier = Modifier.size(iconSize)
        )
    }
}

@Composable
fun PlatformIconCircle(
    platform: Platform,
    size: Dp = 60.dp,
    modifier: Modifier = Modifier
) {
    val gradient = when (platform) {
        Platform.INSTAGRAM -> Brush.linearGradient(listOf(Color(0xFFF58529), Color(0xFFDD2A7B), Color(0xFF8134AF)))
        Platform.FACEBOOK -> Brush.linearGradient(listOf(FacebookBlue, Color(0xFF4267B2)))
        Platform.TIKTOK -> Brush.linearGradient(listOf(TikTokBlack, Color(0xFF25F4EE)))
        Platform.WEBSITE -> Brush.linearGradient(listOf(PrimaryGreen, PrimaryGreenLight))
        Platform.WHATSAPP -> Brush.linearGradient(listOf(WhatsAppGreen, Color(0xFF25D366)))
    }

    val icon = when (platform) {
        Platform.INSTAGRAM -> Icons.Default.CameraAlt
        Platform.FACEBOOK -> Icons.Default.Facebook
        Platform.TIKTOK -> Icons.Default.MusicNote
        Platform.WEBSITE -> Icons.Default.Language
        Platform.WHATSAPP -> Icons.Default.Chat
    }

    Box(
        modifier = modifier
            .size(size)
            .clip(CircleShape)
            .background(gradient),
        contentAlignment = Alignment.Center
    ) {
        Icon(
            imageVector = icon,
            contentDescription = platform.displayName,
            tint = White,
            modifier = Modifier.size(size * 0.5f)
        )
    }
}

@Composable
fun NotificationDot(
    modifier: Modifier = Modifier,
    size: Dp = 10.dp
) {
    Box(
        modifier = modifier
            .size(size)
            .clip(CircleShape)
            .background(ErrorRed)
    )
}

@Composable
fun CountBadge(
    count: Int,
    modifier: Modifier = Modifier
) {
    if (count > 0) {
        Box(
            modifier = modifier
                .clip(RoundedCornerShape(Spacing.radiusSmall))
                .background(PrimaryGreen)
                .padding(horizontal = Spacing.sm, vertical = Spacing.xxs),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = if (count > 99) "99+" else count.toString(),
                style = PreuvelyTypography.caption2.copy(fontWeight = FontWeight.SemiBold),
                color = White
            )
        }
    }
}
