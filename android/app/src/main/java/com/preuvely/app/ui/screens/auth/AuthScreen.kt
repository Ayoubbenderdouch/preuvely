package com.preuvely.app.ui.screens.auth

import android.app.Activity
import android.util.Log
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import com.preuvely.app.ui.components.*
import com.preuvely.app.ui.theme.*

private const val GOOGLE_WEB_CLIENT_ID = "604729087626-711v4u6lm463o20cs21pijic34akrr03.apps.googleusercontent.com"

@Composable
fun AuthScreen(
    onNavigateBack: () -> Unit,
    onAuthSuccess: () -> Unit,
    viewModel: AuthViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val context = LocalContext.current

    // Google Sign-In Launcher
    val googleSignInLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.StartActivityForResult()
    ) { result ->
        if (result.resultCode == Activity.RESULT_OK) {
            val task = GoogleSignIn.getSignedInAccountFromIntent(result.data)
            try {
                val account = task.getResult(ApiException::class.java)
                val idToken = account?.idToken
                if (idToken != null) {
                    Log.d("AuthScreen", "Google Sign-In successful, sending token to backend")
                    viewModel.socialAuth("google", idToken, onAuthSuccess)
                } else {
                    Log.e("AuthScreen", "Google Sign-In: No ID token received")
                    viewModel.setError("Could not retrieve Google ID token. Please try again.")
                }
            } catch (e: ApiException) {
                Log.e("AuthScreen", "Google Sign-In failed", e)
                viewModel.setError("Google Sign-In failed: ${e.localizedMessage}")
            }
        } else {
            Log.d("AuthScreen", "Google Sign-In cancelled or failed")
        }
    }

    // Function to start Google Sign-In
    fun startGoogleSignIn() {
        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestIdToken(GOOGLE_WEB_CLIENT_ID)
            .requestEmail()
            .requestProfile()
            .build()

        val googleSignInClient = GoogleSignIn.getClient(context, gso)

        // Sign out first to allow account selection
        googleSignInClient.signOut().addOnCompleteListener {
            val signInIntent = googleSignInClient.signInIntent
            googleSignInLauncher.launch(signInIntent)
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(BackgroundPrimary)
            .verticalScroll(rememberScrollState())
            .padding(Spacing.screenPadding)
    ) {
        // Back Button
        IconButton(
            icon = Icons.Default.Close,
            onClick = onNavigateBack,
            backgroundColor = Gray6
        )

        Spacer(modifier = Modifier.height(Spacing.xl))

        // Logo
        Column(
            modifier = Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(
                modifier = Modifier
                    .size(80.dp)
                    .clip(RoundedCornerShape(14.dp))
                    .background(PrimaryGreen),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "P",
                    style = PreuvelyTypography.largeTitle,
                    color = White
                )
            }
            Spacer(modifier = Modifier.height(Spacing.md))
            Text(
                text = "Preuvely",
                style = PreuvelyTypography.title1,
                color = TextPrimary
            )
            Text(
                text = "Trust Through Proof",
                style = PreuvelyTypography.caption1,
                color = TextSecondary
            )
        }

        Spacer(modifier = Modifier.height(Spacing.xxl))

        // Mode Selector
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(Spacing.radiusMedium))
                .background(Gray6)
                .padding(4.dp)
        ) {
            AuthModeButton(
                text = "Sign In",
                selected = uiState.mode == AuthMode.LOGIN,
                onClick = { viewModel.setMode(AuthMode.LOGIN) },
                modifier = Modifier.weight(1f)
            )
            AuthModeButton(
                text = "Sign Up",
                selected = uiState.mode == AuthMode.REGISTER,
                onClick = { viewModel.setMode(AuthMode.REGISTER) },
                modifier = Modifier.weight(1f)
            )
        }

        Spacer(modifier = Modifier.height(Spacing.xl))

        // Error Message
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
                    color = ErrorRed,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.fillMaxWidth()
                )
            }
            Spacer(modifier = Modifier.height(Spacing.md))
        }

        // Form Fields
        if (uiState.mode == AuthMode.REGISTER) {
            PreuvelyTextField(
                value = uiState.name,
                onValueChange = { viewModel.setName(it) },
                label = "Full Name",
                placeholder = "Enter your name",
                icon = Icons.Default.Person
            )
            Spacer(modifier = Modifier.height(Spacing.md))
        }

        PreuvelyTextField(
            value = uiState.email,
            onValueChange = { viewModel.setEmail(it) },
            label = "Email",
            placeholder = "Enter your email",
            icon = Icons.Default.Email,
            keyboardType = KeyboardType.Email
        )

        Spacer(modifier = Modifier.height(Spacing.md))

        PreuvelyTextField(
            value = uiState.password,
            onValueChange = { viewModel.setPassword(it) },
            label = "Password",
            placeholder = if (uiState.mode == AuthMode.LOGIN) "Enter your password" else "Min 8 characters",
            icon = Icons.Default.Lock,
            isPassword = true,
            imeAction = if (uiState.mode == AuthMode.LOGIN) ImeAction.Done else ImeAction.Next
        )

        if (uiState.mode == AuthMode.REGISTER) {
            Spacer(modifier = Modifier.height(Spacing.md))

            PreuvelyTextField(
                value = uiState.confirmPassword,
                onValueChange = { viewModel.setConfirmPassword(it) },
                label = "Confirm Password",
                placeholder = "Re-enter your password",
                icon = Icons.Default.Lock,
                isPassword = true,
                isError = !uiState.passwordsMatch,
                errorMessage = if (!uiState.passwordsMatch) "Passwords do not match" else null,
                imeAction = ImeAction.Done
            )
        }

        if (uiState.mode == AuthMode.LOGIN) {
            Spacer(modifier = Modifier.height(Spacing.sm))
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
                Text(
                    text = "Forgot Password?",
                    style = PreuvelyTypography.footnote,
                    color = PrimaryGreen,
                    modifier = Modifier.clickable { /* TODO */ }
                )
            }
        }

        Spacer(modifier = Modifier.height(Spacing.xl))

        // Submit Button
        PrimaryButton(
            text = if (uiState.mode == AuthMode.LOGIN) "Sign In" else "Sign Up",
            onClick = {
                if (uiState.mode == AuthMode.LOGIN) {
                    viewModel.login(onAuthSuccess)
                } else {
                    viewModel.register(onAuthSuccess)
                }
            },
            enabled = if (uiState.mode == AuthMode.LOGIN) viewModel.isLoginFormValid else viewModel.isRegisterFormValid,
            isLoading = uiState.isLoading
        )

        Spacer(modifier = Modifier.height(Spacing.xl))

        // Divider
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Divider(modifier = Modifier.weight(1f), color = com.preuvely.app.ui.theme.Divider)
            Text(
                text = "  or continue with  ",
                style = PreuvelyTypography.caption1,
                color = TextSecondary
            )
            Divider(modifier = Modifier.weight(1f), color = com.preuvely.app.ui.theme.Divider)
        }

        Spacer(modifier = Modifier.height(Spacing.xl))

        // Social Buttons
        SocialButton(
            text = "Sign in with Google",
            onClick = { startGoogleSignIn() },
            icon = {
                androidx.compose.foundation.Image(
                    painter = androidx.compose.ui.res.painterResource(id = com.preuvely.app.R.drawable.ic_google_color),
                    contentDescription = null,
                    modifier = Modifier.size(24.dp)
                )
            },
            backgroundColor = Gray6
        )

        Spacer(modifier = Modifier.height(Spacing.md))

        // Note: Apple Sign-In is not natively available on Android
        // It's only shown on iOS. On Android, we hide this button.
        // If you want to support Apple Sign-In on Android, you would need
        // to implement a web-based OAuth flow through your backend.

        Spacer(modifier = Modifier.height(Spacing.xl))

        // Mode Switch
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.Center
        ) {
            Text(
                text = if (uiState.mode == AuthMode.LOGIN) "Don't have an account? " else "Already have an account? ",
                style = PreuvelyTypography.body,
                color = TextSecondary
            )
            Text(
                text = if (uiState.mode == AuthMode.LOGIN) "Sign Up" else "Sign In",
                style = PreuvelyTypography.bodyBold,
                color = PrimaryGreen,
                modifier = Modifier.clickable {
                    viewModel.setMode(
                        if (uiState.mode == AuthMode.LOGIN) AuthMode.REGISTER else AuthMode.LOGIN
                    )
                }
            )
        }

        Spacer(modifier = Modifier.height(Spacing.xxl))
    }
}

@Composable
private fun AuthModeButton(
    text: String,
    selected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(Spacing.radiusMedium))
            .background(if (selected) PrimaryGreen else Color.Transparent)
            .clickable(onClick = onClick)
            .padding(vertical = Spacing.md),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = text,
            style = PreuvelyTypography.subheadlineBold,
            color = if (selected) White else TextSecondary
        )
    }
}
