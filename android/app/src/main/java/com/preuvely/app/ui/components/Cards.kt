package com.preuvely.app.ui.components

import android.graphics.BitmapFactory
import android.util.Base64
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.Image
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
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import coil.compose.AsyncImagePainter
import coil.compose.SubcomposeAsyncImage
import coil.compose.SubcomposeAsyncImageContent
import com.preuvely.app.data.models.*
import com.preuvely.app.ui.theme.*

// Card shadow configuration matches iOS exactly:
// - shadowRadius: 8dp
// - shadowOpacity: 8%
// - shadowOffset: (0, 2)

/**
 * CachedAvatarImage - A reusable avatar component that handles:
 * - Base64 data URLs (data:image/...)
 * - HTTP/HTTPS URLs
 * - Loading and error states with fallback to initials
 */
@Composable
fun CachedAvatarImage(
    urlString: String?,
    fallbackInitials: String,
    size: androidx.compose.ui.unit.Dp,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .size(size)
            .clip(CircleShape)
            .background(
                Brush.linearGradient(
                    listOf(PrimaryGreen.copy(alpha = 0.15f), PrimaryGreen.copy(alpha = 0.05f))
                )
            ),
        contentAlignment = Alignment.Center
    ) {
        when {
            urlString.isNullOrBlank() -> {
                // No URL - show initials
                Text(
                    text = fallbackInitials,
                    style = PreuvelyTypography.subheadlineBold,
                    color = PrimaryGreen
                )
            }
            urlString.startsWith("data:image") -> {
                // Base64 data URL
                val base64Data = urlString.substringAfter("base64,")
                val bitmap = remember(base64Data) {
                    try {
                        val decodedBytes = Base64.decode(base64Data, Base64.DEFAULT)
                        BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.size)
                    } catch (e: Exception) {
                        null
                    }
                }
                if (bitmap != null) {
                    Image(
                        bitmap = bitmap.asImageBitmap(),
                        contentDescription = null,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier
                            .fillMaxSize()
                            .clip(CircleShape)
                    )
                } else {
                    Text(
                        text = fallbackInitials,
                        style = PreuvelyTypography.subheadlineBold,
                        color = PrimaryGreen
                    )
                }
            }
            else -> {
                // HTTP/HTTPS URL - use SubcomposeAsyncImage for proper state handling
                SubcomposeAsyncImage(
                    model = urlString,
                    contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier
                        .fillMaxSize()
                        .clip(CircleShape)
                ) {
                    when (painter.state) {
                        is AsyncImagePainter.State.Loading -> {
                            Box(
                                modifier = Modifier.fillMaxSize(),
                                contentAlignment = Alignment.Center
                            ) {
                                CircularProgressIndicator(
                                    modifier = Modifier.size(size / 3),
                                    color = PrimaryGreen,
                                    strokeWidth = 2.dp
                                )
                            }
                        }
                        is AsyncImagePainter.State.Error -> {
                            // Show initials on error
                            Text(
                                text = fallbackInitials,
                                style = PreuvelyTypography.subheadlineBold,
                                color = PrimaryGreen
                            )
                        }
                        else -> {
                            SubcomposeAsyncImageContent()
                        }
                    }
                }
            }
        }
    }
}

/**
 * CachedLogoImage - A reusable logo component that handles:
 * - Base64 data URLs (data:image/...)
 * - HTTP/HTTPS URLs
 * - Loading and error states with fallback to initials
 */
@Composable
fun CachedLogoImage(
    urlString: String?,
    fallbackInitials: String,
    modifier: Modifier = Modifier,
    cornerRadius: androidx.compose.ui.unit.Dp = 21.dp
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(cornerRadius))
            .background(
                Brush.linearGradient(
                    listOf(PrimaryGreen.copy(alpha = 0.1f), PrimaryGreen.copy(alpha = 0.05f))
                )
            ),
        contentAlignment = Alignment.Center
    ) {
        when {
            urlString.isNullOrBlank() -> {
                // No URL - show initials
                Text(
                    text = fallbackInitials,
                    style = PreuvelyTypography.largeTitle.copy(fontSize = 36.sp),
                    color = PrimaryGreen
                )
            }
            urlString.startsWith("data:image") -> {
                // Base64 data URL
                val base64Data = urlString.substringAfter("base64,")
                val bitmap = remember(base64Data) {
                    try {
                        val decodedBytes = Base64.decode(base64Data, Base64.DEFAULT)
                        BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.size)
                    } catch (e: Exception) {
                        null
                    }
                }
                if (bitmap != null) {
                    Image(
                        bitmap = bitmap.asImageBitmap(),
                        contentDescription = null,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier
                            .fillMaxSize()
                            .clip(RoundedCornerShape(cornerRadius))
                    )
                } else {
                    Text(
                        text = fallbackInitials,
                        style = PreuvelyTypography.largeTitle.copy(fontSize = 36.sp),
                        color = PrimaryGreen
                    )
                }
            }
            else -> {
                // HTTP/HTTPS URL - use SubcomposeAsyncImage
                SubcomposeAsyncImage(
                    model = urlString,
                    contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier
                        .fillMaxSize()
                        .clip(RoundedCornerShape(cornerRadius))
                ) {
                    when (painter.state) {
                        is AsyncImagePainter.State.Loading -> {
                            Box(
                                modifier = Modifier.fillMaxSize(),
                                contentAlignment = Alignment.Center
                            ) {
                                CircularProgressIndicator(
                                    modifier = Modifier.size(32.dp),
                                    color = PrimaryGreen,
                                    strokeWidth = 2.dp
                                )
                            }
                        }
                        is AsyncImagePainter.State.Error -> {
                            Text(
                                text = fallbackInitials,
                                style = PreuvelyTypography.largeTitle.copy(fontSize = 36.sp),
                                color = PrimaryGreen
                            )
                        }
                        else -> {
                            SubcomposeAsyncImageContent()
                        }
                    }
                }
            }
        }
    }
}

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
            CachedLogoImage(
                urlString = store.logo,
                fallbackInitials = store.nameInitial,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(100.dp),
                cornerRadius = 0.dp
            )

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

/**
 * GridStoreCard - Vertical card for grid layouts (like homepage)
 * Image on top with rounded corners, info below
 */
@Composable
fun GridStoreCard(
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
            .fillMaxWidth()
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
            // Image section with rounded top corners
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(120.dp)
                    .clip(RoundedCornerShape(topStart = 18.dp, topEnd = 18.dp))
                    .background(Gray6),
                contentAlignment = Alignment.Center
            ) {
                if (!store.logo.isNullOrBlank()) {
                    // Handle base64 data URL or regular URL
                    if (store.logo!!.startsWith("data:image")) {
                        val base64Data = store.logo!!.substringAfter("base64,")
                        val bitmap = remember(base64Data) {
                            try {
                                val decodedBytes = Base64.decode(base64Data, Base64.DEFAULT)
                                BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.size)
                            } catch (e: Exception) {
                                null
                            }
                        }
                        bitmap?.let {
                            Image(
                                bitmap = it.asImageBitmap(),
                                contentDescription = store.name,
                                contentScale = ContentScale.Crop,
                                modifier = Modifier.fillMaxSize()
                            )
                        }
                    } else {
                        AsyncImage(
                            model = store.logo,
                            contentDescription = store.name,
                            contentScale = ContentScale.Crop,
                            modifier = Modifier.fillMaxSize()
                        )
                    }
                } else {
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
    val initial = storeName.firstOrNull()?.uppercase() ?: "?"

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
        when {
            logoUrl.isNullOrBlank() -> {
                Text(
                    text = initial,
                    style = PreuvelyTypography.title2,
                    color = PrimaryGreen
                )
            }
            logoUrl.startsWith("data:image") -> {
                // Base64 data URL
                val base64Data = logoUrl.substringAfter("base64,")
                val bitmap = remember(base64Data) {
                    try {
                        val decodedBytes = Base64.decode(base64Data, Base64.DEFAULT)
                        BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.size)
                    } catch (e: Exception) {
                        null
                    }
                }
                if (bitmap != null) {
                    Image(
                        bitmap = bitmap.asImageBitmap(),
                        contentDescription = storeName,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier
                            .fillMaxSize()
                            .clip(RoundedCornerShape(Spacing.radiusMedium))
                    )
                } else {
                    Text(
                        text = initial,
                        style = PreuvelyTypography.title2,
                        color = PrimaryGreen
                    )
                }
            }
            else -> {
                // HTTP/HTTPS URL
                SubcomposeAsyncImage(
                    model = logoUrl,
                    contentDescription = storeName,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier
                        .fillMaxSize()
                        .clip(RoundedCornerShape(Spacing.radiusMedium))
                ) {
                    when (painter.state) {
                        is AsyncImagePainter.State.Error -> {
                            Text(
                                text = initial,
                                style = PreuvelyTypography.title2,
                                color = PrimaryGreen
                            )
                        }
                        else -> SubcomposeAsyncImageContent()
                    }
                }
            }
        }
    }
}

@Composable
fun ReviewCard(
    review: Review,
    modifier: Modifier = Modifier,
    onUserClick: (() -> Unit)? = null,
    isOwner: Boolean = false,
    onReplyClick: ((Int) -> Unit)? = null
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
                // Avatar with border - using CachedAvatarImage
                Box(
                    modifier = Modifier
                        .size(48.dp)
                        .clip(CircleShape)
                        .border(2.dp, PrimaryGreen.copy(alpha = 0.2f), CircleShape)
                        .padding(2.dp)
                        .then(
                            if (onUserClick != null) {
                                Modifier.clickable(onClick = onUserClick)
                            } else Modifier
                        )
                ) {
                    CachedAvatarImage(
                        urlString = review.userAvatar,
                        fallbackInitials = review.user.initials,
                        size = 44.dp
                    )
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

            // Reply button for store owners (only show if no reply yet)
            if (isOwner && review.reply == null && onReplyClick != null) {
                Spacer(modifier = Modifier.height(Spacing.md))
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(Spacing.radiusSmall))
                        .background(PrimaryGreen.copy(alpha = 0.1f))
                        .clickable { onReplyClick(review.id) }
                        .padding(horizontal = Spacing.md, vertical = Spacing.sm)
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.Reply,
                            contentDescription = null,
                            tint = PrimaryGreen,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(Spacing.xs))
                        Text(
                            text = "Reply",
                            style = PreuvelyTypography.caption1.copy(fontWeight = FontWeight.SemiBold),
                            color = PrimaryGreen
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
