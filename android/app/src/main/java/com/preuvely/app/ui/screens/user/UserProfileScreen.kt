package com.preuvely.app.ui.screens.user

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import coil.compose.AsyncImage
import com.preuvely.app.data.models.Review
import com.preuvely.app.ui.components.*
import com.preuvely.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun UserProfileScreen(
    onNavigateBack: () -> Unit,
    onNavigateToStore: (String) -> Unit,
    viewModel: UserProfileViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val listState = rememberLazyListState()

    // Load more when reaching end
    val shouldLoadMore = remember {
        derivedStateOf {
            val lastVisibleItem = listState.layoutInfo.visibleItemsInfo.lastOrNull()?.index ?: 0
            lastVisibleItem >= uiState.reviews.size + 1 // +1 for header
        }
    }

    LaunchedEffect(shouldLoadMore.value) {
        if (shouldLoadMore.value && uiState.hasMoreReviews && !uiState.isLoadingMore) {
            viewModel.loadMoreReviews()
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = uiState.user?.name ?: "Profile",
                        style = PreuvelyTypography.headline,
                        color = TextPrimary
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(
                            imageVector = Icons.Default.ArrowBack,
                            contentDescription = "Back",
                            tint = TextPrimary
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = BackgroundPrimary
                )
            )
        },
        containerColor = BackgroundSecondary
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            when {
                uiState.isLoading -> {
                    LoadingView()
                }
                uiState.error != null -> {
                    EmptyStateView(
                        icon = Icons.Default.Error,
                        title = "Error",
                        message = uiState.error ?: "Something went wrong"
                    )
                }
                uiState.user != null -> {
                    LazyColumn(
                        state = listState,
                        contentPadding = PaddingValues(Spacing.screenPadding),
                        verticalArrangement = Arrangement.spacedBy(Spacing.md)
                    ) {
                        // User Header
                        item {
                            UserProfileHeader(user = uiState.user!!)
                        }

                        // Stats
                        item {
                            UserStatsRow(user = uiState.user!!)
                        }

                        // Reviews Section
                        item {
                            Text(
                                text = "Reviews",
                                style = PreuvelyTypography.headline,
                                color = TextPrimary,
                                modifier = Modifier.padding(top = Spacing.md)
                            )
                        }

                        if (uiState.reviews.isEmpty()) {
                            item {
                                EmptyReviewsSection()
                            }
                        } else {
                            items(
                                items = uiState.reviews,
                                key = { it.id }
                            ) { review ->
                                UserReviewCard(
                                    review = review,
                                    onClick = {
                                        review.store?.slug?.let { onNavigateToStore(it) }
                                    }
                                )
                            }
                        }

                        if (uiState.isLoadingMore) {
                            item {
                                Box(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(Spacing.lg),
                                    contentAlignment = Alignment.Center
                                ) {
                                    CircularProgressIndicator(
                                        modifier = Modifier.size(24.dp),
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
}

@Composable
private fun UserProfileHeader(user: com.preuvely.app.data.models.UserProfile) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = CardBackground)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(Spacing.xl),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Avatar
            Box(
                modifier = Modifier
                    .size(90.dp)
                    .clip(CircleShape)
                    .background(
                        Brush.linearGradient(listOf(PrimaryGreen, PrimaryGreenLight))
                    ),
                contentAlignment = Alignment.Center
            ) {
                if (!user.avatar.isNullOrBlank()) {
                    AsyncImage(
                        model = user.avatar,
                        contentDescription = user.name,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier.fillMaxSize()
                    )
                } else {
                    Text(
                        text = user.initials,
                        style = PreuvelyTypography.title2,
                        color = White
                    )
                }
            }

            Spacer(modifier = Modifier.height(Spacing.lg))

            // Name
            Text(
                text = user.name,
                style = PreuvelyTypography.title3,
                color = TextPrimary
            )

            // Join date
            Text(
                text = "Member since ${user.memberSince}",
                style = PreuvelyTypography.subheadline,
                color = TextSecondary
            )
        }
    }
}

@Composable
private fun UserStatsRow(user: com.preuvely.app.data.models.UserProfile) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(Spacing.sm)
    ) {
        StatCard(
            value = "${user.stats.reviewsCount}",
            label = "Reviews",
            modifier = Modifier.weight(1f)
        )
        StatCard(
            value = "${user.stats.storesCount}",
            label = "Stores",
            modifier = Modifier.weight(1f)
        )
        StatCard(
            value = "${user.reviews.size}",
            label = "Total",
            modifier = Modifier.weight(1f)
        )
    }
}

@Composable
private fun StatCard(
    value: String,
    label: String,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier,
        shape = RoundedCornerShape(Spacing.radiusMedium),
        colors = CardDefaults.cardColors(containerColor = CardBackground)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(Spacing.md),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = value,
                style = PreuvelyTypography.title2,
                color = PrimaryGreen
            )
            Text(
                text = label,
                style = PreuvelyTypography.caption1,
                color = TextSecondary
            )
        }
    }
}

@Composable
private fun EmptyReviewsSection() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(Spacing.radiusMedium),
        colors = CardDefaults.cardColors(containerColor = CardBackground)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(Spacing.xl),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Icon(
                imageVector = Icons.Default.RateReview,
                contentDescription = null,
                tint = Gray3,
                modifier = Modifier.size(48.dp)
            )
            Spacer(modifier = Modifier.height(Spacing.md))
            Text(
                text = "No reviews yet",
                style = PreuvelyTypography.subheadlineBold,
                color = TextSecondary,
                textAlign = TextAlign.Center
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun UserReviewCard(
    review: Review,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(Spacing.radiusMedium),
        colors = CardDefaults.cardColors(containerColor = CardBackground),
        onClick = onClick
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(Spacing.md)
        ) {
            // Store info
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = review.store?.name ?: "Store",
                    style = PreuvelyTypography.subheadlineBold,
                    color = TextPrimary,
                    modifier = Modifier.weight(1f)
                )
                StarRating(rating = review.stars, size = BadgeSize.SMALL)
            }

            Spacer(modifier = Modifier.height(Spacing.sm))

            // Review content
            if (review.comment.isNotBlank()) {
                Text(
                    text = review.comment,
                    style = PreuvelyTypography.body,
                    color = TextSecondary,
                    maxLines = 3
                )
                Spacer(modifier = Modifier.height(Spacing.sm))
            }

            // Date and proofs
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = review.formattedDate,
                    style = PreuvelyTypography.caption1,
                    color = Gray3
                )

                if (review.hasProof) {
                    ProofBadge()
                }
            }
        }
    }
}
