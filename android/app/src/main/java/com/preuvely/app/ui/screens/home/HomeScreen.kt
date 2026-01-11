package com.preuvely.app.ui.screens.home

import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.*
import androidx.compose.foundation.pager.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.Notifications
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
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import coil.compose.AsyncImage
import com.preuvely.app.R
import com.preuvely.app.data.models.Banner
import com.preuvely.app.data.models.Category
import com.preuvely.app.data.models.Store
import com.preuvely.app.ui.components.*
import com.preuvely.app.ui.theme.*
import kotlinx.coroutines.delay

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun HomeScreen(
    onNavigateToStore: (String) -> Unit,
    onNavigateToCategory: (Int, String) -> Unit,
    onNavigateToNotifications: () -> Unit,
    onNavigateToSearch: () -> Unit,
    viewModel: HomeViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(BackgroundPrimary)
            .statusBarsPadding()
    ) {
        // Top Bar
        HomeTopBar(
            onSearchClick = onNavigateToSearch,
            onNotificationClick = onNavigateToNotifications
        )

        if (uiState.isLoading && uiState.categories.isEmpty()) {
            LoadingView()
        } else {
            LazyVerticalGrid(
                columns = GridCells.Fixed(2),
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(
                    start = Spacing.screenPadding,
                    end = Spacing.screenPadding,
                    bottom = 100.dp
                ),
                horizontalArrangement = Arrangement.spacedBy(Spacing.md),
                verticalArrangement = Arrangement.spacedBy(Spacing.md)
            ) {
                // Categories Section Header
                item(span = { GridItemSpan(2) }) {
                    SectionHeader(
                        title = stringResource(R.string.home_categories),
                        action = stringResource(R.string.home_see_all),
                        onAction = { /* Show all categories */ },
                        modifier = Modifier.padding(top = Spacing.lg)
                    )
                }

                // Categories Grid (4 per row)
                item(span = { GridItemSpan(2) }) {
                    val categories = uiState.categories.take(8)
                    Column(verticalArrangement = Arrangement.spacedBy(Spacing.sm)) {
                        // First row (4 categories)
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            categories.take(4).forEach { category ->
                                CategoryTile(
                                    category = category,
                                    onClick = { onNavigateToCategory(category.id, category.slug) },
                                    modifier = Modifier.weight(1f)
                                )
                            }
                        }
                        // Second row (next 4 categories)
                        if (categories.size > 4) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                categories.drop(4).take(4).forEach { category ->
                                    CategoryTile(
                                        category = category,
                                        onClick = { onNavigateToCategory(category.id, category.slug) },
                                        modifier = Modifier.weight(1f)
                                    )
                                }
                                // Fill empty slots if less than 4 in second row
                                repeat(4 - categories.drop(4).take(4).size) {
                                    Spacer(modifier = Modifier.weight(1f))
                                }
                            }
                        }
                    }
                }

                // Banners Carousel
                if (uiState.banners.isNotEmpty()) {
                    item(span = { GridItemSpan(2) }) {
                        BannerCarousel(
                            banners = uiState.banners,
                            modifier = Modifier.padding(top = Spacing.lg)
                        )
                    }
                }

                // Top Reviewed Section Header
                item(span = { GridItemSpan(2) }) {
                    SectionHeader(
                        title = stringResource(R.string.home_top_reviewed),
                        action = stringResource(R.string.home_see_all),
                        onAction = onNavigateToSearch,
                        modifier = Modifier.padding(top = Spacing.lg)
                    )
                }

                // Top Rated Stores
                items(uiState.topRatedStores) { store ->
                    ModernStoreCard(
                        store = store,
                        onClick = { onNavigateToStore(store.slug) }
                    )
                }
            }
        }
    }
}

@Composable
private fun HomeTopBar(
    onSearchClick: () -> Unit,
    onNotificationClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = Spacing.screenPadding, vertical = Spacing.md),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Logo
        Image(
            painter = painterResource(id = com.preuvely.app.R.drawable.logo),
            contentDescription = "Preuvely Logo",
            modifier = Modifier
                .size(44.dp)
                .clip(RoundedCornerShape(12.dp)),
            contentScale = ContentScale.Fit
        )

        Spacer(modifier = Modifier.width(Spacing.md))

        // Search Field
        Box(
            modifier = Modifier
                .weight(1f)
                .height(44.dp)
                .clip(RoundedCornerShape(Spacing.radiusMedium))
                .background(Gray6)
                .clickable(onClick = onSearchClick)
                .padding(horizontal = Spacing.md),
            contentAlignment = Alignment.CenterStart
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.Search,
                    contentDescription = null,
                    tint = Gray2,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(Spacing.sm))
                Text(
                    text = stringResource(R.string.home_search_placeholder),
                    style = PreuvelyTypography.body,
                    color = TextTertiary
                )
            }
        }

        Spacer(modifier = Modifier.width(Spacing.md))

        // Notification Button
        Box(
            modifier = Modifier
                .size(44.dp)
                .clip(CircleShape)
                .background(Gray6)
                .clickable(onClick = onNotificationClick),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = Icons.Outlined.Notifications,
                contentDescription = "Notifications",
                tint = TextPrimary,
                modifier = Modifier.size(22.dp)
            )
        }
    }
}

@Composable
private fun CategoryTile(
    category: Category,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.95f else 1f,
        label = "scale"
    )

    Column(
        modifier = modifier
            .scale(scale)
            .clip(RoundedCornerShape(Spacing.radiusMedium))
            .background(CardBackground)
            .clickable(
                interactionSource = interactionSource,
                indication = null,
                onClick = onClick
            )
            .padding(Spacing.sm),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Image(
            painter = painterResource(id = category.categoryDrawableRes),
            contentDescription = category.name,
            modifier = Modifier
                .size(60.dp)
                .clip(RoundedCornerShape(Spacing.radiusSmall)),
            contentScale = ContentScale.Fit
        )
        Spacer(modifier = Modifier.height(Spacing.sm))
        Text(
            text = category.name,
            style = PreuvelyTypography.caption1,
            color = TextPrimary,
            textAlign = TextAlign.Center,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
    }
}

@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun BannerCarousel(
    banners: List<Banner>,
    modifier: Modifier = Modifier
) {
    val pagerState = rememberPagerState(pageCount = { banners.size })

    // Auto-advance
    LaunchedEffect(pagerState) {
        while (true) {
            delay(4000)
            val nextPage = (pagerState.currentPage + 1) % banners.size
            pagerState.animateScrollToPage(nextPage)
        }
    }

    Column(modifier = modifier) {
        HorizontalPager(
            state = pagerState,
            modifier = Modifier
                .fillMaxWidth()
                .height(150.dp)
        ) { page ->
            BannerCard(banner = banners[page])
        }

        Spacer(modifier = Modifier.height(Spacing.md))

        // Page indicators
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.Center
        ) {
            repeat(banners.size) { index ->
                val isSelected = pagerState.currentPage == index
                Box(
                    modifier = Modifier
                        .padding(horizontal = 2.dp)
                        .size(
                            width = if (isSelected) 20.dp else 6.dp,
                            height = 6.dp
                        )
                        .clip(CircleShape)
                        .background(
                            if (isSelected) PrimaryGreen else Gray4
                        )
                )
            }
        }
    }
}

@Composable
private fun BannerCard(banner: Banner) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 2.dp)
            .clip(RoundedCornerShape(20.dp))
    ) {
        AsyncImage(
            model = banner.imageUrl,
            contentDescription = banner.title,
            contentScale = ContentScale.Crop,
            modifier = Modifier.fillMaxSize()
        )

        // Gradient overlay
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.horizontalGradient(
                        colors = listOf(
                            Color.Black.copy(alpha = 0.6f),
                            Color.Transparent
                        )
                    )
                )
        )

        // Content
        Column(
            modifier = Modifier
                .align(Alignment.CenterStart)
                .padding(Spacing.lg)
        ) {
            banner.title?.let {
                Text(
                    text = it,
                    style = PreuvelyTypography.title3,
                    color = White
                )
            }
            banner.subtitle?.let {
                Text(
                    text = it,
                    style = PreuvelyTypography.subheadline,
                    color = White.copy(alpha = 0.9f)
                )
            }
            if (banner.hasLink) {
                Spacer(modifier = Modifier.height(Spacing.sm))
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(Spacing.radiusSmall))
                        .background(White.copy(alpha = 0.2f))
                        .padding(horizontal = Spacing.md, vertical = Spacing.xs)
                ) {
                    Text(
                        text = "Learn More",
                        style = PreuvelyTypography.caption1,
                        color = White
                    )
                }
            }
        }
    }
}

@Composable
private fun ModernStoreCard(
    store: Store,
    onClick: () -> Unit
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.95f else 1f,
        label = "scale"
    )

    Card(
        modifier = Modifier
            .scale(scale)
            .fillMaxWidth()
            .shadow(
                elevation = 4.dp,
                shape = RoundedCornerShape(18.dp)
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
                        style = PreuvelyTypography.footnote.copy(
                            fontWeight = androidx.compose.ui.text.font.FontWeight.SemiBold
                        ),
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
