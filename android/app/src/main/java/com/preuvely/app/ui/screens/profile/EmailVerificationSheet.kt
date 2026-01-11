package com.preuvely.app.ui.screens.profile

import androidx.compose.animation.animateColorAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
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
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.preuvely.app.ui.components.PrimaryButton
import com.preuvely.app.ui.theme.*
import kotlinx.coroutines.delay

data class EmailVerificationUiState(
    val digits: List<String> = List(6) { "" },
    val isLoading: Boolean = false,
    val isResending: Boolean = false,
    val errorMessage: String? = null,
    val resendCooldown: Int = 0,
    val isVerified: Boolean = false
) {
    val isCodeComplete: Boolean
        get() = digits.all { it.isNotEmpty() }

    val code: String
        get() = digits.joinToString("")
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EmailVerificationSheet(
    email: String,
    onDismiss: () -> Unit,
    onVerify: (String) -> Unit,
    onResendCode: () -> Unit,
    uiState: EmailVerificationUiState,
    onDigitsChange: (List<String>) -> Unit
) {
    val focusRequesters = remember { List(6) { FocusRequester() } }
    var focusedIndex by remember { mutableIntStateOf(0) }

    LaunchedEffect(Unit) {
        focusRequesters[0].requestFocus()
    }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
        containerColor = BackgroundSecondary,
        dragHandle = { BottomSheetDefaults.DragHandle() }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(Spacing.screenPadding)
                .padding(bottom = 32.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Header Icon
            Box(
                modifier = Modifier
                    .size(80.dp)
                    .clip(CircleShape)
                    .background(
                        Brush.linearGradient(
                            colors = listOf(
                                PrimaryGreen.copy(alpha = 0.2f),
                                PrimaryGreen.copy(alpha = 0.05f)
                            )
                        )
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.MarkEmailRead,
                    contentDescription = null,
                    tint = PrimaryGreen,
                    modifier = Modifier.size(36.dp)
                )
            }

            Spacer(modifier = Modifier.height(Spacing.lg))

            // Title
            Text(
                text = "Verify Your Email",
                style = PreuvelyTypography.title2,
                color = TextPrimary,
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(Spacing.sm))

            // Subtitle
            Text(
                text = "Enter the 6-digit code sent to",
                style = PreuvelyTypography.subheadline,
                color = TextSecondary,
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(Spacing.xs))

            Text(
                text = email,
                style = PreuvelyTypography.subheadlineBold,
                color = TextPrimary,
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(Spacing.xxl))

            // OTP Input Fields
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp, Alignment.CenterHorizontally)
            ) {
                uiState.digits.forEachIndexed { index, digit ->
                    OTPDigitField(
                        digit = digit,
                        isFocused = focusedIndex == index,
                        focusRequester = focusRequesters[index],
                        onFocusChange = { isFocused ->
                            if (isFocused) focusedIndex = index
                        },
                        onDigitChange = { newDigit ->
                            handleDigitChange(
                                index = index,
                                newValue = newDigit,
                                currentDigits = uiState.digits,
                                onDigitsChange = onDigitsChange,
                                focusRequesters = focusRequesters,
                                onFocusChange = { focusedIndex = it }
                            )
                        },
                        onBackspace = {
                            if (digit.isEmpty() && index > 0) {
                                focusRequesters[index - 1].requestFocus()
                                focusedIndex = index - 1
                            }
                        }
                    )
                }
            }

            Spacer(modifier = Modifier.height(Spacing.lg))

            // Error message
            if (uiState.errorMessage != null) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(Spacing.radiusMedium))
                        .background(ErrorRed.copy(alpha = 0.1f))
                        .padding(Spacing.md),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Error,
                        contentDescription = null,
                        tint = ErrorRed,
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(Spacing.sm))
                    Text(
                        text = uiState.errorMessage,
                        style = PreuvelyTypography.caption1,
                        color = ErrorRed
                    )
                }
                Spacer(modifier = Modifier.height(Spacing.lg))
            }

            // Verify Button
            PrimaryButton(
                text = "Verify Email",
                onClick = { onVerify(uiState.code) },
                enabled = uiState.isCodeComplete && !uiState.isLoading,
                isLoading = uiState.isLoading,
                icon = Icons.Default.Verified,
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(Spacing.xl))

            // Resend code section
            Text(
                text = "Didn't receive the code?",
                style = PreuvelyTypography.caption1,
                color = TextSecondary
            )

            Spacer(modifier = Modifier.height(Spacing.sm))

            TextButton(
                onClick = onResendCode,
                enabled = uiState.resendCooldown == 0 && !uiState.isResending
            ) {
                if (uiState.isResending) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(16.dp),
                        color = PrimaryGreen,
                        strokeWidth = 2.dp
                    )
                    Spacer(modifier = Modifier.width(Spacing.sm))
                    Text(
                        text = "Sending...",
                        style = PreuvelyTypography.subheadlineBold,
                        color = TextSecondary
                    )
                } else {
                    Icon(
                        imageVector = Icons.Default.Refresh,
                        contentDescription = null,
                        tint = if (uiState.resendCooldown > 0) TextSecondary else PrimaryGreen,
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(Spacing.xs))
                    Text(
                        text = if (uiState.resendCooldown > 0) {
                            "Resend in ${uiState.resendCooldown}s"
                        } else {
                            "Resend Code"
                        },
                        style = PreuvelyTypography.subheadlineBold,
                        color = if (uiState.resendCooldown > 0) TextSecondary else PrimaryGreen
                    )
                }
            }

            Spacer(modifier = Modifier.height(Spacing.xl))

            // Info footer
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Schedule,
                    contentDescription = null,
                    tint = TextSecondary,
                    modifier = Modifier.size(14.dp)
                )
                Spacer(modifier = Modifier.width(Spacing.xs))
                Text(
                    text = "Code expires in 15 minutes",
                    style = PreuvelyTypography.caption1,
                    color = TextSecondary
                )
            }
        }
    }
}

@Composable
private fun OTPDigitField(
    digit: String,
    isFocused: Boolean,
    focusRequester: FocusRequester,
    onFocusChange: (Boolean) -> Unit,
    onDigitChange: (String) -> Unit,
    onBackspace: () -> Unit
) {
    val borderColor by animateColorAsState(
        targetValue = if (isFocused) PrimaryGreen else Gray4,
        label = "borderColor"
    )

    val shadowElevation = if (isFocused) 8.dp else 2.dp

    Box(
        modifier = Modifier
            .size(48.dp, 56.dp)
            .shadow(
                elevation = shadowElevation,
                shape = RoundedCornerShape(Spacing.radiusMedium),
                spotColor = if (isFocused) PrimaryGreen.copy(alpha = 0.3f) else CardShadow
            )
            .clip(RoundedCornerShape(Spacing.radiusMedium))
            .background(CardBackground)
            .border(
                width = if (isFocused) 2.dp else 1.dp,
                color = borderColor,
                shape = RoundedCornerShape(Spacing.radiusMedium)
            ),
        contentAlignment = Alignment.Center
    ) {
        BasicTextField(
            value = digit,
            onValueChange = { newValue ->
                if (newValue.isEmpty()) {
                    onDigitChange("")
                    onBackspace()
                } else {
                    // Only accept numeric input
                    val filtered = newValue.filter { it.isDigit() }
                    if (filtered.isNotEmpty()) {
                        onDigitChange(filtered)
                    }
                }
            },
            modifier = Modifier
                .fillMaxSize()
                .focusRequester(focusRequester)
                .onFocusChanged { onFocusChange(it.isFocused) },
            textStyle = PreuvelyTypography.title1.copy(
                textAlign = TextAlign.Center,
                color = TextPrimary
            ),
            keyboardOptions = KeyboardOptions(
                keyboardType = KeyboardType.NumberPassword
            ),
            singleLine = true,
            cursorBrush = SolidColor(PrimaryGreen),
            decorationBox = { innerTextField ->
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    innerTextField()
                }
            }
        )
    }
}

private fun handleDigitChange(
    index: Int,
    newValue: String,
    currentDigits: List<String>,
    onDigitsChange: (List<String>) -> Unit,
    focusRequesters: List<FocusRequester>,
    onFocusChange: (Int) -> Unit
) {
    // Handle paste of full code
    if (newValue.length > 1) {
        val pastedDigits = newValue.filter { it.isDigit() }.take(6)
        val newDigits = currentDigits.toMutableList()
        pastedDigits.forEachIndexed { i, char ->
            if (i < 6) {
                newDigits[i] = char.toString()
            }
        }
        onDigitsChange(newDigits)
        val focusIndex = minOf(pastedDigits.length, 5)
        focusRequesters[focusIndex].requestFocus()
        onFocusChange(focusIndex)
        return
    }

    // Update single digit
    val newDigits = currentDigits.toMutableList()
    newDigits[index] = newValue.take(1)
    onDigitsChange(newDigits)

    // Move to next field when digit is entered
    if (newValue.isNotEmpty() && index < 5) {
        focusRequesters[index + 1].requestFocus()
        onFocusChange(index + 1)
    }
}
