package com.preuvely.app.ui.components

import androidx.compose.foundation.Image
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
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.preuvely.app.R
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

    val iconSize = badgeSize * 0.8f

    val iconRes = when (platform) {
        Platform.INSTAGRAM -> R.drawable.ic_instagram_color
        Platform.FACEBOOK -> R.drawable.ic_facebook_color
        Platform.TIKTOK -> R.drawable.ic_tiktok_color
        Platform.WEBSITE -> null // Use material icon for website
        Platform.WHATSAPP -> R.drawable.ic_whatsapp_color
    }

    Box(
        modifier = modifier
            .size(badgeSize)
            .clip(RoundedCornerShape(Spacing.radiusSmall)),
        contentAlignment = Alignment.Center
    ) {
        if (iconRes != null) {
            Image(
                painter = painterResource(id = iconRes),
                contentDescription = platform.displayName,
                modifier = Modifier.size(iconSize),
                contentScale = ContentScale.Fit
            )
        } else {
            Icon(
                imageVector = Icons.Default.Language,
                contentDescription = platform.displayName,
                tint = PrimaryGreen,
                modifier = Modifier.size(iconSize)
            )
        }
    }
}

@Composable
fun PlatformIconCircle(
    platform: Platform,
    size: Dp = 60.dp,
    modifier: Modifier = Modifier
) {
    val iconRes = when (platform) {
        Platform.INSTAGRAM -> R.drawable.ic_instagram_color
        Platform.FACEBOOK -> R.drawable.ic_facebook_color
        Platform.TIKTOK -> R.drawable.ic_tiktok_color
        Platform.WEBSITE -> null
        Platform.WHATSAPP -> R.drawable.ic_whatsapp_color
    }

    Box(
        modifier = modifier
            .size(size)
            .clip(CircleShape),
        contentAlignment = Alignment.Center
    ) {
        if (iconRes != null) {
            Image(
                painter = painterResource(id = iconRes),
                contentDescription = platform.displayName,
                modifier = Modifier.size(size * 0.85f),
                contentScale = ContentScale.Fit
            )
        } else {
            // Website fallback with gradient background
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Brush.linearGradient(listOf(PrimaryGreen, PrimaryGreenLight))),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Language,
                    contentDescription = platform.displayName,
                    tint = White,
                    modifier = Modifier.size(size * 0.5f)
                )
            }
        }
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
