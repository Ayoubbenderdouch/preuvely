package com.preuvely.app.ui.screens.notifications

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
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
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.preuvely.app.data.models.AppNotification
import com.preuvely.app.data.models.NotificationType
import com.preuvely.app.ui.components.EmptyStateView
import com.preuvely.app.ui.components.LoadingView
import com.preuvely.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NotificationsScreen(
    onNavigateBack: () -> Unit,
    onNavigateToStore: (String) -> Unit,
    viewModel: NotificationsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val listState = rememberLazyListState()

    // Load more when reaching end
    val shouldLoadMore = remember {
        derivedStateOf {
            val lastVisibleItem = listState.layoutInfo.visibleItemsInfo.lastOrNull()?.index ?: 0
            lastVisibleItem >= uiState.notifications.size - 3
        }
    }

    LaunchedEffect(shouldLoadMore.value) {
        if (shouldLoadMore.value && uiState.hasMorePages && !uiState.isLoadingMore) {
            viewModel.loadMoreNotifications()
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = "Notifications",
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
                actions = {
                    if (uiState.notifications.any { !it.isRead }) {
                        TextButton(onClick = { viewModel.markAllAsRead() }) {
                            Text(
                                text = "Mark all read",
                                style = PreuvelyTypography.subheadlineBold,
                                color = PrimaryGreen
                            )
                        }
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
                uiState.notifications.isEmpty() -> {
                    EmptyStateView(
                        icon = Icons.Default.Notifications,
                        title = "No Notifications",
                        message = "You don't have any notifications yet"
                    )
                }
                else -> {
                    LazyColumn(
                        state = listState,
                        contentPadding = PaddingValues(Spacing.screenPadding),
                        verticalArrangement = Arrangement.spacedBy(Spacing.sm)
                    ) {
                        items(
                            items = uiState.notifications,
                            key = { it.id }
                        ) { notification ->
                            NotificationItem(
                                notification = notification,
                                onClick = {
                                    if (!notification.isRead) {
                                        viewModel.markAsRead(notification.id)
                                    }
                                    // Navigate based on notification type
                                    notification.relatedId?.let { _ ->
                                        // For now, don't navigate
                                    }
                                }
                            )
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
private fun NotificationItem(
    notification: AppNotification,
    onClick: () -> Unit
) {
    val isUnread = !notification.isRead
    val (icon, iconColor) = getNotificationIcon(notification.type)

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(Spacing.radiusMedium))
            .background(if (isUnread) PrimaryGreen.copy(alpha = 0.05f) else CardBackground)
            .clickable(onClick = onClick)
            .padding(Spacing.md),
        verticalAlignment = Alignment.Top
    ) {
        // Icon
        Box(
            modifier = Modifier
                .size(44.dp)
                .clip(CircleShape)
                .background(iconColor.copy(alpha = 0.1f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = iconColor,
                modifier = Modifier.size(20.dp)
            )
        }

        Spacer(modifier = Modifier.width(Spacing.md))

        Column(modifier = Modifier.weight(1f)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.Top
            ) {
                Text(
                    text = notification.title,
                    style = if (isUnread) PreuvelyTypography.subheadlineBold else PreuvelyTypography.subheadline,
                    color = TextPrimary,
                    modifier = Modifier.weight(1f)
                )

                if (isUnread) {
                    Spacer(modifier = Modifier.width(Spacing.sm))
                    Box(
                        modifier = Modifier
                            .size(8.dp)
                            .clip(CircleShape)
                            .background(
                                Brush.linearGradient(listOf(PrimaryGreen, PrimaryGreenLight))
                            )
                    )
                }
            }

            Spacer(modifier = Modifier.height(Spacing.xxs))

            Text(
                text = notification.message,
                style = PreuvelyTypography.caption1,
                color = TextSecondary,
                maxLines = 2
            )

            Spacer(modifier = Modifier.height(Spacing.xs))

            Text(
                text = notification.formattedDate,
                style = PreuvelyTypography.caption2,
                color = Gray3
            )
        }
    }
}

@Composable
private fun getNotificationIcon(type: NotificationType): Pair<ImageVector, androidx.compose.ui.graphics.Color> {
    return when (type) {
        NotificationType.REVIEW_RECEIVED -> Pair(Icons.Default.Star, StarYellow)
        NotificationType.REVIEW_APPROVED -> Pair(Icons.Default.CheckCircle, SuccessGreen)
        NotificationType.REVIEW_REJECTED -> Pair(Icons.Default.Cancel, ErrorRed)
        NotificationType.CLAIM_APPROVED -> Pair(Icons.Default.Verified, SuccessGreen)
        NotificationType.CLAIM_REJECTED -> Pair(Icons.Default.Block, ErrorRed)
        NotificationType.NEW_REPLY -> Pair(Icons.Default.Reply, PrimaryGreen)
        NotificationType.STORE_VERIFIED -> Pair(Icons.Default.Store, PrimaryGreen)
    }
}
