package com.preuvely.app.ui.screens.search

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.preuvely.app.R
import com.preuvely.app.data.models.Category
import com.preuvely.app.data.models.StoreSortOption
import com.preuvely.app.ui.components.*
import com.preuvely.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SearchScreen(
    onNavigateToStore: (String) -> Unit,
    onNavigateToAddStore: () -> Unit,
    viewModel: SearchViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    var showFilters by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(BackgroundPrimary)
            .statusBarsPadding()
    ) {
        // Top Bar with Search
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = Spacing.screenPadding, vertical = Spacing.md),
            verticalAlignment = Alignment.CenterVertically
        ) {
            SearchBar(
                query = uiState.query,
                onQueryChange = { viewModel.onQueryChange(it) },
                placeholder = stringResource(R.string.search_placeholder),
                onSearch = { viewModel.search() },
                modifier = Modifier.weight(1f)
            )

            Spacer(modifier = Modifier.width(Spacing.md))

            // Filter Button
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .clip(RoundedCornerShape(Spacing.radiusMedium))
                    .background(
                        if (uiState.hasActiveFilters) PrimaryGreen else Gray6
                    )
                    .clickable { showFilters = true },
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Tune,
                    contentDescription = "Filters",
                    tint = if (uiState.hasActiveFilters) White else PrimaryGreen
                )
            }
        }

        // Active Filters
        if (uiState.hasActiveFilters) {
            LazyRow(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = Spacing.screenPadding),
                horizontalArrangement = Arrangement.spacedBy(Spacing.sm)
            ) {
                uiState.selectedCategory?.let { category ->
                    item {
                        FilterChip(
                            text = category.name,
                            icon = Icons.Default.Tag,
                            onRemove = { viewModel.setCategory(null); viewModel.applyFilters() }
                        )
                    }
                }
                if (uiState.verifiedOnly) {
                    item {
                        FilterChip(
                            text = stringResource(R.string.store_verified),
                            icon = Icons.Default.Verified,
                            onRemove = { viewModel.setVerifiedOnly(false); viewModel.applyFilters() }
                        )
                    }
                }
                if (uiState.sortOption != StoreSortOption.BEST_RATED) {
                    item {
                        FilterChip(
                            text = uiState.sortOption.displayName,
                            icon = Icons.Default.Sort,
                            onRemove = { viewModel.setSortOption(StoreSortOption.BEST_RATED); viewModel.applyFilters() }
                        )
                    }
                }
            }
            Spacer(modifier = Modifier.height(Spacing.md))
        }

        // Content
        when {
            uiState.isLoading -> {
                LoadingView()
            }
            !uiState.hasSearched && uiState.query.isBlank() -> {
                // Initial state with search hints
                SearchInitialState(
                    onHintClick = { prefix -> viewModel.onQueryChange(prefix) }
                )
            }
            uiState.stores.isEmpty() && uiState.hasSearched -> {
                EmptyStateView(
                    icon = Icons.Default.SearchOff,
                    title = stringResource(R.string.search_no_results),
                    message = stringResource(R.string.search_try_different),
                    actionText = stringResource(R.string.search_add_store),
                    onAction = onNavigateToAddStore
                )
            }
            else -> {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(
                        horizontal = Spacing.screenPadding,
                        vertical = Spacing.md
                    ),
                    verticalArrangement = Arrangement.spacedBy(Spacing.md)
                ) {
                    items(uiState.stores) { store ->
                        StoreCard(
                            store = store,
                            onClick = { onNavigateToStore(store.slug) }
                        )
                    }

                    if (uiState.isLoadingMore) {
                        item {
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(Spacing.md),
                                contentAlignment = Alignment.Center
                            ) {
                                CircularProgressIndicator(
                                    color = PrimaryGreen,
                                    modifier = Modifier.size(24.dp)
                                )
                            }
                        }
                    } else if (uiState.hasMorePages) {
                        item {
                            LaunchedEffect(Unit) {
                                viewModel.loadMore()
                            }
                        }
                    }
                }
            }
        }
    }

    // Filters Bottom Sheet
    if (showFilters) {
        ModalBottomSheet(
            onDismissRequest = { showFilters = false },
            containerColor = BackgroundPrimary
        ) {
            SearchFiltersSheet(
                categories = uiState.categories,
                selectedCategory = uiState.selectedCategory,
                verifiedOnly = uiState.verifiedOnly,
                sortOption = uiState.sortOption,
                onCategorySelected = { viewModel.setCategory(it) },
                onVerifiedOnlyChanged = { viewModel.setVerifiedOnly(it) },
                onSortOptionSelected = { viewModel.setSortOption(it) },
                onReset = { viewModel.resetFilters() },
                onApply = {
                    viewModel.applyFilters()
                    showFilters = false
                }
            )
        }
    }
}

@Composable
private fun FilterChip(
    text: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    onRemove: () -> Unit
) {
    Row(
        modifier = Modifier
            .clip(RoundedCornerShape(Spacing.radiusRound))
            .background(PrimaryGreen.copy(alpha = 0.1f))
            .padding(horizontal = Spacing.md, vertical = Spacing.xs),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = PrimaryGreen,
            modifier = Modifier.size(14.dp)
        )
        Spacer(modifier = Modifier.width(Spacing.xs))
        Text(
            text = text,
            style = PreuvelyTypography.caption1,
            color = PrimaryGreen
        )
        Spacer(modifier = Modifier.width(Spacing.xs))
        Icon(
            imageVector = Icons.Default.Close,
            contentDescription = "Remove",
            tint = PrimaryGreen,
            modifier = Modifier
                .size(14.dp)
                .clickable(onClick = onRemove)
        )
    }
}

@Composable
private fun SearchFiltersSheet(
    categories: List<Category>,
    selectedCategory: Category?,
    verifiedOnly: Boolean,
    sortOption: StoreSortOption,
    onCategorySelected: (Category?) -> Unit,
    onVerifiedOnlyChanged: (Boolean) -> Unit,
    onSortOptionSelected: (StoreSortOption) -> Unit,
    onReset: () -> Unit,
    onApply: () -> Unit
) {
    val filtersTitle = stringResource(R.string.search_filters)
    val resetText = stringResource(R.string.search_reset)
    val categoryText = stringResource(R.string.search_category)
    val allText = stringResource(R.string.search_all_categories)
    val verifiedOnlyTitle = stringResource(R.string.search_verified_only)
    val verifiedOnlyDesc = stringResource(R.string.search_verified_only_desc)
    val sortByText = stringResource(R.string.search_sort_by)
    val applyText = stringResource(R.string.search_apply)

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(Spacing.screenPadding)
            .padding(bottom = 32.dp)
    ) {
        // Header
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = filtersTitle,
                style = PreuvelyTypography.title2,
                color = TextPrimary
            )
            TextButton(onClick = onReset) {
                Text(resetText, color = ErrorRed)
            }
        }

        Spacer(modifier = Modifier.height(Spacing.xl))

        // Categories
        Text(
            text = categoryText,
            style = PreuvelyTypography.subheadlineBold,
            color = TextPrimary
        )
        Spacer(modifier = Modifier.height(Spacing.md))
        LazyRow(
            horizontalArrangement = Arrangement.spacedBy(Spacing.sm)
        ) {
            item {
                ChipButton(
                    text = allText,
                    selected = selectedCategory == null,
                    onClick = { onCategorySelected(null) }
                )
            }
            items(categories) { category ->
                ChipButton(
                    text = category.name,
                    selected = selectedCategory?.id == category.id,
                    onClick = { onCategorySelected(category) }
                )
            }
        }

        Spacer(modifier = Modifier.height(Spacing.xl))

        // Verified Only Toggle
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(Spacing.radiusLarge))
                .background(Gray6)
                .padding(Spacing.lg),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.Verified,
                    contentDescription = null,
                    tint = PrimaryGreen
                )
                Spacer(modifier = Modifier.width(Spacing.md))
                Column {
                    Text(
                        text = verifiedOnlyTitle,
                        style = PreuvelyTypography.subheadlineBold,
                        color = TextPrimary
                    )
                    Text(
                        text = verifiedOnlyDesc,
                        style = PreuvelyTypography.caption1,
                        color = TextSecondary
                    )
                }
            }
            Switch(
                checked = verifiedOnly,
                onCheckedChange = onVerifiedOnlyChanged,
                colors = SwitchDefaults.colors(
                    checkedThumbColor = White,
                    checkedTrackColor = PrimaryGreen
                )
            )
        }

        Spacer(modifier = Modifier.height(Spacing.xl))

        // Sort Options
        Text(
            text = sortByText,
            style = PreuvelyTypography.subheadlineBold,
            color = TextPrimary
        )
        Spacer(modifier = Modifier.height(Spacing.md))
        val sortOptions = listOf(
            StoreSortOption.BEST_RATED to stringResource(R.string.search_sort_best_rated),
            StoreSortOption.MOST_REVIEWED to stringResource(R.string.search_sort_most_reviewed),
            StoreSortOption.NEWEST to stringResource(R.string.search_sort_newest)
        )
        sortOptions.forEach { (option, displayName) ->
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(Spacing.radiusMedium))
                    .background(
                        if (sortOption == option) PrimaryGreen.copy(alpha = 0.08f)
                        else Color.Transparent
                    )
                    .clickable { onSortOptionSelected(option) }
                    .padding(Spacing.md),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = displayName,
                    style = PreuvelyTypography.body,
                    color = TextPrimary
                )
                if (sortOption == option) {
                    Icon(
                        imageVector = Icons.Default.CheckCircle,
                        contentDescription = null,
                        tint = PrimaryGreen
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(Spacing.xl))

        // Apply Button
        PrimaryButton(
            text = applyText,
            onClick = onApply
        )
    }
}

@Composable
private fun SearchInitialState(
    onHintClick: (String) -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = Spacing.screenPadding),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            imageVector = Icons.Default.Search,
            contentDescription = null,
            modifier = Modifier.size(64.dp),
            tint = Gray4
        )

        Spacer(modifier = Modifier.height(Spacing.lg))

        Text(
            text = stringResource(R.string.search_initial_title),
            style = PreuvelyTypography.title2,
            color = TextPrimary
        )

        Spacer(modifier = Modifier.height(Spacing.sm))

        Text(
            text = stringResource(R.string.search_initial_message),
            style = PreuvelyTypography.body,
            color = TextSecondary
        )

        Spacer(modifier = Modifier.height(Spacing.xl))

        // Search Hints
        Column(
            verticalArrangement = Arrangement.spacedBy(Spacing.md)
        ) {
            // First row - Store related
            Row(
                horizontalArrangement = Arrangement.spacedBy(Spacing.sm),
                modifier = Modifier.fillMaxWidth()
            ) {
                SearchHintChip(
                    text = stringResource(R.string.search_hint_name),
                    icon = Icons.Default.Storefront,
                    onClick = { onHintClick("") },
                    modifier = Modifier.weight(1f)
                )
                SearchHintChip(
                    text = stringResource(R.string.search_hint_phone),
                    icon = Icons.Default.Phone,
                    onClick = { onHintClick("+213") },
                    modifier = Modifier.weight(1f)
                )
                SearchHintChip(
                    text = stringResource(R.string.search_hint_website),
                    icon = Icons.Default.Link,
                    onClick = { onHintClick("https://") },
                    modifier = Modifier.weight(1f)
                )
            }

            // Second row - Social platforms
            Row(
                horizontalArrangement = Arrangement.spacedBy(Spacing.sm),
                modifier = Modifier.fillMaxWidth()
            ) {
                PlatformHintChip(
                    text = "@",
                    iconRes = R.drawable.ic_tiktok,
                    onClick = { onHintClick("@") },
                    modifier = Modifier.weight(1f)
                )
                PlatformHintChip(
                    text = "@",
                    iconRes = R.drawable.ic_instagram,
                    onClick = { onHintClick("@") },
                    modifier = Modifier.weight(1f)
                )
                PlatformHintChip(
                    text = "",
                    iconRes = R.drawable.ic_facebook,
                    onClick = { onHintClick("fb.com/") },
                    modifier = Modifier.weight(1f)
                )
                PlatformHintChip(
                    text = "+213",
                    iconRes = R.drawable.ic_whatsapp,
                    onClick = { onHintClick("+213") },
                    modifier = Modifier.weight(1f)
                )
            }
        }
    }
}

@Composable
private fun SearchHintChip(
    text: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Surface(
        modifier = modifier
            .clip(RoundedCornerShape(Spacing.radiusMedium))
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(Spacing.radiusMedium),
        border = BorderStroke(1.dp, Gray5)
    ) {
        Row(
            modifier = Modifier.padding(horizontal = Spacing.md, vertical = Spacing.sm),
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                modifier = Modifier.size(16.dp),
                tint = TextSecondary
            )
            Spacer(modifier = Modifier.width(Spacing.xs))
            Text(
                text = text,
                style = PreuvelyTypography.caption1,
                color = TextSecondary
            )
        }
    }
}

@Composable
private fun PlatformHintChip(
    text: String,
    iconRes: Int,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Surface(
        modifier = modifier
            .clip(RoundedCornerShape(Spacing.radiusMedium))
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(Spacing.radiusMedium),
        border = BorderStroke(1.dp, Gray5)
    ) {
        Row(
            modifier = Modifier.padding(horizontal = Spacing.md, vertical = Spacing.sm),
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Image(
                painter = painterResource(id = iconRes),
                contentDescription = null,
                modifier = Modifier.size(20.dp),
                contentScale = ContentScale.Fit
            )
            if (text.isNotEmpty()) {
                Spacer(modifier = Modifier.width(Spacing.xs))
                Text(
                    text = text,
                    style = PreuvelyTypography.caption1,
                    color = TextSecondary
                )
            }
        }
    }
}
