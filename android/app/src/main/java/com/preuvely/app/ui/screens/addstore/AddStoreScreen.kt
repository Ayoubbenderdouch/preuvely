package com.preuvely.app.ui.screens.addstore

import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import coil.compose.AsyncImage
import com.preuvely.app.R
import com.preuvely.app.data.models.Category
import com.preuvely.app.data.models.Platform
import com.preuvely.app.ui.components.*
import com.preuvely.app.ui.theme.*

@Composable
fun AddStoreScreen(
    onNavigateToStore: (String) -> Unit,
    onNavigateToAuth: () -> Unit,
    viewModel: AddStoreViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    // Image picker launcher
    val imagePickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        viewModel.setLogoUri(uri)
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Gray6)
            .statusBarsPadding()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = Spacing.screenPadding)
            .padding(bottom = 140.dp)
    ) {
        Spacer(modifier = Modifier.height(Spacing.lg))

        // Header Section
        HeaderSection()

        Spacer(modifier = Modifier.height(Spacing.xl))

        // Error
        uiState.error?.let { error ->
            ErrorBanner(error = error)
            Spacer(modifier = Modifier.height(Spacing.md))
        }

        // Store Name Card
        FormCard {
            SectionHeader(
                icon = Icons.Default.Tag,
                title = stringResource(R.string.add_store_name),
                required = true
            )
            Spacer(modifier = Modifier.height(Spacing.md))
            StoreNameInput(
                value = uiState.name,
                onValueChange = { viewModel.setName(it) },
                isError = uiState.name.isBlank() && uiState.hasAttemptedSubmit
            )
        }

        Spacer(modifier = Modifier.height(Spacing.md))

        // Logo Card
        FormCard {
            SectionHeader(
                icon = Icons.Default.Image,
                title = stringResource(R.string.add_store_logo),
                required = false
            )
            Spacer(modifier = Modifier.height(Spacing.md))
            LogoUploadSection(
                logoUri = uiState.logoUri,
                onSelectImage = { imagePickerLauncher.launch("image/*") },
                onRemoveImage = { viewModel.setLogoUri(null) }
            )
        }

        Spacer(modifier = Modifier.height(Spacing.md))

        // Platform Card
        FormCard {
            SectionHeader(
                icon = Icons.Default.Apps,
                title = stringResource(R.string.add_store_platform),
                required = true
            )
            Spacer(modifier = Modifier.height(Spacing.md))

            // Platform Pills
            LazyRow(
                horizontalArrangement = Arrangement.spacedBy(Spacing.sm)
            ) {
                items(Platform.entries.filter { it != Platform.WHATSAPP }) { platform ->
                    PlatformPill(
                        platform = platform,
                        selected = uiState.selectedPlatform == platform,
                        hasLink = uiState.platformLinks[platform]?.isNotBlank() == true,
                        onClick = { viewModel.setSelectedPlatform(platform) }
                    )
                }
            }

            // Platform Link Input
            uiState.selectedPlatform?.let { platform ->
                Spacer(modifier = Modifier.height(Spacing.md))
                PlatformLinkInput(
                    platform = platform,
                    value = uiState.platformLinks[platform] ?: "",
                    onValueChange = { viewModel.setPlatformLink(platform, it) }
                )
            }
        }

        Spacer(modifier = Modifier.height(Spacing.md))

        // WhatsApp Card
        FormCard {
            SectionHeader(
                icon = Icons.Default.Message,
                title = "WhatsApp",
                required = false
            )
            Spacer(modifier = Modifier.height(Spacing.md))
            WhatsAppInput(
                value = uiState.whatsapp,
                onValueChange = { viewModel.setWhatsapp(it) }
            )
        }

        Spacer(modifier = Modifier.height(Spacing.md))

        // Categories Card
        FormCard {
            SectionHeader(
                icon = Icons.Default.GridView,
                title = stringResource(R.string.add_store_categories),
                required = true
            )
            Spacer(modifier = Modifier.height(Spacing.md))

            if (uiState.categories.isEmpty()) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(100.dp),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator(color = PrimaryGreen)
                }
            } else {
                CategoryGrid(
                    categories = uiState.categories,
                    selectedCategories = uiState.selectedCategories.toList(),
                    onToggleCategory = { viewModel.toggleCategory(it) }
                )
            }
        }

        Spacer(modifier = Modifier.height(Spacing.md))

        // Info Banner
        InfoBanner()

        Spacer(modifier = Modifier.height(Spacing.xl))

        // Submit Button
        SubmitButton(
            isValid = viewModel.isFormValid,
            isLoading = uiState.isSubmitting,
            onClick = {
                viewModel.submitStore(
                    onSuccess = { slug -> onNavigateToStore(slug) },
                    onAuthRequired = onNavigateToAuth
                )
            }
        )
    }
}

@Composable
private fun HeaderSection() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = Spacing.lg),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Icon with gradient background
        Box(
            modifier = Modifier
                .size(80.dp)
                .clip(CircleShape)
                .background(
                    Brush.linearGradient(
                        listOf(
                            PrimaryGreen.copy(alpha = 0.2f),
                            PrimaryGreen.copy(alpha = 0.05f)
                        )
                    )
                ),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = Icons.Default.Storefront,
                contentDescription = null,
                tint = PrimaryGreen,
                modifier = Modifier.size(32.dp)
            )
        }

        Spacer(modifier = Modifier.height(Spacing.lg))

        Text(
            text = stringResource(R.string.add_store_title),
            style = PreuvelyTypography.title3,
            color = TextPrimary
        )

        Spacer(modifier = Modifier.height(Spacing.xs))

        Text(
            text = stringResource(R.string.add_store_subtitle),
            style = PreuvelyTypography.subheadline,
            color = TextSecondary
        )
    }
}

@Composable
private fun FormCard(
    content: @Composable ColumnScope.() -> Unit
) {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(
                elevation = 2.dp,
                shape = RoundedCornerShape(20.dp),
                spotColor = Color.Black.copy(alpha = 0.05f)
            ),
        shape = RoundedCornerShape(20.dp),
        color = White
    ) {
        Column(
            modifier = Modifier.padding(Spacing.lg),
            content = content
        )
    }
}

@Composable
private fun SectionHeader(
    icon: ImageVector,
    title: String,
    required: Boolean
) {
    Row(
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = PrimaryGreen,
            modifier = Modifier.size(18.dp)
        )
        Spacer(modifier = Modifier.width(Spacing.sm))
        Text(
            text = title,
            style = PreuvelyTypography.subheadlineBold,
            color = TextPrimary
        )
        Spacer(modifier = Modifier.width(Spacing.sm))
        Text(
            text = if (required) "(${stringResource(R.string.add_store_required)})" else "(${stringResource(R.string.add_store_optional)})",
            style = PreuvelyTypography.caption1,
            color = if (required) PrimaryGreen else TextSecondary
        )
    }
}

@Composable
private fun StoreNameInput(
    value: String,
    onValueChange: (String) -> Unit,
    isError: Boolean
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(Gray6)
            .padding(Spacing.md),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(36.dp)
                .clip(CircleShape)
                .background(PrimaryGreen.copy(alpha = 0.1f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = Icons.Default.Edit,
                contentDescription = null,
                tint = PrimaryGreen,
                modifier = Modifier.size(16.dp)
            )
        }
        Spacer(modifier = Modifier.width(Spacing.md))
        BasicTextField(
            value = value,
            onValueChange = onValueChange,
            textStyle = PreuvelyTypography.body.copy(color = TextPrimary),
            modifier = Modifier.weight(1f),
            decorationBox = { innerTextField ->
                Box {
                    if (value.isEmpty()) {
                        Text(
                            text = stringResource(R.string.add_store_name_placeholder),
                            style = PreuvelyTypography.body,
                            color = TextSecondary.copy(alpha = 0.6f)
                        )
                    }
                    innerTextField()
                }
            }
        )
    }
}

@Composable
private fun PlatformPill(
    platform: Platform,
    selected: Boolean,
    hasLink: Boolean,
    onClick: () -> Unit
) {
    val iconRes = when (platform) {
        Platform.INSTAGRAM -> R.drawable.ic_instagram_color
        Platform.FACEBOOK -> R.drawable.ic_facebook_color
        Platform.TIKTOK -> R.drawable.ic_tiktok_color
        Platform.WEBSITE -> null
        else -> null
    }

    val background = when {
        selected -> Brush.linearGradient(listOf(PrimaryGreen, PrimaryGreen.copy(alpha = 0.8f)))
        hasLink -> Brush.linearGradient(listOf(PrimaryGreen.copy(alpha = 0.15f), PrimaryGreen.copy(alpha = 0.15f)))
        else -> Brush.linearGradient(listOf(Gray6, Gray6))
    }

    val textColor = when {
        selected -> White
        else -> TextPrimary
    }

    val borderColor = when {
        selected -> Color.Transparent
        hasLink -> PrimaryGreen.copy(alpha = 0.3f)
        else -> Color.Transparent
    }

    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(25.dp))
            .background(background)
            .then(
                if (borderColor != Color.Transparent) {
                    Modifier.border(1.dp, borderColor, RoundedCornerShape(25.dp))
                } else Modifier
            )
            .clickable(onClick = onClick)
            .padding(horizontal = 14.dp, vertical = 10.dp)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            if (iconRes != null) {
                Image(
                    painter = painterResource(id = iconRes),
                    contentDescription = platform.displayName,
                    modifier = Modifier.size(20.dp),
                    contentScale = ContentScale.Fit
                )
                Spacer(modifier = Modifier.width(Spacing.sm))
            } else {
                Icon(
                    imageVector = Icons.Default.Language,
                    contentDescription = null,
                    tint = textColor,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(Spacing.sm))
            }
            Text(
                text = platform.displayName,
                style = PreuvelyTypography.subheadlineBold,
                color = textColor
            )
            if (hasLink && !selected) {
                Spacer(modifier = Modifier.width(Spacing.xs))
                Box(
                    modifier = Modifier
                        .size(16.dp)
                        .clip(CircleShape)
                        .background(PrimaryGreen),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Check,
                        contentDescription = null,
                        tint = White,
                        modifier = Modifier.size(10.dp)
                    )
                }
            }
        }
    }
}

@Composable
private fun PlatformLinkInput(
    platform: Platform,
    value: String,
    onValueChange: (String) -> Unit
) {
    val placeholder = when (platform) {
        Platform.INSTAGRAM -> "@storename"
        Platform.TIKTOK -> "@storename"
        Platform.FACEBOOK -> "facebook.com/storename"
        Platform.WEBSITE -> "https://store.com"
        else -> stringResource(R.string.add_store_link)
    }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(Gray6)
            .padding(Spacing.md),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(36.dp)
                .clip(CircleShape)
                .background(PrimaryGreen.copy(alpha = 0.1f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = Icons.Default.Link,
                contentDescription = null,
                tint = PrimaryGreen,
                modifier = Modifier.size(16.dp)
            )
        }
        Spacer(modifier = Modifier.width(Spacing.md))
        BasicTextField(
            value = value,
            onValueChange = onValueChange,
            textStyle = PreuvelyTypography.body.copy(color = TextPrimary),
            modifier = Modifier.weight(1f),
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Uri),
            decorationBox = { innerTextField ->
                Box {
                    if (value.isEmpty()) {
                        Text(
                            text = placeholder,
                            style = PreuvelyTypography.body,
                            color = TextSecondary.copy(alpha = 0.6f)
                        )
                    }
                    innerTextField()
                }
            }
        )
    }
}

@Composable
private fun WhatsAppInput(
    value: String,
    onValueChange: (String) -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(WhatsAppGreen.copy(alpha = 0.08f))
            .border(1.dp, WhatsAppGreen.copy(alpha = 0.2f), RoundedCornerShape(14.dp))
            .padding(Spacing.md),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Image(
            painter = painterResource(id = R.drawable.ic_whatsapp),
            contentDescription = "WhatsApp",
            modifier = Modifier.size(36.dp),
            contentScale = ContentScale.Fit
        )
        Spacer(modifier = Modifier.width(Spacing.md))
        BasicTextField(
            value = value,
            onValueChange = { newValue ->
                // Filter to only allow digits and +
                val filtered = newValue.filter { it.isDigit() || it == '+' }
                onValueChange(filtered)
            },
            textStyle = PreuvelyTypography.body.copy(color = TextPrimary),
            modifier = Modifier.weight(1f),
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone),
            decorationBox = { innerTextField ->
                Box {
                    if (value.isEmpty()) {
                        Text(
                            text = "+213 555 123 456",
                            style = PreuvelyTypography.body,
                            color = TextSecondary.copy(alpha = 0.6f)
                        )
                    }
                    innerTextField()
                }
            }
        )
    }
}

@Composable
private fun CategoryGrid(
    categories: List<Category>,
    selectedCategories: List<Int>,
    onToggleCategory: (Int) -> Unit
) {
    Column(
        verticalArrangement = Arrangement.spacedBy(Spacing.sm)
    ) {
        categories.chunked(2).forEach { rowCategories ->
            Row(
                horizontalArrangement = Arrangement.spacedBy(Spacing.sm),
                modifier = Modifier.fillMaxWidth()
            ) {
                rowCategories.forEach { category ->
                    CategorySelectButton(
                        category = category,
                        selected = selectedCategories.contains(category.id),
                        onClick = { onToggleCategory(category.id) },
                        modifier = Modifier.weight(1f)
                    )
                }
                if (rowCategories.size == 1) {
                    Spacer(modifier = Modifier.weight(1f))
                }
            }
        }
    }
}

@Composable
private fun CategorySelectButton(
    category: Category,
    selected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val background = if (selected) {
        Brush.linearGradient(listOf(PrimaryGreen, PrimaryGreen.copy(alpha = 0.8f)))
    } else {
        Brush.linearGradient(listOf(Gray6, Gray6))
    }

    val borderModifier = if (!selected) {
        Modifier.border(1.dp, Gray5, RoundedCornerShape(12.dp))
    } else {
        Modifier
    }

    Box(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(background)
            .then(borderModifier)
            .clickable(onClick = onClick)
            .padding(horizontal = 14.dp, vertical = 12.dp)
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center,
            modifier = Modifier.fillMaxWidth()
        ) {
            if (selected) {
                Icon(
                    imageVector = Icons.Default.CheckCircle,
                    contentDescription = null,
                    tint = White,
                    modifier = Modifier.size(16.dp)
                )
                Spacer(modifier = Modifier.width(Spacing.xs))
            }
            Text(
                text = category.name,
                style = PreuvelyTypography.subheadline,
                color = if (selected) White else TextPrimary,
                textAlign = TextAlign.Center
            )
        }
    }
}

@Composable
private fun InfoBanner() {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(FacebookBlue.copy(alpha = 0.08f))
            .border(1.dp, FacebookBlue.copy(alpha = 0.15f), RoundedCornerShape(16.dp))
            .padding(Spacing.lg),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(40.dp)
                .clip(CircleShape)
                .background(FacebookBlue.copy(alpha = 0.15f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = Icons.Default.Info,
                contentDescription = null,
                tint = FacebookBlue,
                modifier = Modifier.size(18.dp)
            )
        }
        Spacer(modifier = Modifier.width(Spacing.md))
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = stringResource(R.string.add_store_review_notice_title),
                style = PreuvelyTypography.subheadlineBold,
                color = TextPrimary
            )
            Text(
                text = stringResource(R.string.add_store_review_notice_message),
                style = PreuvelyTypography.caption1,
                color = TextSecondary
            )
        }
    }
}

@Composable
private fun SubmitButton(
    isValid: Boolean,
    isLoading: Boolean,
    onClick: () -> Unit
) {
    val background = if (isValid) {
        Brush.linearGradient(listOf(PrimaryGreen, PrimaryGreen.copy(alpha = 0.8f)))
    } else {
        Brush.linearGradient(listOf(Gray4, Gray4))
    }

    Button(
        onClick = onClick,
        enabled = isValid && !isLoading,
        modifier = Modifier
            .fillMaxWidth()
            .height(56.dp)
            .then(
                if (isValid) {
                    Modifier.shadow(
                        elevation = 10.dp,
                        shape = RoundedCornerShape(16.dp),
                        spotColor = PrimaryGreen.copy(alpha = 0.3f)
                    )
                } else Modifier
            ),
        shape = RoundedCornerShape(16.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = Color.Transparent,
            disabledContainerColor = Color.Transparent
        ),
        contentPadding = PaddingValues(0.dp)
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(background),
            contentAlignment = Alignment.Center
        ) {
            if (isLoading) {
                CircularProgressIndicator(
                    color = White,
                    modifier = Modifier.size(24.dp),
                    strokeWidth = 2.dp
                )
            } else {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Send,
                        contentDescription = null,
                        tint = White,
                        modifier = Modifier.size(18.dp)
                    )
                    Spacer(modifier = Modifier.width(Spacing.sm))
                    Text(
                        text = stringResource(R.string.add_store_submit),
                        style = PreuvelyTypography.headline,
                        color = White
                    )
                }
            }
        }
    }
}

@Composable
private fun ErrorBanner(error: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(ErrorRed.copy(alpha = 0.1f))
            .border(1.dp, ErrorRed.copy(alpha = 0.2f), RoundedCornerShape(12.dp))
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

@Composable
private fun LogoUploadSection(
    logoUri: Uri?,
    onSelectImage: () -> Unit,
    onRemoveImage: () -> Unit
) {
    if (logoUri != null) {
        // Show selected image
        Box(
            modifier = Modifier.fillMaxWidth(),
            contentAlignment = Alignment.Center
        ) {
            Box {
                AsyncImage(
                    model = logoUri,
                    contentDescription = "Store Logo",
                    contentScale = ContentScale.Crop,
                    modifier = Modifier
                        .size(100.dp)
                        .clip(RoundedCornerShape(16.dp))
                        .border(2.dp, PrimaryGreen.copy(alpha = 0.3f), RoundedCornerShape(16.dp))
                )
                // Remove button
                Box(
                    modifier = Modifier
                        .align(Alignment.TopEnd)
                        .offset(x = 8.dp, y = (-8).dp)
                        .size(28.dp)
                        .clip(CircleShape)
                        .background(ErrorRed)
                        .clickable(onClick = onRemoveImage),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Close,
                        contentDescription = "Remove",
                        tint = White,
                        modifier = Modifier.size(16.dp)
                    )
                }
            }
        }
        Spacer(modifier = Modifier.height(Spacing.sm))
        // Change button
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .background(Gray6)
                .clickable(onClick = onSelectImage)
                .padding(Spacing.md),
            contentAlignment = Alignment.Center
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.Edit,
                    contentDescription = null,
                    tint = PrimaryGreen,
                    modifier = Modifier.size(18.dp)
                )
                Spacer(modifier = Modifier.width(Spacing.sm))
                Text(
                    text = stringResource(R.string.add_store_change_logo),
                    style = PreuvelyTypography.subheadline,
                    color = PrimaryGreen
                )
            }
        }
    } else {
        // Upload button
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(120.dp)
                .clip(RoundedCornerShape(16.dp))
                .background(
                    Brush.linearGradient(
                        listOf(
                            PrimaryGreen.copy(alpha = 0.08f),
                            PrimaryGreen.copy(alpha = 0.03f)
                        )
                    )
                )
                .border(
                    width = 2.dp,
                    brush = Brush.linearGradient(
                        listOf(
                            PrimaryGreen.copy(alpha = 0.3f),
                            PrimaryGreen.copy(alpha = 0.1f)
                        )
                    ),
                    shape = RoundedCornerShape(16.dp)
                )
                .clickable(onClick = onSelectImage),
            contentAlignment = Alignment.Center
        ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Box(
                    modifier = Modifier
                        .size(48.dp)
                        .clip(CircleShape)
                        .background(PrimaryGreen.copy(alpha = 0.15f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.AddPhotoAlternate,
                        contentDescription = null,
                        tint = PrimaryGreen,
                        modifier = Modifier.size(24.dp)
                    )
                }
                Spacer(modifier = Modifier.height(Spacing.sm))
                Text(
                    text = stringResource(R.string.add_store_upload_logo),
                    style = PreuvelyTypography.subheadlineBold,
                    color = PrimaryGreen
                )
                Text(
                    text = stringResource(R.string.add_store_logo_hint),
                    style = PreuvelyTypography.caption1,
                    color = TextSecondary
                )
            }
        }
    }
}
