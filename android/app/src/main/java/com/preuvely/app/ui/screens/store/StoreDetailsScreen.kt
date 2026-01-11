package com.preuvely.app.ui.screens.store

import androidx.compose.animation.animateContentSize
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.res.stringResource
import androidx.compose.foundation.text.KeyboardOptions
import androidx.hilt.navigation.compose.hiltViewModel
import com.preuvely.app.R
import coil.compose.AsyncImage
import coil.compose.SubcomposeAsyncImage
import coil.compose.SubcomposeAsyncImageContent
import com.preuvely.app.data.models.*
import com.preuvely.app.ui.components.*
import com.preuvely.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun StoreDetailsScreen(
    slug: String,
    onNavigateBack: () -> Unit,
    onNavigateToUser: (Int) -> Unit,
    onNavigateToAuth: () -> Unit,
    viewModel: StoreDetailsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val uriHandler = LocalUriHandler.current
    var showWriteReview by remember { mutableStateOf(false) }
    var isEditingReview by remember { mutableStateOf(false) }
    var showClaimStore by remember { mutableStateOf(false) }
    var showReport by remember { mutableStateOf(false) }
    var showMenu by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.Default.ArrowBack, stringResource(R.string.store_back))
                    }
                },
                actions = {
                    Box {
                        IconButton(onClick = { showMenu = true }) {
                            Icon(Icons.Default.MoreVert, stringResource(R.string.store_more_options))
                        }
                        DropdownMenu(
                            expanded = showMenu,
                            onDismissRequest = { showMenu = false }
                        ) {
                            DropdownMenuItem(
                                text = {
                                    Row(verticalAlignment = Alignment.CenterVertically) {
                                        Icon(
                                            Icons.Default.Store,
                                            contentDescription = null,
                                            tint = PrimaryGreen,
                                            modifier = Modifier.size(20.dp)
                                        )
                                        Spacer(modifier = Modifier.width(Spacing.sm))
                                        Text(stringResource(R.string.store_claim))
                                    }
                                },
                                onClick = {
                                    showMenu = false
                                    showClaimStore = true
                                }
                            )
                            DropdownMenuItem(
                                text = {
                                    Row(verticalAlignment = Alignment.CenterVertically) {
                                        Icon(
                                            Icons.Default.Flag,
                                            contentDescription = null,
                                            tint = ErrorRed,
                                            modifier = Modifier.size(20.dp)
                                        )
                                        Spacer(modifier = Modifier.width(Spacing.sm))
                                        Text(stringResource(R.string.store_report))
                                    }
                                },
                                onClick = {
                                    showMenu = false
                                    showReport = true
                                }
                            )
                        }
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = BackgroundPrimary
                )
            )
        }
    ) { padding ->
        if (uiState.isLoading) {
            LoadingView(modifier = Modifier.padding(padding))
        } else if (uiState.error != null) {
            ErrorStateView(
                title = "Error",
                message = uiState.error!!,
                onRetry = { viewModel.loadData() },
                modifier = Modifier.padding(padding)
            )
        } else {
            uiState.store?.let { store ->
                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(padding),
                    contentPadding = PaddingValues(bottom = 100.dp)
                ) {
                    // Header Section
                    item {
                        StoreHeader(
                            store = store,
                            summary = uiState.summary
                        )
                    }

                    // Social Links
                    if (store.links.isNotEmpty()) {
                        item {
                            SocialLinksSection(
                                links = store.links,
                                onLinkClick = { url ->
                                    try {
                                        uriHandler.openUri(url)
                                    } catch (e: Exception) { }
                                }
                            )
                        }
                    }

                    // Contacts
                    store.contacts?.let { contacts ->
                        if (!contacts.whatsapp.isNullOrBlank() || !contacts.phone.isNullOrBlank()) {
                            item {
                                ContactsSection(
                                    contacts = contacts,
                                    onWhatsAppClick = { phone ->
                                        try {
                                            uriHandler.openUri("https://wa.me/$phone")
                                        } catch (e: Exception) { }
                                    },
                                    onPhoneClick = { phone ->
                                        try {
                                            uriHandler.openUri("tel:$phone")
                                        } catch (e: Exception) { }
                                    }
                                )
                            }
                        }
                    }

                    // Rating Breakdown
                    uiState.summary?.let { summary ->
                        item {
                            RatingBreakdownSection(summary = summary)
                        }
                    }

                    // Write Review Button
                    item {
                        WriteReviewSection(
                            hasReviewed = uiState.userReview != null,
                            onWriteReview = {
                                isEditingReview = false
                                showWriteReview = true
                            },
                            onEditReview = {
                                isEditingReview = true
                                showWriteReview = true
                            }
                        )
                    }

                    // Reviews Header
                    item {
                        SectionHeader(
                            title = stringResource(R.string.store_reviews),
                            modifier = Modifier.padding(top = Spacing.xl)
                        )
                        Spacer(modifier = Modifier.height(Spacing.md))
                    }

                    // Reviews
                    if (uiState.reviews.isEmpty() && !uiState.isLoadingReviews) {
                        item {
                            EmptyStateView(
                                icon = Icons.Default.RateReview,
                                title = stringResource(R.string.store_no_reviews),
                                message = stringResource(R.string.store_be_first),
                                modifier = Modifier.padding(Spacing.xl)
                            )
                        }
                    } else {
                        items(uiState.reviews) { review ->
                            ReviewCard(
                                review = review,
                                onUserClick = { onNavigateToUser(review.userId) },
                                modifier = Modifier.padding(
                                    horizontal = Spacing.screenPadding,
                                    vertical = Spacing.xs
                                )
                            )
                        }

                        // Load More
                        if (uiState.isLoadingMore) {
                            item {
                                Box(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(Spacing.lg),
                                    contentAlignment = Alignment.Center
                                ) {
                                    CircularProgressIndicator(
                                        color = PrimaryGreen,
                                        modifier = Modifier.size(24.dp)
                                    )
                                }
                            }
                        } else if (uiState.hasMoreReviews) {
                            item {
                                Box(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(Spacing.md)
                                        .clip(RoundedCornerShape(Spacing.radiusMedium))
                                        .background(PrimaryGreen.copy(alpha = 0.1f))
                                        .clickable { viewModel.loadMoreReviews() }
                                        .padding(Spacing.md),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text(
                                        text = stringResource(R.string.store_load_more),
                                        style = PreuvelyTypography.subheadlineBold,
                                        color = PrimaryGreen
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Write Review Sheet
    var reviewSuccess by remember { mutableStateOf(false) }
    var reviewError by remember { mutableStateOf<String?>(null) }
    var reviewNeedsAuth by remember { mutableStateOf(false) }

    if (showWriteReview) {
        WriteReviewSheet(
            store = uiState.store!!,
            isSubmitting = uiState.isSubmittingReview,
            showSuccess = reviewSuccess,
            errorMessage = reviewError,
            needsAuth = reviewNeedsAuth,
            isEditing = isEditingReview,
            existingStars = uiState.userReview?.stars ?: 0,
            existingComment = uiState.userReview?.comment ?: "",
            onDismiss = {
                showWriteReview = false
                isEditingReview = false
                reviewSuccess = false
                reviewError = null
                reviewNeedsAuth = false
            },
            onSubmitReview = { stars, comment ->
                reviewError = null
                reviewNeedsAuth = false
                if (isEditingReview && uiState.userReview != null) {
                    viewModel.updateReview(
                        reviewId = uiState.userReview!!.id,
                        stars = stars,
                        comment = comment,
                        onSuccess = { reviewSuccess = true },
                        onError = { error ->
                            if (error.contains("Unauthenticated", ignoreCase = true) ||
                                error.contains("401", ignoreCase = true)) {
                                reviewNeedsAuth = true
                            } else {
                                reviewError = error
                            }
                        }
                    )
                } else {
                    viewModel.createReview(
                        stars = stars,
                        comment = comment,
                        onSuccess = { reviewSuccess = true },
                        onError = { error ->
                            if (error.contains("Unauthenticated", ignoreCase = true) ||
                                error.contains("401", ignoreCase = true)) {
                                reviewNeedsAuth = true
                            } else {
                                reviewError = error
                            }
                        }
                    )
                }
            },
            onNavigateToAuth = {
                showWriteReview = false
                isEditingReview = false
                reviewNeedsAuth = false
                onNavigateToAuth()
            }
        )
    }

    // Claim Store Sheet
    if (showClaimStore && uiState.store != null) {
        ClaimStoreSheet(
            store = uiState.store!!,
            isSubmitting = uiState.isSubmittingClaim,
            onDismiss = { showClaimStore = false },
            onSubmitClaim = { name, phone, note ->
                viewModel.createClaim(
                    requesterName = name,
                    requesterPhone = phone,
                    note = note,
                    onSuccess = { showClaimStore = false },
                    onError = { /* TODO: Show error toast */ }
                )
            }
        )
    }

    // Report Store Sheet
    var reportSuccess by remember { mutableStateOf(false) }
    var reportError by remember { mutableStateOf<String?>(null) }
    var reportNeedsAuth by remember { mutableStateOf(false) }

    if (showReport && uiState.store != null) {
        ReportStoreSheet(
            store = uiState.store!!,
            isSubmitting = uiState.isSubmittingReport,
            showSuccess = reportSuccess,
            errorMessage = reportError,
            needsAuth = reportNeedsAuth,
            onDismiss = {
                showReport = false
                reportSuccess = false
                reportError = null
                reportNeedsAuth = false
            },
            onSubmitReport = { reason, note ->
                reportError = null
                reportNeedsAuth = false
                viewModel.createReport(
                    reason = reason,
                    note = note,
                    onSuccess = { reportSuccess = true },
                    onError = { error ->
                        if (error.contains("Unauthenticated", ignoreCase = true) ||
                            error.contains("401", ignoreCase = true)) {
                            reportNeedsAuth = true
                        } else {
                            reportError = error
                        }
                    }
                )
            },
            onNavigateToAuth = {
                showReport = false
                reportNeedsAuth = false
                onNavigateToAuth()
            }
        )
    }
}

@Composable
private fun StoreHeader(
    store: Store,
    summary: StoreSummary?
) {
    Box(
        modifier = Modifier.fillMaxWidth()
    ) {
        // Gradient Background
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(180.dp)
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            PrimaryGreen.copy(alpha = 0.15f),
                            PrimaryGreen.copy(alpha = 0.05f),
                            Color.Transparent
                        )
                    )
                )
        )

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(Spacing.screenPadding),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(Spacing.md))

            // Logo with shadow and border
            Box(
                modifier = Modifier
                    .size(110.dp)
                    .shadow(12.dp, RoundedCornerShape(24.dp))
                    .clip(RoundedCornerShape(24.dp))
                    .background(White)
                    .padding(3.dp)
                    .clip(RoundedCornerShape(21.dp))
                    .background(
                        Brush.linearGradient(
                            listOf(PrimaryGreen.copy(alpha = 0.1f), PrimaryGreen.copy(alpha = 0.05f))
                        )
                    ),
                contentAlignment = Alignment.Center
            ) {
                CachedLogoImage(
                    urlString = store.logo,
                    fallbackInitials = store.nameInitial,
                    modifier = Modifier.fillMaxSize(),
                    cornerRadius = 21.dp
                )
            }

            Spacer(modifier = Modifier.height(Spacing.lg))

            // Name + Verified
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    text = store.name,
                    style = PreuvelyTypography.title2.copy(fontWeight = FontWeight.Bold),
                    color = TextPrimary
                )
                if (store.isVerified) {
                    Spacer(modifier = Modifier.width(Spacing.xs))
                    VerifiedBadge(size = BadgeSize.MEDIUM)
                }
            }

            // Description
            store.description?.let { description ->
                Spacer(modifier = Modifier.height(Spacing.sm))
                Text(
                    text = description,
                    style = PreuvelyTypography.body,
                    color = TextSecondary,
                    textAlign = TextAlign.Center,
                    maxLines = 3,
                    overflow = TextOverflow.Ellipsis
                )
            }

            // Categories as styled chips
            if (store.categories.isNotEmpty()) {
                Spacer(modifier = Modifier.height(Spacing.md))
                LazyRow(
                    horizontalArrangement = Arrangement.spacedBy(Spacing.sm)
                ) {
                    items(store.categories) { category ->
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(20.dp))
                                .background(PrimaryGreen.copy(alpha = 0.1f))
                                .border(1.dp, PrimaryGreen.copy(alpha = 0.3f), RoundedCornerShape(20.dp))
                                .padding(horizontal = 16.dp, vertical = 8.dp)
                        ) {
                            Text(
                                text = category.name,
                                style = PreuvelyTypography.footnote.copy(fontWeight = FontWeight.Medium),
                                color = PrimaryGreen
                            )
                        }
                    }
                }
            }

            // City with icon
            store.city?.let { city ->
                Spacer(modifier = Modifier.height(Spacing.md))
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier
                        .clip(RoundedCornerShape(12.dp))
                        .background(TextSecondary.copy(alpha = 0.08f))
                        .padding(horizontal = 12.dp, vertical = 6.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.LocationOn,
                        contentDescription = null,
                        tint = TextSecondary,
                        modifier = Modifier.size(14.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = city,
                        style = PreuvelyTypography.caption1,
                        color = TextSecondary
                    )
                }
            }
        }
    }
}

@Composable
private fun SocialLinksSection(
    links: List<StoreLink>,
    onLinkClick: (String) -> Unit
) {
    Column(modifier = Modifier.padding(Spacing.screenPadding)) {
        LazyRow(
            horizontalArrangement = Arrangement.spacedBy(Spacing.md)
        ) {
            items(links) { link ->
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.clickable { onLinkClick(link.url) }
                ) {
                    PlatformIconCircle(
                        platform = link.platform,
                        size = 60.dp
                    )
                    Spacer(modifier = Modifier.height(Spacing.xs))
                    Text(
                        text = link.platform.displayName,
                        style = PreuvelyTypography.caption1,
                        color = TextSecondary
                    )
                }
            }
        }
    }
}

@Composable
private fun ContactsSection(
    contacts: StoreContact,
    onWhatsAppClick: (String) -> Unit,
    onPhoneClick: (String) -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = Spacing.screenPadding),
        horizontalArrangement = Arrangement.spacedBy(Spacing.md)
    ) {
        contacts.whatsapp?.let { whatsapp ->
            Box(
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(Spacing.radiusMedium))
                    .background(WhatsAppGreen.copy(alpha = 0.1f))
                    .clickable { onWhatsAppClick(whatsapp) }
                    .padding(Spacing.md),
                contentAlignment = Alignment.Center
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.Chat,
                        contentDescription = null,
                        tint = WhatsAppGreen
                    )
                    Spacer(modifier = Modifier.width(Spacing.sm))
                    Text(
                        text = stringResource(R.string.store_whatsapp),
                        style = PreuvelyTypography.subheadlineBold,
                        color = WhatsAppGreen
                    )
                }
            }
        }

        contacts.phone?.let { phone ->
            Box(
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(Spacing.radiusMedium))
                    .background(PrimaryGreen.copy(alpha = 0.1f))
                    .clickable { onPhoneClick(phone) }
                    .padding(Spacing.md),
                contentAlignment = Alignment.Center
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.Phone,
                        contentDescription = null,
                        tint = PrimaryGreen
                    )
                    Spacer(modifier = Modifier.width(Spacing.sm))
                    Text(
                        text = stringResource(R.string.store_call),
                        style = PreuvelyTypography.subheadlineBold,
                        color = PrimaryGreen
                    )
                }
            }
        }
    }
}

@Composable
private fun RatingBreakdownSection(summary: StoreSummary) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(Spacing.screenPadding)
            .shadow(
                elevation = 8.dp,
                shape = RoundedCornerShape(20.dp),
                ambientColor = PrimaryGreen.copy(alpha = 0.1f),
                spotColor = PrimaryGreen.copy(alpha = 0.1f)
            ),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = White)
    ) {
        Column(modifier = Modifier.padding(20.dp)) {
            // Header with icon
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    modifier = Modifier
                        .size(40.dp)
                        .clip(RoundedCornerShape(12.dp))
                        .background(
                            Brush.linearGradient(
                                listOf(StarYellow, StarYellow.copy(alpha = 0.7f))
                            )
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Star,
                        contentDescription = null,
                        tint = White,
                        modifier = Modifier.size(22.dp)
                    )
                }
                Spacer(modifier = Modifier.width(12.dp))
                Text(
                    text = stringResource(R.string.store_rating_breakdown),
                    style = PreuvelyTypography.headline.copy(fontWeight = FontWeight.Bold),
                    color = TextPrimary
                )
            }

            Spacer(modifier = Modifier.height(20.dp))

            Row(verticalAlignment = Alignment.CenterVertically) {
                // Average rating with circular background
                Box(
                    modifier = Modifier
                        .size(100.dp)
                        .clip(CircleShape)
                        .background(
                            Brush.radialGradient(
                                colors = listOf(
                                    StarYellow.copy(alpha = 0.15f),
                                    StarYellow.copy(alpha = 0.05f)
                                )
                            )
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text = String.format("%.1f", summary.avgRating),
                            style = PreuvelyTypography.largeTitle.copy(
                                fontSize = 32.sp,
                                fontWeight = FontWeight.Bold
                            ),
                            color = TextPrimary
                        )
                        Row {
                            repeat(5) { index ->
                                Icon(
                                    imageVector = if (index < summary.avgRating.toInt()) Icons.Default.Star else Icons.Default.StarBorder,
                                    contentDescription = null,
                                    tint = StarYellow,
                                    modifier = Modifier.size(14.dp)
                                )
                            }
                        }
                        Spacer(modifier = Modifier.height(2.dp))
                        Text(
                            text = "${summary.reviewsCount} reviews",
                            style = PreuvelyTypography.caption2,
                            color = TextSecondary
                        )
                    }
                }

                Spacer(modifier = Modifier.width(20.dp))

                // Breakdown bars with improved design
                Column(modifier = Modifier.weight(1f)) {
                    (5 downTo 1).forEach { stars ->
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier.padding(vertical = 3.dp)
                        ) {
                            Text(
                                text = "$stars",
                                style = PreuvelyTypography.caption1.copy(fontWeight = FontWeight.SemiBold),
                                color = TextSecondary,
                                modifier = Modifier.width(14.dp)
                            )
                            Icon(
                                imageVector = Icons.Default.Star,
                                contentDescription = null,
                                tint = StarYellow,
                                modifier = Modifier.size(14.dp)
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Box(
                                modifier = Modifier
                                    .weight(1f)
                                    .height(10.dp)
                                    .clip(RoundedCornerShape(5.dp))
                                    .background(Gray5)
                            ) {
                                Box(
                                    modifier = Modifier
                                        .fillMaxHeight()
                                        .fillMaxWidth(summary.ratingBreakdown.percentage(stars))
                                        .clip(RoundedCornerShape(5.dp))
                                        .background(
                                            Brush.horizontalGradient(
                                                listOf(StarYellow, StarYellow.copy(alpha = 0.8f))
                                            )
                                        )
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun WriteReviewSection(
    hasReviewed: Boolean,
    onWriteReview: () -> Unit,
    onEditReview: () -> Unit
) {
    Column(modifier = Modifier.padding(Spacing.screenPadding)) {
        PrimaryButton(
            text = if (hasReviewed) stringResource(R.string.store_edit_review) else stringResource(R.string.store_write_review),
            onClick = if (hasReviewed) onEditReview else onWriteReview,
            enabled = true,
            icon = Icons.Default.Edit
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun WriteReviewSheet(
    store: Store,
    isSubmitting: Boolean,
    showSuccess: Boolean,
    errorMessage: String?,
    needsAuth: Boolean,
    isEditing: Boolean = false,
    existingStars: Int = 0,
    existingComment: String = "",
    onDismiss: () -> Unit,
    onSubmitReview: (stars: Int, comment: String) -> Unit,
    onNavigateToAuth: () -> Unit
) {
    var stars by remember { mutableIntStateOf(existingStars) }
    var comment by remember { mutableStateOf(existingComment) }

    val ratingLabelPoor = stringResource(R.string.review_rating_poor)
    val ratingLabelFair = stringResource(R.string.review_rating_fair)
    val ratingLabelGood = stringResource(R.string.review_rating_good)
    val ratingLabelVeryGood = stringResource(R.string.review_rating_very_good)
    val ratingLabelExcellent = stringResource(R.string.review_rating_excellent)
    val ratingLabels = listOf("", ratingLabelPoor, ratingLabelFair, ratingLabelGood, ratingLabelVeryGood, ratingLabelExcellent)

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = BackgroundPrimary
    ) {
        // Login Required State
        if (needsAuth) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(Spacing.screenPadding)
                    .padding(bottom = 32.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Box(
                    modifier = Modifier
                        .size(80.dp)
                        .clip(CircleShape)
                        .background(PrimaryGreen.copy(alpha = 0.1f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Person,
                        contentDescription = null,
                        tint = PrimaryGreen,
                        modifier = Modifier.size(40.dp)
                    )
                }

                Spacer(modifier = Modifier.height(Spacing.lg))

                Text(
                    text = stringResource(R.string.review_login_required),
                    style = PreuvelyTypography.title3,
                    color = TextPrimary
                )

                Spacer(modifier = Modifier.height(Spacing.sm))

                Text(
                    text = stringResource(R.string.review_login_message),
                    style = PreuvelyTypography.body,
                    color = TextSecondary,
                    textAlign = TextAlign.Center
                )

                Spacer(modifier = Modifier.height(Spacing.xl))

                PrimaryButton(
                    text = stringResource(R.string.review_login),
                    onClick = onNavigateToAuth
                )

                Spacer(modifier = Modifier.height(Spacing.md))

                SecondaryButton(
                    text = stringResource(R.string.cancel),
                    onClick = onDismiss
                )
            }
        }
        // Success State
        else if (showSuccess) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(Spacing.screenPadding)
                    .padding(bottom = 32.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Box(
                    modifier = Modifier
                        .size(80.dp)
                        .clip(CircleShape)
                        .background(SuccessGreen.copy(alpha = 0.1f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Check,
                        contentDescription = null,
                        tint = SuccessGreen,
                        modifier = Modifier.size(40.dp)
                    )
                }

                Spacer(modifier = Modifier.height(Spacing.lg))

                Text(
                    text = if (isEditing) stringResource(R.string.review_success_edit) else stringResource(R.string.review_success),
                    style = PreuvelyTypography.title3,
                    color = TextPrimary
                )

                Spacer(modifier = Modifier.height(Spacing.sm))

                Text(
                    text = if (isEditing) stringResource(R.string.review_success_edit_message) else stringResource(R.string.review_success_message),
                    style = PreuvelyTypography.body,
                    color = TextSecondary,
                    textAlign = TextAlign.Center
                )

                Spacer(modifier = Modifier.height(Spacing.xl))

                PrimaryButton(
                    text = stringResource(R.string.done),
                    onClick = onDismiss
                )
            }
        }
        // Review Form
        else {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 32.dp)
            ) {
            // Header with gradient
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(
                        Brush.linearGradient(
                            colors = listOf(PrimaryGreen, PrimaryGreenLight)
                        )
                    )
                    .padding(Spacing.lg)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier
                            .size(48.dp)
                            .clip(CircleShape)
                            .background(White.copy(alpha = 0.2f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.RateReview,
                            contentDescription = null,
                            tint = White,
                            modifier = Modifier.size(24.dp)
                        )
                    }
                    Spacer(modifier = Modifier.width(Spacing.md))
                    Column {
                        Text(
                            text = if (isEditing) stringResource(R.string.review_title_edit) else stringResource(R.string.review_title),
                            style = PreuvelyTypography.title3,
                            color = White
                        )
                        Text(
                            text = if (isEditing) stringResource(R.string.review_update_experience) else stringResource(R.string.review_share_experience),
                            style = PreuvelyTypography.caption1,
                            color = White.copy(alpha = 0.8f)
                        )
                    }
                }
            }

            Column(
                modifier = Modifier.padding(Spacing.screenPadding)
            ) {
                // Store Card
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(Spacing.radiusMedium),
                    colors = CardDefaults.cardColors(containerColor = Gray6)
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(Spacing.md),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        StoreLogoImage(
                            logoUrl = store.logo,
                            storeName = store.name,
                            size = 48.dp
                        )
                        Spacer(modifier = Modifier.width(Spacing.md))
                        Column(modifier = Modifier.weight(1f)) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Text(
                                    text = store.name,
                                    style = PreuvelyTypography.subheadlineBold,
                                    color = TextPrimary
                                )
                                if (store.isVerified) {
                                    Spacer(modifier = Modifier.width(Spacing.xs))
                                    VerifiedBadge(size = BadgeSize.SMALL)
                                }
                            }
                            if (store.categories.isNotEmpty()) {
                                Text(
                                    text = store.categories.firstOrNull()?.name ?: "",
                                    style = PreuvelyTypography.caption1,
                                    color = TextSecondary
                                )
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(Spacing.xl))

                // Rating Section
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(Spacing.radiusMedium),
                    colors = CardDefaults.cardColors(containerColor = CardBackground),
                    elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(Spacing.lg),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = stringResource(R.string.review_how_was_experience),
                            style = PreuvelyTypography.subheadlineBold,
                            color = TextPrimary
                        )

                        Spacer(modifier = Modifier.height(Spacing.lg))

                        // Star Rating
                        Row(
                            horizontalArrangement = Arrangement.Center
                        ) {
                            (1..5).forEach { index ->
                                Box(
                                    modifier = Modifier
                                        .size(52.dp)
                                        .clip(CircleShape)
                                        .background(
                                            if (index <= stars) StarYellow.copy(alpha = 0.15f)
                                            else Color.Transparent
                                        )
                                        .clickable { stars = index }
                                        .padding(6.dp),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Icon(
                                        imageVector = if (index <= stars) Icons.Default.Star else Icons.Default.StarBorder,
                                        contentDescription = null,
                                        tint = if (index <= stars) StarYellow else Gray4,
                                        modifier = Modifier.size(36.dp)
                                    )
                                }
                            }
                        }

                        // Rating Label
                        if (stars > 0) {
                            Spacer(modifier = Modifier.height(Spacing.md))
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(Spacing.radiusSmall))
                                    .background(
                                        when (stars) {
                                            1, 2 -> ErrorRed.copy(alpha = 0.1f)
                                            3 -> StarYellow.copy(alpha = 0.1f)
                                            else -> SuccessGreen.copy(alpha = 0.1f)
                                        }
                                    )
                                    .padding(horizontal = Spacing.md, vertical = Spacing.xs)
                            ) {
                                Text(
                                    text = ratingLabels[stars],
                                    style = PreuvelyTypography.subheadlineBold,
                                    color = when (stars) {
                                        1, 2 -> ErrorRed
                                        3 -> StarYellow
                                        else -> SuccessGreen
                                    }
                                )
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(Spacing.lg))

                // Review Text Section
                Text(
                    text = stringResource(R.string.review_tell_us_more),
                    style = PreuvelyTypography.subheadlineBold,
                    color = TextPrimary
                )
                Spacer(modifier = Modifier.height(Spacing.sm))

                OutlinedTextField(
                    value = comment,
                    onValueChange = { if (it.length <= 500) comment = it },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(140.dp),
                    placeholder = {
                        Text(
                            text = stringResource(R.string.review_comment_placeholder),
                            style = PreuvelyTypography.body,
                            color = TextTertiary
                        )
                    },
                    shape = RoundedCornerShape(Spacing.radiusMedium),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = PrimaryGreen,
                        unfocusedBorderColor = Gray4,
                        focusedContainerColor = Gray6.copy(alpha = 0.5f),
                        unfocusedContainerColor = Gray6.copy(alpha = 0.5f)
                    )
                )

                // Character count & validation
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = Spacing.xs),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    if (comment.isNotEmpty() && comment.length < 8) {
                        Text(
                            text = stringResource(R.string.review_min_chars),
                            style = PreuvelyTypography.caption1,
                            color = ErrorRed
                        )
                    } else {
                        Spacer(modifier = Modifier.weight(1f))
                    }
                    Text(
                        text = "${comment.length}/500",
                        style = PreuvelyTypography.caption1,
                        color = if (comment.length >= 8) TextSecondary else Gray4
                    )
                }

                // Error message
                errorMessage?.let { error ->
                    Spacer(modifier = Modifier.height(Spacing.md))
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(Spacing.radiusMedium))
                            .background(ErrorRed.copy(alpha = 0.1f))
                            .padding(Spacing.md),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = Icons.Default.Error,
                            contentDescription = null,
                            tint = ErrorRed,
                            modifier = Modifier.size(20.dp)
                        )
                        Spacer(modifier = Modifier.width(Spacing.sm))
                        Text(
                            text = error,
                            style = PreuvelyTypography.caption1,
                            color = ErrorRed
                        )
                    }
                }

                Spacer(modifier = Modifier.height(Spacing.xl))

                // Submit Button
                Button(
                    onClick = { onSubmitReview(stars, comment) },
                    enabled = stars > 0 && comment.length >= 8 && !isSubmitting,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp),
                    shape = RoundedCornerShape(Spacing.radiusMedium),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = PrimaryGreen,
                        disabledContainerColor = Gray4
                    )
                ) {
                    if (isSubmitting) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(20.dp),
                            color = White,
                            strokeWidth = 2.dp
                        )
                    } else {
                        Icon(
                            imageVector = Icons.Default.Send,
                            contentDescription = null,
                            modifier = Modifier.size(20.dp)
                        )
                        Spacer(modifier = Modifier.width(Spacing.sm))
                        Text(
                            text = if (isEditing) stringResource(R.string.review_update) else stringResource(R.string.review_submit),
                            style = PreuvelyTypography.subheadlineBold
                        )
                    }
                }
            }
        }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ClaimStoreSheet(
    store: Store,
    isSubmitting: Boolean,
    onDismiss: () -> Unit,
    onSubmitClaim: (name: String, phone: String, note: String?) -> Unit
) {
    var ownerName by remember { mutableStateOf("") }
    var whatsappNumber by remember { mutableStateOf("") }
    var note by remember { mutableStateOf("") }
    var showSuccess by remember { mutableStateOf(false) }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = BackgroundPrimary
    ) {
        if (showSuccess) {
            // Success State
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(Spacing.screenPadding)
                    .padding(bottom = 32.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Box(
                    modifier = Modifier
                        .size(80.dp)
                        .clip(CircleShape)
                        .background(SuccessGreen.copy(alpha = 0.1f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Check,
                        contentDescription = null,
                        tint = SuccessGreen,
                        modifier = Modifier.size(40.dp)
                    )
                }

                Spacer(modifier = Modifier.height(Spacing.lg))

                Text(
                    text = stringResource(R.string.claim_success),
                    style = PreuvelyTypography.title3,
                    color = TextPrimary
                )

                Spacer(modifier = Modifier.height(Spacing.sm))

                Text(
                    text = stringResource(R.string.claim_success_message),
                    style = PreuvelyTypography.body,
                    color = TextSecondary,
                    textAlign = TextAlign.Center
                )

                Spacer(modifier = Modifier.height(Spacing.xl))

                PrimaryButton(
                    text = stringResource(R.string.claim_got_it),
                    onClick = onDismiss
                )
            }
        } else {
            // Form
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(Spacing.screenPadding)
                    .padding(bottom = 32.dp)
            ) {
                Text(
                    text = stringResource(R.string.claim_title),
                    style = PreuvelyTypography.title3,
                    color = TextPrimary
                )

                Spacer(modifier = Modifier.height(Spacing.sm))

                // Info Banner
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(Spacing.radiusMedium))
                        .background(PrimaryGreen.copy(alpha = 0.1f))
                        .padding(Spacing.md),
                    verticalAlignment = Alignment.Top
                ) {
                    Icon(
                        imageVector = Icons.Default.Info,
                        contentDescription = null,
                        tint = PrimaryGreen,
                        modifier = Modifier.size(20.dp)
                    )
                    Spacer(modifier = Modifier.width(Spacing.sm))
                    Text(
                        text = stringResource(R.string.claim_info_banner),
                        style = PreuvelyTypography.caption1,
                        color = TextSecondary
                    )
                }

                Spacer(modifier = Modifier.height(Spacing.xl))

                // Owner Name
                OutlinedTextField(
                    value = ownerName,
                    onValueChange = { ownerName = it },
                    label = { Text(stringResource(R.string.claim_owner_name)) },
                    leadingIcon = {
                        Icon(Icons.Default.Person, null, tint = Gray3)
                    },
                    modifier = Modifier.fillMaxWidth(),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = PrimaryGreen,
                        unfocusedBorderColor = Gray4
                    ),
                    singleLine = true
                )

                Spacer(modifier = Modifier.height(Spacing.md))

                // WhatsApp Number
                OutlinedTextField(
                    value = whatsappNumber,
                    onValueChange = { whatsappNumber = it },
                    label = { Text(stringResource(R.string.claim_whatsapp)) },
                    leadingIcon = {
                        Icon(Icons.Default.Message, null, tint = Gray3)
                    },
                    modifier = Modifier.fillMaxWidth(),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = PrimaryGreen,
                        unfocusedBorderColor = Gray4
                    ),
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone)
                )

                Spacer(modifier = Modifier.height(Spacing.md))

                // Note (Optional)
                OutlinedTextField(
                    value = note,
                    onValueChange = { note = it },
                    label = { Text(stringResource(R.string.claim_note)) },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(100.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = PrimaryGreen,
                        unfocusedBorderColor = Gray4
                    )
                )

                Spacer(modifier = Modifier.height(Spacing.xl))

                PrimaryButton(
                    text = stringResource(R.string.claim_submit),
                    onClick = {
                        onSubmitClaim(ownerName, whatsappNumber, note.ifBlank { null })
                        showSuccess = true
                    },
                    enabled = ownerName.isNotBlank() && whatsappNumber.length >= 10 && !isSubmitting,
                    isLoading = isSubmitting
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ReportStoreSheet(
    store: Store,
    isSubmitting: Boolean,
    showSuccess: Boolean,
    errorMessage: String?,
    needsAuth: Boolean,
    onDismiss: () -> Unit,
    onSubmitReport: (reason: String, note: String?) -> Unit,
    onNavigateToAuth: () -> Unit
) {
    var selectedReason by remember { mutableStateOf<String?>(null) }
    var note by remember { mutableStateOf("") }

    val reasonSpam = stringResource(R.string.report_spam)
    val reasonAbuse = stringResource(R.string.report_abuse)
    val reasonFake = stringResource(R.string.report_fake)
    val reasonOther = stringResource(R.string.report_other)
    val reasons = listOf(
        "spam" to reasonSpam,
        "abuse" to reasonAbuse,
        "fake" to reasonFake,
        "other" to reasonOther
    )

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = BackgroundPrimary
    ) {
        if (needsAuth) {
            // Login Required State
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(Spacing.screenPadding)
                    .padding(bottom = 32.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Box(
                    modifier = Modifier
                        .size(80.dp)
                        .clip(CircleShape)
                        .background(PrimaryGreen.copy(alpha = 0.1f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Person,
                        contentDescription = null,
                        tint = PrimaryGreen,
                        modifier = Modifier.size(40.dp)
                    )
                }

                Spacer(modifier = Modifier.height(Spacing.lg))

                Text(
                    text = stringResource(R.string.review_login_required),
                    style = PreuvelyTypography.title3,
                    color = TextPrimary
                )

                Spacer(modifier = Modifier.height(Spacing.sm))

                Text(
                    text = stringResource(R.string.profile_report_login_message),
                    style = PreuvelyTypography.body,
                    color = TextSecondary,
                    textAlign = TextAlign.Center
                )

                Spacer(modifier = Modifier.height(Spacing.xl))

                PrimaryButton(
                    text = stringResource(R.string.review_login),
                    onClick = onNavigateToAuth
                )

                Spacer(modifier = Modifier.height(Spacing.md))

                SecondaryButton(
                    text = stringResource(R.string.cancel),
                    onClick = onDismiss
                )
            }
        } else if (showSuccess) {
            // Success State
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(Spacing.screenPadding)
                    .padding(bottom = 32.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Box(
                    modifier = Modifier
                        .size(80.dp)
                        .clip(CircleShape)
                        .background(SuccessGreen.copy(alpha = 0.1f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Check,
                        contentDescription = null,
                        tint = SuccessGreen,
                        modifier = Modifier.size(40.dp)
                    )
                }

                Spacer(modifier = Modifier.height(Spacing.lg))

                Text(
                    text = stringResource(R.string.report_success),
                    style = PreuvelyTypography.title3,
                    color = TextPrimary
                )

                Spacer(modifier = Modifier.height(Spacing.sm))

                Text(
                    text = stringResource(R.string.report_success_message),
                    style = PreuvelyTypography.body,
                    color = TextSecondary,
                    textAlign = TextAlign.Center
                )

                Spacer(modifier = Modifier.height(Spacing.xl))

                PrimaryButton(
                    text = stringResource(R.string.done),
                    onClick = onDismiss
                )
            }
        } else {
            // Form
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(Spacing.screenPadding)
                    .padding(bottom = 32.dp)
            ) {
                Text(
                    text = stringResource(R.string.report_title),
                    style = PreuvelyTypography.title3,
                    color = TextPrimary
                )

                Spacer(modifier = Modifier.height(Spacing.sm))

                // Reporting Header
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(Spacing.radiusMedium))
                        .background(Gray6)
                        .padding(Spacing.md),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = Icons.Default.Store,
                        contentDescription = null,
                        tint = Gray3,
                        modifier = Modifier.size(20.dp)
                    )
                    Spacer(modifier = Modifier.width(Spacing.sm))
                    Text(
                        text = stringResource(R.string.report_store_info, store.name),
                        style = PreuvelyTypography.subheadline,
                        color = TextSecondary
                    )
                }

                Spacer(modifier = Modifier.height(Spacing.xl))

                Text(
                    text = stringResource(R.string.report_reason),
                    style = PreuvelyTypography.subheadlineBold,
                    color = TextPrimary
                )

                Spacer(modifier = Modifier.height(Spacing.md))

                // Reason Options
                reasons.forEach { (value, label) ->
                    val isSelected = selectedReason == value
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(Spacing.radiusMedium))
                            .background(if (isSelected) PrimaryGreen.copy(alpha = 0.1f) else Gray6)
                            .border(
                                width = if (isSelected) 1.5.dp else 0.dp,
                                color = if (isSelected) PrimaryGreen else Color.Transparent,
                                shape = RoundedCornerShape(Spacing.radiusMedium)
                            )
                            .clickable { selectedReason = value }
                            .padding(Spacing.md),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = if (isSelected) Icons.Default.CheckCircle else Icons.Default.RadioButtonUnchecked,
                            contentDescription = null,
                            tint = if (isSelected) PrimaryGreen else Gray3,
                            modifier = Modifier.size(24.dp)
                        )
                        Spacer(modifier = Modifier.width(Spacing.md))
                        Text(
                            text = label,
                            style = PreuvelyTypography.body,
                            color = if (isSelected) PrimaryGreen else TextPrimary
                        )
                    }
                    Spacer(modifier = Modifier.height(Spacing.sm))
                }

                Spacer(modifier = Modifier.height(Spacing.md))

                // Note (Optional)
                OutlinedTextField(
                    value = note,
                    onValueChange = { note = it },
                    label = { Text(stringResource(R.string.report_note)) },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(100.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = PrimaryGreen,
                        unfocusedBorderColor = Gray4
                    )
                )

                // Error message
                errorMessage?.let { error ->
                    Spacer(modifier = Modifier.height(Spacing.md))
                    Text(
                        text = error,
                        style = PreuvelyTypography.caption1,
                        color = ErrorRed
                    )
                }

                Spacer(modifier = Modifier.height(Spacing.xl))

                PrimaryButton(
                    text = stringResource(R.string.report_submit),
                    onClick = {
                        selectedReason?.let { reason ->
                            onSubmitReport(reason, note.ifBlank { null })
                        }
                    },
                    enabled = selectedReason != null && !isSubmitting,
                    isLoading = isSubmitting
                )
            }
        }
    }
}
