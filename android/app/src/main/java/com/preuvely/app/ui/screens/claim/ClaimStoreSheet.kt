package com.preuvely.app.ui.screens.claim

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
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.preuvely.app.ui.components.PrimaryButton
import com.preuvely.app.ui.components.PreuvelyTextField
import com.preuvely.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ClaimStoreSheet(
    storeName: String,
    storeId: Int,
    onDismiss: () -> Unit,
    onSubmit: (message: String, proofs: List<Uri>) -> Unit,
    isSubmitting: Boolean = false,
    error: String? = null
) {
    var message by remember { mutableStateOf("") }
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
            // Header Icon
            Box(
                modifier = Modifier
                    .fillMaxWidth(),
                contentAlignment = Alignment.Center
            ) {
                Box(
                    modifier = Modifier
                        .size(70.dp)
                        .clip(CircleShape)
                        .background(PrimaryGreen.copy(alpha = 0.1f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Verified,
                        contentDescription = null,
                        tint = PrimaryGreen,
                        modifier = Modifier.size(32.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(Spacing.lg))

            // Header
            Text(
                text = "Claim This Store",
                style = PreuvelyTypography.title3,
                color = TextPrimary,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(Spacing.xs))

            Text(
                text = "Verify that you own $storeName",
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

            // Message
            Text(
                text = "Message (optional)",
                style = PreuvelyTypography.subheadlineBold,
                color = TextPrimary
            )

            Spacer(modifier = Modifier.height(Spacing.md))

            OutlinedTextField(
                value = message,
                onValueChange = { message = it },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(100.dp),
                placeholder = {
                    Text(
                        text = "Tell us why you're claiming this store...",
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

            // Proof of Ownership
            Text(
                text = "Proof of Ownership *",
                style = PreuvelyTypography.subheadlineBold,
                color = TextPrimary
            )

            Spacer(modifier = Modifier.height(Spacing.xs))

            Text(
                text = "Upload business documents, screenshots from your store dashboard, or other proof",
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
                                .size(100.dp)
                                .clip(RoundedCornerShape(Spacing.radiusMedium))
                                .background(Gray6)
                                .border(
                                    width = 2.dp,
                                    color = if (proofImages.isEmpty()) PrimaryGreen else Gray4,
                                    shape = RoundedCornerShape(Spacing.radiusMedium)
                                )
                                .clickable { imagePicker.launch("image/*") },
                            contentAlignment = Alignment.Center
                        ) {
                            Column(
                                horizontalAlignment = Alignment.CenterHorizontally
                            ) {
                                Icon(
                                    imageVector = Icons.Default.CloudUpload,
                                    contentDescription = "Upload",
                                    tint = if (proofImages.isEmpty()) PrimaryGreen else Gray3,
                                    modifier = Modifier.size(32.dp)
                                )
                                Spacer(modifier = Modifier.height(Spacing.xs))
                                Text(
                                    text = "Upload",
                                    style = PreuvelyTypography.caption1,
                                    color = if (proofImages.isEmpty()) PrimaryGreen else Gray3
                                )
                            }
                        }
                    }
                }

                // Existing images
                itemsIndexed(proofImages) { index, uri ->
                    Box(
                        modifier = Modifier
                            .size(100.dp)
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
                                .size(28.dp)
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
                                modifier = Modifier.size(16.dp)
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(Spacing.xl))

            // Requirements list
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(Spacing.radiusMedium))
                    .background(WarningOrange.copy(alpha = 0.08f))
                    .padding(Spacing.md)
            ) {
                Text(
                    text = "What we accept as proof:",
                    style = PreuvelyTypography.subheadlineBold,
                    color = TextPrimary
                )
                Spacer(modifier = Modifier.height(Spacing.sm))

                RequirementItem("Business registration documents")
                RequirementItem("Screenshot from your store admin panel")
                RequirementItem("Verified social media screenshots")
                RequirementItem("Payment/invoice records")
            }

            Spacer(modifier = Modifier.height(Spacing.xl))

            // Submit Button
            PrimaryButton(
                text = "Submit Claim",
                onClick = { onSubmit(message, proofImages) },
                enabled = proofImages.isNotEmpty(),
                isLoading = isSubmitting,
                icon = Icons.Default.Send
            )
        }
    }
}

@Composable
private fun RequirementItem(text: String) {
    Row(
        modifier = Modifier.padding(vertical = Spacing.xxs),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = Icons.Default.Check,
            contentDescription = null,
            tint = SuccessGreen,
            modifier = Modifier.size(16.dp)
        )
        Spacer(modifier = Modifier.width(Spacing.sm))
        Text(
            text = text,
            style = PreuvelyTypography.caption1,
            color = TextSecondary
        )
    }
}
