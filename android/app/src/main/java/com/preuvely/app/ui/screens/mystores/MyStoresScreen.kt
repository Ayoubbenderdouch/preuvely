package com.preuvely.app.ui.screens.mystores

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
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
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import coil.compose.AsyncImage
import com.preuvely.app.data.models.OwnedStore
import com.preuvely.app.data.models.StoreStatus
import com.preuvely.app.ui.components.EmptyStateView
import com.preuvely.app.ui.components.LoadingView
import com.preuvely.app.ui.components.StarRating
import com.preuvely.app.ui.components.BadgeSize
import com.preuvely.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MyStoresScreen(
    onNavigateBack: () -> Unit,
    onNavigateToEditStore: (Int) -> Unit,
    onNavigateToStore: (String) -> Unit,
    viewModel: MyStoresViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = "My Stores",
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
                uiState.stores.isEmpty() -> {
                    EmptyStateView(
                        icon = Icons.Default.Store,
                        title = "No Stores",
                        message = "You don't own any stores yet. Claim a store to manage it."
                    )
                }
                else -> {
                    LazyColumn(
                        contentPadding = PaddingValues(Spacing.screenPadding),
                        verticalArrangement = Arrangement.spacedBy(Spacing.md)
                    ) {
                        items(
                            items = uiState.stores,
                            key = { it.id }
                        ) { store ->
                            OwnedStoreCard(
                                store = store,
                                onEdit = { onNavigateToEditStore(store.id) },
                                onView = { onNavigateToStore(store.slug) }
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
private fun OwnedStoreCard(
    store: OwnedStore,
    onEdit: () -> Unit,
    onView: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(Spacing.radiusLarge),
        colors = CardDefaults.cardColors(containerColor = CardBackground),
        onClick = onView
    ) {
        Column(modifier = Modifier.padding(Spacing.md)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Store Image
                Box(
                    modifier = Modifier
                        .size(60.dp)
                        .clip(RoundedCornerShape(Spacing.radiusMedium))
                        .background(
                            Brush.linearGradient(listOf(PrimaryGreen.copy(alpha = 0.1f), PrimaryGreenLight.copy(alpha = 0.1f)))
                        ),
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
                        Icon(
                            imageVector = Icons.Default.Store,
                            contentDescription = null,
                            tint = PrimaryGreen,
                            modifier = Modifier.size(28.dp)
                        )
                    }
                }

                Spacer(modifier = Modifier.width(Spacing.md))

                // Store Info
                Column(modifier = Modifier.weight(1f)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            text = store.name,
                            style = PreuvelyTypography.headline,
                            color = TextPrimary,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                        if (store.isVerified) {
                            Spacer(modifier = Modifier.width(Spacing.xs))
                            Icon(
                                imageVector = Icons.Default.Verified,
                                contentDescription = "Verified",
                                tint = PrimaryGreen,
                                modifier = Modifier.size(16.dp)
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(Spacing.xxs))

                    Row(verticalAlignment = Alignment.CenterVertically) {
                        StarRating(rating = store.avgRating.toInt(), size = BadgeSize.SMALL)
                        Spacer(modifier = Modifier.width(Spacing.xs))
                        Text(
                            text = "(${store.reviewsCount})",
                            style = PreuvelyTypography.caption1,
                            color = TextSecondary
                        )
                    }
                }

                // Status Badge
                StoreStatusBadge(status = store.status)
            }

            Spacer(modifier = Modifier.height(Spacing.md))

            // Stats Row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                StatItem(value = "0", label = "Views")
                StatItem(value = "${store.reviewsCount}", label = "Reviews")
                StatItem(value = String.format("%.1f", store.avgRating), label = "Rating")
            }

            Spacer(modifier = Modifier.height(Spacing.md))

            // Edit Button
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(Spacing.radiusMedium))
                    .background(PrimaryGreen.copy(alpha = 0.1f))
                    .clickable(onClick = onEdit)
                    .padding(Spacing.md),
                contentAlignment = Alignment.Center
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.Edit,
                        contentDescription = null,
                        tint = PrimaryGreen,
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(Spacing.sm))
                    Text(
                        text = "Edit Store",
                        style = PreuvelyTypography.subheadlineBold,
                        color = PrimaryGreen
                    )
                }
            }
        }
    }
}

@Composable
private fun StatItem(value: String, label: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = value,
            style = PreuvelyTypography.headline,
            color = TextPrimary
        )
        Text(
            text = label,
            style = PreuvelyTypography.caption1,
            color = TextSecondary
        )
    }
}

@Composable
private fun StoreStatusBadge(status: String?) {
    val storeStatus = StoreStatus.fromValue(status)
    val (backgroundColor, textColor, text) = when (storeStatus) {
        StoreStatus.PENDING -> Triple(WarningOrange.copy(alpha = 0.1f), WarningOrange, "Pending")
        StoreStatus.ACTIVE -> Triple(SuccessGreen.copy(alpha = 0.1f), SuccessGreen, "Active")
        StoreStatus.SUSPENDED -> Triple(ErrorRed.copy(alpha = 0.1f), ErrorRed, "Suspended")
    }

    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(Spacing.radiusSmall))
            .background(backgroundColor)
            .padding(horizontal = Spacing.sm, vertical = Spacing.xxs)
    ) {
        Text(
            text = text,
            style = PreuvelyTypography.caption1,
            color = textColor
        )
    }
}
