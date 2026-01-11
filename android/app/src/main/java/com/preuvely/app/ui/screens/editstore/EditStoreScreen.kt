package com.preuvely.app.ui.screens.editstore

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.preuvely.app.data.models.Category
import com.preuvely.app.data.models.Platform
import com.preuvely.app.ui.components.*
import com.preuvely.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditStoreScreen(
    onNavigateBack: () -> Unit,
    viewModel: EditStoreViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    var selectedPlatform by remember { mutableStateOf<Platform?>(null) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = "Edit Store",
                        style = PreuvelyTypography.headline,
                        color = TextPrimary
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(
                            imageVector = Icons.Default.Close,
                            contentDescription = "Close",
                            tint = TextPrimary
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = BackgroundPrimary
                )
            )
        },
        containerColor = BackgroundPrimary
    ) { paddingValues ->
        if (uiState.isLoading) {
            LoadingView()
        } else {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues)
                    .verticalScroll(rememberScrollState())
                    .padding(Spacing.screenPadding)
                    .padding(bottom = 100.dp)
            ) {
                // Error
                uiState.error?.let { error ->
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(Spacing.radiusMedium))
                            .background(ErrorRed.copy(alpha = 0.1f))
                            .padding(Spacing.md)
                    ) {
                        Text(
                            text = error,
                            style = PreuvelyTypography.caption1,
                            color = ErrorRed
                        )
                    }
                    Spacer(modifier = Modifier.height(Spacing.md))
                }

                // Store Name
                PreuvelyTextField(
                    value = uiState.name,
                    onValueChange = { viewModel.setName(it) },
                    label = "Store Name *",
                    placeholder = "Enter store name",
                    icon = Icons.Default.Store
                )

                Spacer(modifier = Modifier.height(Spacing.lg))

                // Description
                PreuvelyTextField(
                    value = uiState.description,
                    onValueChange = { viewModel.setDescription(it) },
                    label = "Description (optional)",
                    placeholder = "Describe your store...",
                    icon = Icons.Default.Description,
                    singleLine = false
                )

                Spacer(modifier = Modifier.height(Spacing.lg))

                // City
                PreuvelyTextField(
                    value = uiState.city,
                    onValueChange = { viewModel.setCity(it) },
                    label = "City (optional)",
                    placeholder = "Enter city",
                    icon = Icons.Default.LocationCity
                )

                Spacer(modifier = Modifier.height(Spacing.xl))

                // Platform Selection
                Text(
                    text = "Social Links *",
                    style = PreuvelyTypography.subheadlineBold,
                    color = TextPrimary
                )
                Spacer(modifier = Modifier.height(Spacing.md))

                LazyRow(
                    horizontalArrangement = Arrangement.spacedBy(Spacing.sm)
                ) {
                    items(Platform.entries.filter { it != Platform.WHATSAPP }) { platform ->
                        EditPlatformPill(
                            platform = platform,
                            selected = selectedPlatform == platform,
                            hasLink = uiState.platformLinks[platform]?.isNotBlank() == true,
                            onClick = { selectedPlatform = platform }
                        )
                    }
                }

                Spacer(modifier = Modifier.height(Spacing.md))

                // Platform Link Input
                selectedPlatform?.let { platform ->
                    PreuvelyTextField(
                        value = uiState.platformLinks[platform] ?: "",
                        onValueChange = { viewModel.setPlatformLink(platform, it) },
                        label = "${platform.displayName} Link",
                        placeholder = when (platform) {
                            Platform.INSTAGRAM -> "instagram.com/username"
                            Platform.FACEBOOK -> "facebook.com/page"
                            Platform.TIKTOK -> "tiktok.com/@username"
                            Platform.WEBSITE -> "https://example.com"
                            else -> "Enter link"
                        },
                        icon = Icons.Default.Link,
                        keyboardType = KeyboardType.Uri
                    )
                }

                Spacer(modifier = Modifier.height(Spacing.xl))

                // Contact Info
                Text(
                    text = "Contact Information",
                    style = PreuvelyTypography.subheadlineBold,
                    color = TextPrimary
                )
                Spacer(modifier = Modifier.height(Spacing.md))

                PreuvelyTextField(
                    value = uiState.whatsapp,
                    onValueChange = { viewModel.setWhatsapp(it) },
                    label = "WhatsApp (optional)",
                    placeholder = "+213 5XX XXX XXX",
                    icon = Icons.Default.Chat,
                    keyboardType = KeyboardType.Phone
                )

                Spacer(modifier = Modifier.height(Spacing.md))

                PreuvelyTextField(
                    value = uiState.phone,
                    onValueChange = { viewModel.setPhone(it) },
                    label = "Phone (optional)",
                    placeholder = "+213 XXX XXX XXX",
                    icon = Icons.Default.Phone,
                    keyboardType = KeyboardType.Phone
                )

                Spacer(modifier = Modifier.height(Spacing.xl))

                // Categories
                Text(
                    text = "Categories *",
                    style = PreuvelyTypography.subheadlineBold,
                    color = TextPrimary
                )
                Spacer(modifier = Modifier.height(Spacing.md))

                Column(
                    verticalArrangement = Arrangement.spacedBy(Spacing.sm)
                ) {
                    uiState.categories.chunked(2).forEach { rowCategories ->
                        Row(
                            horizontalArrangement = Arrangement.spacedBy(Spacing.sm),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            rowCategories.forEach { category ->
                                EditCategoryButton(
                                    category = category,
                                    selected = uiState.selectedCategories.contains(category.id),
                                    onClick = { viewModel.toggleCategory(category.id) },
                                    modifier = Modifier.weight(1f)
                                )
                            }
                            if (rowCategories.size == 1) {
                                Spacer(modifier = Modifier.weight(1f))
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(Spacing.xxl))

                // Save Button
                PrimaryButton(
                    text = "Save Changes",
                    onClick = {
                        viewModel.saveStore(onSuccess = onNavigateBack)
                    },
                    enabled = viewModel.isFormValid,
                    isLoading = uiState.isSaving,
                    icon = Icons.Default.Save
                )
            }
        }
    }
}

@Composable
private fun EditPlatformPill(
    platform: Platform,
    selected: Boolean,
    hasLink: Boolean,
    onClick: () -> Unit
) {
    val backgroundColor = when {
        selected -> Brush.linearGradient(listOf(PrimaryGreen, PrimaryGreenLight))
        hasLink -> Brush.linearGradient(listOf(PrimaryGreen.copy(alpha = 0.15f), PrimaryGreen.copy(alpha = 0.15f)))
        else -> Brush.linearGradient(listOf(Gray6, Gray6))
    }

    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(25.dp))
            .background(backgroundColor)
            .clickable(onClick = onClick)
            .padding(horizontal = Spacing.lg, vertical = Spacing.md)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            if (hasLink && !selected) {
                Icon(
                    imageVector = Icons.Default.Check,
                    contentDescription = null,
                    tint = PrimaryGreen,
                    modifier = Modifier.size(16.dp)
                )
                Spacer(modifier = Modifier.width(Spacing.xs))
            }
            Text(
                text = platform.displayName,
                style = PreuvelyTypography.subheadlineBold,
                color = if (selected) White else TextPrimary
            )
        }
    }
}

@Composable
private fun EditCategoryButton(
    category: Category,
    selected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val backgroundColor = if (selected) {
        Brush.linearGradient(listOf(PrimaryGreen, PrimaryGreenLight))
    } else {
        Brush.linearGradient(listOf(Gray6, Gray6))
    }

    Box(
        modifier = modifier
            .clip(RoundedCornerShape(Spacing.radiusMedium))
            .background(backgroundColor)
            .clickable(onClick = onClick)
            .padding(Spacing.md)
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center,
            modifier = Modifier.fillMaxWidth()
        ) {
            if (selected) {
                Icon(
                    imageVector = Icons.Default.Check,
                    contentDescription = null,
                    tint = White,
                    modifier = Modifier.size(14.dp)
                )
                Spacer(modifier = Modifier.width(Spacing.xs))
            }
            Text(
                text = category.name,
                style = PreuvelyTypography.caption1,
                color = if (selected) White else TextPrimary,
                textAlign = TextAlign.Center
            )
        }
    }
}
