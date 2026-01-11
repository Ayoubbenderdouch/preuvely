package com.preuvely.app.ui.screens.report

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
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.preuvely.app.data.models.ReportReason
import com.preuvely.app.ui.components.PrimaryButton
import com.preuvely.app.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ReportStoreSheet(
    storeName: String,
    storeId: Int,
    onDismiss: () -> Unit,
    onSubmit: (reason: ReportReason, details: String) -> Unit,
    isSubmitting: Boolean = false,
    error: String? = null
) {
    var selectedReason by remember { mutableStateOf<ReportReason?>(null) }
    var details by remember { mutableStateOf("") }

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
                modifier = Modifier.fillMaxWidth(),
                contentAlignment = Alignment.Center
            ) {
                Box(
                    modifier = Modifier
                        .size(70.dp)
                        .clip(CircleShape)
                        .background(ErrorRed.copy(alpha = 0.1f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Flag,
                        contentDescription = null,
                        tint = ErrorRed,
                        modifier = Modifier.size(32.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(Spacing.lg))

            // Header
            Text(
                text = "Report Store",
                style = PreuvelyTypography.title3,
                color = TextPrimary,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(Spacing.xs))

            Text(
                text = "Help us keep Preuvely safe by reporting issues with $storeName",
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

            // Reason Selection
            Text(
                text = "Reason for reporting *",
                style = PreuvelyTypography.subheadlineBold,
                color = TextPrimary
            )

            Spacer(modifier = Modifier.height(Spacing.md))

            ReportReason.entries.forEach { reason ->
                ReasonOption(
                    reason = reason,
                    isSelected = selectedReason == reason,
                    onClick = { selectedReason = reason }
                )
                Spacer(modifier = Modifier.height(Spacing.sm))
            }

            Spacer(modifier = Modifier.height(Spacing.lg))

            // Details
            Text(
                text = "Additional Details (optional)",
                style = PreuvelyTypography.subheadlineBold,
                color = TextPrimary
            )

            Spacer(modifier = Modifier.height(Spacing.md))

            OutlinedTextField(
                value = details,
                onValueChange = { details = it },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(100.dp),
                placeholder = {
                    Text(
                        text = "Provide more information about the issue...",
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

            // Submit Button
            PrimaryButton(
                text = "Submit Report",
                onClick = {
                    selectedReason?.let { reason ->
                        onSubmit(reason, details)
                    }
                },
                enabled = selectedReason != null,
                isLoading = isSubmitting,
                icon = Icons.Default.Send
            )
        }
    }
}

@Composable
private fun ReasonOption(
    reason: ReportReason,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(Spacing.radiusMedium))
            .background(if (isSelected) PrimaryGreen.copy(alpha = 0.1f) else CardBackground)
            .border(
                width = if (isSelected) 1.5.dp else 1.dp,
                color = if (isSelected) PrimaryGreen else Gray5,
                shape = RoundedCornerShape(Spacing.radiusMedium)
            )
            .clickable(onClick = onClick)
            .padding(Spacing.md),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(22.dp)
                .clip(CircleShape)
                .border(
                    width = 2.dp,
                    color = if (isSelected) PrimaryGreen else Gray4,
                    shape = CircleShape
                ),
            contentAlignment = Alignment.Center
        ) {
            if (isSelected) {
                Box(
                    modifier = Modifier
                        .size(12.dp)
                        .clip(CircleShape)
                        .background(PrimaryGreen)
                )
            }
        }

        Spacer(modifier = Modifier.width(Spacing.md))

        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = reason.displayName,
                style = PreuvelyTypography.subheadlineBold,
                color = TextPrimary
            )
            Text(
                text = reason.description,
                style = PreuvelyTypography.caption1,
                color = TextSecondary
            )
        }
    }
}
