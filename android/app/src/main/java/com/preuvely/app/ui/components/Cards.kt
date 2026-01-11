package com.preuvely.app.ui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.preuvely.app.data.models.*
import com.preuvely.app.ui.theme.*

@Composable
fun StoreCard(
    store: Store,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale by animateFloatAsState(if (isPressed) 0.98f else 1f, label = "scale")

    Card(
        modifier = modifier
            .scale(scale)
            .fillMaxWidth()
            .shadow(
                elevation = 4.dp,
                shape = RoundedCornerShape(Spacing.radiusMedium),
                ambientColor = CardShadow,
                spotColor = CardShadow
            )
            .clickable(
                interactionSource = interactionSource,
                indication = null,
                onClick = onClick
            ),
        shape = RoundedCornerShape(Spacing.radiusMedium),
        colors = CardDefaults.cardColors(containerColor = CardBackground)
    ) {
        Row(
            modifier = Modifier.padding(Spacing.cardPadding),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Logo
            StoreLogoImage(
                logoUrl = store.logo,
                storeName = store.name,
                size = Spacing.logoMedium
            )

            Spacer(modifier = Modifier.width(Spacing.md))

            // Info
            Column(modifier = Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = store.name,
                        style = PreuvelyTypography.subheadlineBold,
                        color = TextPrimary,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.weight(1f, fill = false)
                    )
                    if (store.isVerified) {
                        Spacer(modifier = Modifier.width(Spacing.xs))
                        VerifiedBadge(size = BadgeSize.SMALL)
                    }
                }

                Spacer(modifier = Modifier.height(Spacing.xs))

                Row(verticalAlignment = Alignment.CenterVertically) {
                    RatingBadge(rating = store.avgRating, size = BadgeSize.SMALL)
                    Spacer(modifier = Modifier.width(Spacing.sm))
                    Text(
                        text = "${store.formattedReviewsCount} reviews",
                        style = PreuvelyTypography.caption1,
                        color = TextSecondary
                    )
                }

                if (!store.city.isNullOrBlank()) {
                    Spacer(modifier = Modifier.height(Spacing.xs))
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.LocationOn,
                            contentDescription = null,
                            tint = TextSecondary,
                            modifier = Modifier.size(12.dp)
                        )
                        Spacer(modifier = Modifier.width(2.dp))
                        Text(
                            text = store.city,
                            style = PreuvelyTypography.caption1,
                            color = TextSecondary
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun CompactStoreCard(
    store: Store,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale by animateFloatAsState(if (isPressed) 0.95f else 1f, label = "scale")

    Card(
        modifier = modifier
            .scale(scale)
            .width(160.dp)
            .shadow(
                elevation = 4.dp,
                shape = RoundedCornerShape(18.dp),
                ambientColor = CardShadow,
                spotColor = CardShadow
            )
            .clickable(
                interactionSource = interactionSource,
                indication = null,
                onClick = onClick
            ),
        shape = RoundedCornerShape(18.dp),
        colors = CardDefaults.cardColors(containerColor = CardBackground)
    ) {
        Column {
            // Image section
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(100.dp)
                    .background(Gray6),
                contentAlignment = Alignment.Center
            ) {
                if (!store.logo.isNullOrBlank()) {
                    AsyncImage(
                        model = store.logo,
                        contentDescription = store.name,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier.fillMaxSize()
                    )
                } else {
                    // Placeholder
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .background(
                                Brush.linearGradient(
                                    listOf(
                                        PrimaryGreen.copy(alpha = 0.15f),
                                        PrimaryGreen.copy(alpha = 0.05f)
                                    )
                                )
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = store.nameInitial,
                            style = PreuvelyTypography.title1,
                            color = PrimaryGreen
                        )
                    }
                }
            }

            // Info section
            Column(modifier = Modifier.padding(Spacing.md)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = store.name,
                        style = PreuvelyTypography.footnote.copy(fontWeight = FontWeight.SemiBold),
                        color = TextPrimary,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.weight(1f, fill = false)
                    )
                    if (store.isVerified) {
                        Spacer(modifier = Modifier.width(2.dp))
                        VerifiedBadge(size = BadgeSize.SMALL)
                    }
                }

                Spacer(modifier = Modifier.height(Spacing.xs))

                Row(verticalAlignment = Alignment.CenterVertically) {
                    RatingBadge(rating = store.avgRating, size = BadgeSize.SMALL)
                    Spacer(modifier = Modifier.width(Spacing.xs))
                    Text(
                        text = "${store.reviewsCount}",
                        style = PreuvelyTypography.caption2,
                        color = TextSecondary
                    )
                }
            }
        }
    }
}

@Composable
fun StoreLogoImage(
    logoUrl: String?,
    storeName: String,
    size: androidx.compose.ui.unit.Dp,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .size(size)
            .clip(RoundedCornerShape(Spacing.radiusMedium))
            .background(
                Brush.linearGradient(
                    listOf(
                        PrimaryGreen.copy(alpha = 0.15f),
                        PrimaryGreen.copy(alpha = 0.05f)
                    )
                )
            ),
        contentAlignment = Alignment.Center
    ) {
        if (!logoUrl.isNullOrBlank()) {
            AsyncImage(
                model = logoUrl,
                contentDescription = storeName,
                contentScale = ContentScale.Crop,
                modifier = Modifier
                    .fillMaxSize()
                    .clip(RoundedCornerShape(Spacing.radiusMedium))
            )
        } else {
            Text(
                text = storeName.firstOrNull()?.uppercase() ?: "?",
                style = PreuvelyTypography.title2,
                color = PrimaryGreen
            )
        }
    }
}

@Composable
fun ReviewCard(
    review: Review,
    modifier: Modifier = Modifier,
    onUserClick: (() -> Unit)? = null
) {
    Card(
        modifier = modifier
            .fillMaxWidth()
            .shadow(
                elevation = 4.dp,
                shape = RoundedCornerShape(16.dp),
                ambientColor = CardShadow.copy(alpha = 0.1f),
                spotColor = CardShadow.copy(alpha = 0.1f)
            ),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = White)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            // Header
            Row(verticalAlignment = Alignment.CenterVertically) {
                // Avatar with border
                Box(
                    modifier = Modifier
                        .size(48.dp)
                        .clip(CircleShape)
                        .border(2.dp, PrimaryGreen.copy(alpha = 0.2f), CircleShape)
                        .padding(2.dp)
                        .clip(CircleShape)
                        .background(
                            Brush.linearGradient(
                                listOf(PrimaryGreen.copy(alpha = 0.15f), PrimaryGreen.copy(alpha = 0.05f))
                            )
                        )
                        .then(
                            if (onUserClick != null) {
                                Modifier.clickable(onClick = onUserClick)
                            } else Modifier
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    if (!review.userAvatar.isNullOrBlank()) {
                        AsyncImage(
                            model = review.userAvatar,
                            contentDescription = review.userName,
                            contentScale = ContentScale.Crop,
                            modifier = Modifier.fillMaxSize()
                        )
                    } else {
                        Text(
                            text = review.user.initials,
                            style = PreuvelyTypography.subheadlineBold,
                            color = PrimaryGreen
                        )
                    }
                }

                Spacer(modifier = Modifier.width(12.dp))

                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = review.userName,
                        style = PreuvelyTypography.subheadlineBold,
                        color = TextPrimary
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = review.relativeDate,
                        style = PreuvelyTypography.caption1,
                        color = TextSecondary
                    )
                }

                // Rating badge
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(12.dp))
                        .background(StarYellow.copy(alpha = 0.15f))
                        .padding(horizontal = 10.dp, vertical = 6.dp)
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.Star,
                            contentDescription = null,
                            tint = StarYellow,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = "${review.stars}",
                            style = PreuvelyTypography.subheadlineBold,
                            color = StarYellow.copy(alpha = 0.9f)
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Comment with quote style
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(Gray5.copy(alpha = 0.5f))
                    .padding(12.dp)
            ) {
                Text(
                    text = review.comment,
                    style = PreuvelyTypography.body,
                    color = TextPrimary,
                    lineHeight = 22.sp
                )
            }

            // Status badge if not approved
            if (review.status != ReviewStatus.APPROVED) {
                Spacer(modifier = Modifier.height(Spacing.sm))
                StatusBadge(status = review.status)
            }

            // Proof badge if has verified proof
            if (review.hasVerifiedProof) {
                Spacer(modifier = Modifier.height(Spacing.sm))
                ProofBadge()
            }

            // Reply
            review.reply?.let { reply ->
                Spacer(modifier = Modifier.height(Spacing.md))
                Divider(color = com.preuvely.app.ui.theme.Divider)
                Spacer(modifier = Modifier.height(Spacing.md))

                Row(verticalAlignment = Alignment.Top) {
                    Icon(
                        imageVector = Icons.Default.Reply,
                        contentDescription = null,
                        tint = PrimaryGreen,
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(Spacing.sm))
                    Column {
                        Text(
                            text = reply.userName,
                            style = PreuvelyTypography.caption1.copy(fontWeight = FontWeight.SemiBold),
                            color = PrimaryGreen
                        )
                        Spacer(modifier = Modifier.height(Spacing.xxs))
                        Text(
                            text = reply.replyText,
                            style = PreuvelyTypography.subheadline,
                            color = TextSecondary
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun StarRating(
    rating: Int,
    size: BadgeSize = BadgeSize.MEDIUM,
    modifier: Modifier = Modifier
) {
    val starSize = when (size) {
        BadgeSize.SMALL -> Spacing.starSmall
        BadgeSize.MEDIUM -> Spacing.starMedium
        BadgeSize.LARGE -> Spacing.starLarge
    }

    Row(modifier = modifier) {
        repeat(5) { index ->
            Icon(
                imageVector = if (index < rating) Icons.Default.Star else Icons.Default.StarBorder,
                contentDescription = null,
                tint = if (index < rating) StarYellow else Gray4,
                modifier = Modifier.size(starSize)
            )
        }
    }
}

@Composable
fun CategoryCard(
    category: Category,
    selected: Boolean = false,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale by animateFloatAsState(if (isPressed) 0.95f else 1f, label = "scale")

    Column(
        modifier = modifier
            .scale(scale)
            .clickable(
                interactionSource = interactionSource,
                indication = null,
                onClick = onClick
            ),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Icon circle
        Box(
            modifier = Modifier
                .size(64.dp)
                .clip(CircleShape)
                .background(
                    if (selected) PrimaryGreen.copy(alpha = 0.15f) else Gray6
                )
                .then(
                    if (selected) Modifier
                        .background(
                            color = Color.Transparent,
                            shape = CircleShape
                        ) else Modifier
                ),
            contentAlignment = Alignment.Center
        ) {
            // Use a generic icon for now
            Icon(
                imageVector = Icons.Default.Category,
                contentDescription = null,
                tint = if (selected) PrimaryGreen else TextSecondary,
                modifier = Modifier.size(32.dp)
            )
        }

        Spacer(modifier = Modifier.height(Spacing.sm))

        Text(
            text = category.name,
            style = PreuvelyTypography.caption2.copy(fontWeight = FontWeight.Medium),
            color = TextPrimary,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )

        category.storesCount?.let { count ->
            Text(
                text = "$count stores",
                style = PreuvelyTypography.caption2,
                color = TextSecondary
            )
        }
    }
}
