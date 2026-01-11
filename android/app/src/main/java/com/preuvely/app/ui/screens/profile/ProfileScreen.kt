package com.preuvely.app.ui.screens.profile

import android.app.Activity
import android.content.Intent
import android.graphics.BitmapFactory
import android.net.Uri
import android.util.Base64
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import coil.compose.AsyncImage
import com.preuvely.app.R
import com.preuvely.app.data.models.ClaimStatus
import com.preuvely.app.data.models.ReviewStatus
import com.preuvely.app.ui.components.*
import com.preuvely.app.ui.theme.*
import com.preuvely.app.utils.AppLanguage
import com.preuvely.app.utils.LocalizationManager

@Composable
fun ProfileScreen(
    onNavigateToAuth: () -> Unit,
    onNavigateToStore: (String) -> Unit,
    onNavigateToUser: (Int) -> Unit,
    onNavigateToEditStore: (Int) -> Unit,
    onNavigateToNotifications: () -> Unit,
    viewModel: ProfileViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Box(modifier = Modifier.fillMaxSize()) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(BackgroundSecondary)
                .statusBarsPadding()
                .verticalScroll(rememberScrollState())
                .padding(bottom = 100.dp)
        ) {
            Spacer(modifier = Modifier.height(Spacing.md))

            if (uiState.isAuthenticated && uiState.user != null) {
                AuthenticatedContent(
                    uiState = uiState,
                    onEditProfile = { viewModel.showEditProfileSheet() },
                    onNavigateToStore = onNavigateToStore,
                    onNavigateToNotifications = onNavigateToNotifications,
                    onResendEmail = { viewModel.resendVerificationEmail() },
                    onLogout = { viewModel.logout { } }
                )
            } else {
                GuestContent(onSignIn = onNavigateToAuth)
            }
        }

        // Edit Profile Sheet
        if (uiState.showEditProfileSheet && uiState.user != null) {
            EditProfileSheet(
                user = uiState.user!!,
                uiState = uiState.editProfileState,
                onDismiss = { viewModel.hideEditProfileSheet() },
                onSave = { name, phone -> viewModel.updateProfile(name, phone) },
                onAvatarSelected = { uri -> viewModel.uploadAvatar(uri) }
            )
        }
    }
}

@Composable
private fun GuestContent(onSignIn: () -> Unit) {
    Column(modifier = Modifier.padding(Spacing.screenPadding)) {
        // Guest Header Card
        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(24.dp),
            colors = CardDefaults.cardColors(containerColor = CardBackground)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = Spacing.xl),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Avatar placeholder
                Box(
                    modifier = Modifier
                        .size(90.dp)
                        .clip(CircleShape)
                        .background(
                            Brush.linearGradient(listOf(PrimaryGreen, PrimaryGreenLight))
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Person,
                        contentDescription = null,
                        tint = White,
                        modifier = Modifier.size(36.dp)
                    )
                }

                Spacer(modifier = Modifier.height(Spacing.md))

                Text(
                    text = stringResource(R.string.profile_guest),
                    style = PreuvelyTypography.title3,
                    color = TextPrimary
                )

                Text(
                    text = stringResource(R.string.profile_sign_in_prompt),
                    style = PreuvelyTypography.subheadline,
                    color = TextSecondary
                )

                Spacer(modifier = Modifier.height(Spacing.lg))

                PrimaryButton(
                    text = stringResource(R.string.profile_sign_in),
                    onClick = onSignIn,
                    icon = Icons.Default.ArrowForward,
                    modifier = Modifier.padding(horizontal = Spacing.xl)
                )
            }
        }

        Spacer(modifier = Modifier.height(Spacing.xl))

        // Settings
        SettingsSection()

        Spacer(modifier = Modifier.height(Spacing.xl))

        // Social Media
        SocialMediaSection()
    }
}

@Composable
private fun AuthenticatedContent(
    uiState: ProfileUiState,
    onEditProfile: () -> Unit,
    onNavigateToStore: (String) -> Unit,
    onNavigateToNotifications: () -> Unit,
    onResendEmail: () -> Unit,
    onLogout: () -> Unit
) {
    val user = uiState.user!!

    Column(modifier = Modifier.padding(Spacing.screenPadding)) {
        // User Card
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .clickable(onClick = onEditProfile),
            shape = RoundedCornerShape(20.dp),
            colors = CardDefaults.cardColors(containerColor = CardBackground)
        ) {
            Row(
                modifier = Modifier.padding(18.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Avatar
                Box(
                    modifier = Modifier
                        .size(56.dp)
                        .clip(CircleShape)
                        .background(
                            Brush.linearGradient(listOf(PrimaryGreen, PrimaryGreenLight))
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    if (!user.avatar.isNullOrBlank()) {
                        // Handle base64 data URL
                        if (user.avatar!!.startsWith("data:image")) {
                            val base64Data = user.avatar!!.substringAfter("base64,")
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
                                    contentDescription = user.name,
                                    contentScale = ContentScale.Crop,
                                    modifier = Modifier.fillMaxSize()
                                )
                            }
                        } else {
                            AsyncImage(
                                model = user.avatar,
                                contentDescription = user.name,
                                contentScale = ContentScale.Crop,
                                modifier = Modifier.fillMaxSize()
                            )
                        }
                    } else {
                        Text(
                            text = user.initials,
                            style = PreuvelyTypography.headline,
                            color = White
                        )
                    }
                }

                Spacer(modifier = Modifier.width(Spacing.md))

                Column(modifier = Modifier.weight(1f)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            text = user.name,
                            style = PreuvelyTypography.headline,
                            color = TextPrimary
                        )
                        Spacer(modifier = Modifier.width(Spacing.xs))
                        Text(
                            text = stringResource(R.string.profile_edit),
                            style = PreuvelyTypography.caption1,
                            color = TextSecondary
                        )
                    }
                    Text(
                        text = user.displayEmail,
                        style = PreuvelyTypography.subheadline,
                        color = TextSecondary
                    )
                }

                Box(
                    modifier = Modifier
                        .size(32.dp)
                        .clip(CircleShape)
                        .background(PrimaryGreen.copy(alpha = 0.1f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.ChevronRight,
                        contentDescription = null,
                        tint = PrimaryGreen,
                        modifier = Modifier.size(20.dp)
                    )
                }
            }
        }

        // Email Verification Banner
        if (!user.emailVerified && user.email != null) {
            Spacer(modifier = Modifier.height(Spacing.md))
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(
                    containerColor = WarningOrange.copy(alpha = 0.08f)
                )
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .border(
                            width = 1.dp,
                            color = WarningOrange.copy(alpha = 0.3f),
                            shape = RoundedCornerShape(16.dp)
                        )
                        .padding(Spacing.lg),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = Icons.Default.MarkEmailUnread,
                        contentDescription = null,
                        tint = WarningOrange,
                        modifier = Modifier.size(24.dp)
                    )
                    Spacer(modifier = Modifier.width(Spacing.md))
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = stringResource(R.string.profile_verify_email),
                            style = PreuvelyTypography.subheadlineBold,
                            color = TextPrimary
                        )
                        Text(
                            text = stringResource(R.string.profile_verify_email_message),
                            style = PreuvelyTypography.caption1,
                            color = TextSecondary
                        )
                    }
                    TextButton(
                        onClick = onResendEmail,
                        enabled = !uiState.isResendingEmail
                    ) {
                        if (uiState.isResendingEmail) {
                            CircularProgressIndicator(
                                modifier = Modifier.size(16.dp),
                                color = WarningOrange
                            )
                        } else {
                            Text(
                                text = stringResource(R.string.profile_resend_email),
                                style = PreuvelyTypography.subheadlineBold,
                                color = WarningOrange
                            )
                        }
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(Spacing.xl))

        // My Reviews Section
        SectionHeader(title = stringResource(R.string.profile_my_reviews), modifier = Modifier.padding(horizontal = 0.dp))
        Spacer(modifier = Modifier.height(Spacing.md))

        if (uiState.reviews.isEmpty()) {
            EmptySection(
                icon = Icons.Outlined.RateReview,
                message = stringResource(R.string.profile_no_reviews)
            )
        } else {
            uiState.reviews.forEach { review ->
                ReviewItem(review = review)
                Spacer(modifier = Modifier.height(Spacing.sm))
            }
        }

        Spacer(modifier = Modifier.height(Spacing.xl))

        // My Claims Section
        SectionHeader(title = stringResource(R.string.profile_my_claims), modifier = Modifier.padding(horizontal = 0.dp))
        Spacer(modifier = Modifier.height(Spacing.md))

        if (uiState.claims.isEmpty()) {
            EmptySection(
                icon = Icons.Outlined.Store,
                message = stringResource(R.string.profile_no_claims)
            )
        } else {
            uiState.claims.forEach { claim ->
                ClaimItem(claim = claim)
                Spacer(modifier = Modifier.height(Spacing.sm))
            }
        }

        Spacer(modifier = Modifier.height(Spacing.xl))

        // Settings
        SettingsSection()

        Spacer(modifier = Modifier.height(Spacing.xl))

        // Social Media
        SocialMediaSection()

        Spacer(modifier = Modifier.height(Spacing.xl))

        // Logout Button
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(14.dp))
                .background(ErrorRed.copy(alpha = 0.08f))
                .border(
                    width = 1.dp,
                    color = ErrorRed.copy(alpha = 0.2f),
                    shape = RoundedCornerShape(14.dp)
                )
                .clickable(onClick = onLogout)
                .padding(14.dp),
            contentAlignment = Alignment.Center
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.Logout,
                    contentDescription = null,
                    tint = ErrorRed,
                    modifier = Modifier.size(16.dp)
                )
                Spacer(modifier = Modifier.width(Spacing.sm))
                Text(
                    text = stringResource(R.string.profile_sign_out),
                    style = PreuvelyTypography.body,
                    color = ErrorRed
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun SettingsSection() {
    val context = LocalContext.current
    var showLanguagePicker by remember { mutableStateOf(false) }
    var currentLanguage by remember { mutableStateOf(LocalizationManager.getSavedLanguage(context)) }

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = CardBackground)
    ) {
        Column {
            SettingsRow(
                icon = Icons.Outlined.Language,
                title = stringResource(R.string.profile_language),
                value = currentLanguage.nativeName,
                onClick = { showLanguagePicker = true }
            )
            Divider(
                modifier = Modifier.padding(start = 66.dp),
                color = Divider
            )
            SettingsRow(
                icon = Icons.Outlined.Help,
                title = stringResource(R.string.profile_support),
                onClick = { }
            )
            Divider(
                modifier = Modifier.padding(start = 66.dp),
                color = Divider
            )
            SettingsRow(
                icon = Icons.Outlined.Description,
                title = stringResource(R.string.profile_terms),
                onClick = { }
            )
            Divider(
                modifier = Modifier.padding(start = 66.dp),
                color = Divider
            )
            SettingsRow(
                icon = Icons.Outlined.PrivacyTip,
                title = stringResource(R.string.profile_privacy),
                onClick = { }
            )
        }
    }

    // Language Picker Bottom Sheet
    if (showLanguagePicker) {
        ModalBottomSheet(
            onDismissRequest = { showLanguagePicker = false },
            containerColor = CardBackground,
            shape = RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp)
        ) {
            LanguagePickerContent(
                currentLanguage = currentLanguage,
                onLanguageSelected = { language ->
                    currentLanguage = language
                    LocalizationManager.saveLanguage(context, language)
                    showLanguagePicker = false
                    // Restart activity to apply language change
                    (context as? Activity)?.let { activity ->
                        val intent = activity.intent
                        activity.finish()
                        activity.startActivity(intent)
                    }
                }
            )
        }
    }
}

@Composable
private fun LanguagePickerContent(
    currentLanguage: AppLanguage,
    onLanguageSelected: (AppLanguage) -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = Spacing.screenPadding)
            .padding(bottom = 32.dp)
    ) {
        Text(
            text = stringResource(R.string.select_language),
            style = PreuvelyTypography.title3,
            color = TextPrimary,
            modifier = Modifier.padding(bottom = Spacing.lg)
        )

        AppLanguage.entries.forEach { language ->
            LanguageOption(
                language = language,
                isSelected = language == currentLanguage,
                onClick = { onLanguageSelected(language) }
            )
            if (language != AppLanguage.entries.last()) {
                Spacer(modifier = Modifier.height(Spacing.sm))
            }
        }
    }
}

@Composable
private fun LanguageOption(
    language: AppLanguage,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(
            containerColor = if (isSelected) PrimaryGreen.copy(alpha = 0.1f) else Gray6
        ),
        border = if (isSelected) androidx.compose.foundation.BorderStroke(1.5.dp, PrimaryGreen) else null
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(Spacing.lg),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                // Flag Image
                Image(
                    painter = painterResource(id = language.flagResId),
                    contentDescription = language.displayName,
                    modifier = Modifier
                        .size(36.dp)
                        .clip(CircleShape),
                    contentScale = ContentScale.Crop
                )
                Spacer(modifier = Modifier.width(Spacing.md))
                Column {
                    Text(
                        text = language.nativeName,
                        style = PreuvelyTypography.bodyBold,
                        color = if (isSelected) PrimaryGreen else TextPrimary
                    )
                    Text(
                        text = language.displayName,
                        style = PreuvelyTypography.caption1,
                        color = TextSecondary
                    )
                }
            }
            if (isSelected) {
                Icon(
                    imageVector = Icons.Filled.CheckCircle,
                    contentDescription = null,
                    tint = PrimaryGreen,
                    modifier = Modifier.size(24.dp)
                )
            }
        }
    }
}

@Composable
private fun SettingsRow(
    icon: ImageVector,
    title: String,
    value: String? = null,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(horizontal = Spacing.lg, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(36.dp)
                .clip(RoundedCornerShape(Spacing.radiusSmall))
                .background(PrimaryGreen.copy(alpha = 0.1f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = PrimaryGreen,
                modifier = Modifier.size(16.dp)
            )
        }
        Spacer(modifier = Modifier.width(Spacing.md))
        Text(
            text = title,
            style = PreuvelyTypography.body,
            color = TextPrimary,
            modifier = Modifier.weight(1f)
        )
        if (value != null) {
            Text(
                text = value,
                style = PreuvelyTypography.caption1,
                color = TextSecondary
            )
            Spacer(modifier = Modifier.width(Spacing.sm))
        }
        Icon(
            imageVector = Icons.Default.ChevronRight,
            contentDescription = null,
            tint = Gray3,
            modifier = Modifier.size(12.dp)
        )
    }
}

@Composable
private fun EmptySection(
    icon: ImageVector,
    message: String
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(Spacing.radiusMedium))
            .background(CardBackground)
            .padding(Spacing.lg),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = Gray3,
            modifier = Modifier.size(24.dp)
        )
        Spacer(modifier = Modifier.width(Spacing.md))
        Text(
            text = message,
            style = PreuvelyTypography.subheadline,
            color = TextSecondary
        )
    }
}

@Composable
private fun ReviewItem(review: com.preuvely.app.data.models.Review) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(Spacing.radiusMedium))
            .background(CardBackground)
            .padding(Spacing.md),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(40.dp)
                .clip(CircleShape)
                .background(StarYellow.copy(alpha = 0.1f)),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "${review.stars}",
                style = PreuvelyTypography.headline,
                color = StarYellow
            )
        }
        Spacer(modifier = Modifier.width(Spacing.md))
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = review.store?.name ?: "Store",
                style = PreuvelyTypography.subheadlineBold,
                color = TextPrimary
            )
            StarRating(rating = review.stars, size = BadgeSize.SMALL)
        }
        StatusBadge(status = review.status)
    }
}

@Composable
private fun ClaimItem(claim: com.preuvely.app.data.models.Claim) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(Spacing.radiusMedium))
            .background(CardBackground)
            .padding(Spacing.md),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = claim.displayStoreName,
                style = PreuvelyTypography.subheadlineBold,
                color = TextPrimary
            )
            Text(
                text = claim.formattedDate,
                style = PreuvelyTypography.caption1,
                color = TextSecondary
            )
        }
        ClaimStatusBadge(status = claim.status)
    }
}

@Composable
private fun ClaimStatusBadge(status: ClaimStatus) {
    val pendingText = stringResource(R.string.profile_claim_pending)
    val approvedText = stringResource(R.string.profile_claim_approved)
    val rejectedText = stringResource(R.string.profile_claim_rejected)

    val (backgroundColor, textColor, text) = when (status) {
        ClaimStatus.PENDING -> Triple(WarningOrange.copy(alpha = 0.1f), WarningOrange, pendingText)
        ClaimStatus.APPROVED -> Triple(SuccessGreen.copy(alpha = 0.1f), SuccessGreen, approvedText)
        ClaimStatus.REJECTED -> Triple(ErrorRed.copy(alpha = 0.1f), ErrorRed, rejectedText)
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

@Composable
private fun SocialMediaSection() {
    val context = LocalContext.current

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = CardBackground)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(Spacing.lg),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Header
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Favorite,
                    contentDescription = null,
                    tint = PrimaryGreen,
                    modifier = Modifier.size(14.dp)
                )
                Spacer(modifier = Modifier.width(Spacing.sm))
                Text(
                    text = stringResource(R.string.profile_follow_us),
                    style = PreuvelyTypography.subheadline,
                    color = TextSecondary
                )
            }

            Spacer(modifier = Modifier.height(Spacing.lg))

            // Social Media Buttons
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                SocialMediaButton(
                    iconRes = R.drawable.ic_instagram_color,
                    contentDescription = "Instagram",
                    onClick = {
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://instagram.com/preuvely"))
                        context.startActivity(intent)
                    }
                )
                Spacer(modifier = Modifier.width(Spacing.lg))
                SocialMediaButton(
                    iconRes = R.drawable.ic_facebook_color,
                    contentDescription = "Facebook",
                    onClick = {
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://facebook.com/preuvely"))
                        context.startActivity(intent)
                    }
                )
                Spacer(modifier = Modifier.width(Spacing.lg))
                SocialMediaButton(
                    iconRes = R.drawable.ic_tiktok_color,
                    contentDescription = "TikTok",
                    onClick = {
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://tiktok.com/@preuvely"))
                        context.startActivity(intent)
                    }
                )
                Spacer(modifier = Modifier.width(Spacing.lg))
                SocialMediaButton(
                    iconRes = R.drawable.ic_whatsapp_color,
                    contentDescription = "WhatsApp",
                    onClick = {
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://wa.me/213555123456"))
                        context.startActivity(intent)
                    }
                )
            }
        }
    }
}

@Composable
private fun SocialMediaButton(
    iconRes: Int,
    contentDescription: String,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .size(52.dp)
            .clip(CircleShape)
            .background(
                Brush.linearGradient(
                    colors = listOf(Gray6, Gray5)
                )
            )
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Image(
            painter = painterResource(id = iconRes),
            contentDescription = contentDescription,
            modifier = Modifier.size(26.dp),
            contentScale = ContentScale.Fit
        )
    }
}
