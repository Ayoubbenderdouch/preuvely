package com.preuvely.app.ui.screens.review

import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
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
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.preuvely.app.ui.components.PrimaryButton
import com.preuvely.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WriteReviewSheet(
    storeName: String,
    storeId: Int,
    onDismiss: () -> Unit,
    onSubmit: (rating: Int, content: String, proofs: List<Uri>) -> Unit,
    isSubmitting: Boolean = false,
    error: String? = null
) {
    var rating by remember { mutableIntStateOf(0) }
    var content by remember { mutableStateOf("") }
    var proofImages by remember { mutableStateOf<List<Uri>>(emptyList()) }

    val imagePicker = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        uri?.let {
            if (proofImages.size < 5) {
                proofImages = proofImages + it
            }
        }
    }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
        containerColor = BackgroundPrimary,
        dragHandle = { BottomSheetDefaults.DragHandle() }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(Spacing.screenPadding)
                .padding(bottom = 32.dp)
        ) {
            // Header
            Text(
                text = "Write a Review",
                style = PreuvelyTypography.title3,
                color = TextPrimary,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(Spacing.xs))

            Text(
                text = "for $storeName",
                style = PreuvelyTypography.subheadline,
                color = TextSecondary,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(Spacing.xl))

            // Error
            error?.let { errorMessage ->
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(Spacing.radiusMedium))
                        .background(ErrorRed.copy(alpha = 0.1f))
                        .padding(Spacing.md)
                ) {
                    Text(
                        text = errorMessage,
                        style = PreuvelyTypography.caption1,
                        color = ErrorRed
                    )
                }
                Spacer(modifier = Modifier.height(Spacing.md))
            }

            // Rating Section
            Text(
                text = "Your Rating *",
                style = PreuvelyTypography.subheadlineBold,
                color = TextPrimary
            )

            Spacer(modifier = Modifier.height(Spacing.md))

            // Star Rating Picker
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.Center
            ) {
                (1..5).forEach { star ->
                    Icon(
                        imageVector = if (star <= rating) Icons.Filled.Star else Icons.Filled.StarOutline,
                        contentDescription = "Star $star",
                        tint = if (star <= rating) StarYellow else Gray3,
                        modifier = Modifier
                            .size(48.dp)
                            .clickable { rating = star }
                            .padding(Spacing.xs)
                    )
                }
            }

            Spacer(modifier = Modifier.height(Spacing.xs))

            // Rating label
            Text(
                text = when (rating) {
                    1 -> "Poor"
                    2 -> "Fair"
                    3 -> "Good"
                    4 -> "Very Good"
                    5 -> "Excellent"
                    else -> "Tap to rate"
                },
                style = PreuvelyTypography.caption1,
                color = if (rating > 0) StarYellow else TextSecondary,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(Spacing.xl))

            // Review Content
            Text(
                text = "Your Review (optional)",
                style = PreuvelyTypography.subheadlineBold,
                color = TextPrimary
            )

            Spacer(modifier = Modifier.height(Spacing.md))

            OutlinedTextField(
                value = content,
                onValueChange = { content = it },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(120.dp),
                placeholder = {
                    Text(
                        text = "Share your experience with this store...",
                        style = PreuvelyTypography.body,
                        color = TextTertiary
                    )
                },
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = PrimaryGreen,
                    unfocusedBorderColor = Gray5,
                    focusedContainerColor = Gray6,
                    unfocusedContainerColor = Gray6
                ),
                shape = RoundedCornerShape(Spacing.radiusMedium)
            )

            Spacer(modifier = Modifier.height(Spacing.xl))

            // Proof of Purchase
            Text(
                text = "Proof of Purchase (optional)",
                style = PreuvelyTypography.subheadlineBold,
                color = TextPrimary
            )

            Spacer(modifier = Modifier.height(Spacing.xs))

            Text(
                text = "Add photos to verify your purchase (max 5)",
                style = PreuvelyTypography.caption1,
                color = TextSecondary
            )

            Spacer(modifier = Modifier.height(Spacing.md))

            // Proof Images
            LazyRow(
                horizontalArrangement = Arrangement.spacedBy(Spacing.sm)
            ) {
                // Add button
                if (proofImages.size < 5) {
                    item {
                        Box(
                            modifier = Modifier
                                .size(80.dp)
                                .clip(RoundedCornerShape(Spacing.radiusMedium))
                                .background(Gray6)
                                .border(
                                    width = 1.dp,
                                    color = Gray4,
                                    shape = RoundedCornerShape(Spacing.radiusMedium)
                                )
                                .clickable { imagePicker.launch("image/*") },
                            contentAlignment = Alignment.Center
                        ) {
                            Column(
                                horizontalAlignment = Alignment.CenterHorizontally
                            ) {
                                Icon(
                                    imageVector = Icons.Default.AddAPhoto,
                                    contentDescription = "Add photo",
                                    tint = PrimaryGreen,
                                    modifier = Modifier.size(24.dp)
                                )
                                Spacer(modifier = Modifier.height(Spacing.xxs))
                                Text(
                                    text = "Add",
                                    style = PreuvelyTypography.caption2,
                                    color = PrimaryGreen
                                )
                            }
                        }
                    }
                }

                // Existing images
                itemsIndexed(proofImages) { index, uri ->
                    Box(
                        modifier = Modifier
                            .size(80.dp)
                            .clip(RoundedCornerShape(Spacing.radiusMedium))
                    ) {
                        AsyncImage(
                            model = uri,
                            contentDescription = "Proof ${index + 1}",
                            contentScale = ContentScale.Crop,
                            modifier = Modifier.fillMaxSize()
                        )

                        // Remove button
                        Box(
                            modifier = Modifier
                                .align(Alignment.TopEnd)
                                .offset(x = 4.dp, y = (-4).dp)
                                .size(24.dp)
                                .clip(CircleShape)
                                .background(ErrorRed)
                                .clickable {
                                    proofImages = proofImages.toMutableList().apply {
                                        removeAt(index)
                                    }
                                },
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = Icons.Default.Close,
                                contentDescription = "Remove",
                                tint = White,
                                modifier = Modifier.size(14.dp)
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(Spacing.xxl))

            // Info Banner
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(Spacing.radiusMedium))
                    .background(FacebookBlue.copy(alpha = 0.08f))
                    .border(
                        width = 1.dp,
                        color = FacebookBlue.copy(alpha = 0.15f),
                        shape = RoundedCornerShape(Spacing.radiusMedium)
                    )
                    .padding(Spacing.md),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Default.Info,
                    contentDescription = null,
                    tint = FacebookBlue,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(Spacing.sm))
                Text(
                    text = "Your review will be moderated before appearing publicly",
                    style = PreuvelyTypography.caption1,
                    color = TextSecondary
                )
            }

            Spacer(modifier = Modifier.height(Spacing.xl))

            // Submit Button
            PrimaryButton(
                text = "Submit Review",
                onClick = { onSubmit(rating, content, proofImages) },
                enabled = rating > 0,
                isLoading = isSubmitting,
                icon = Icons.Default.Send
            )
        }
    }
}
