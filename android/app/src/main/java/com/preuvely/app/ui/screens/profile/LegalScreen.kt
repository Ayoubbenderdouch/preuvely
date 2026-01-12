package com.preuvely.app.ui.screens.profile

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.preuvely.app.R
import com.preuvely.app.ui.theme.*
import com.preuvely.app.utils.AppLanguage
import com.preuvely.app.utils.LocalizationManager
import java.io.BufferedReader
import java.io.InputStreamReader

enum class LegalType {
    TERMS,
    PRIVACY
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LegalScreen(
    legalType: LegalType,
    onNavigateBack: () -> Unit
) {
    val context = LocalContext.current
    val currentLanguage = LocalizationManager.getSavedLanguage(context)

    val title = when (legalType) {
        LegalType.TERMS -> when (currentLanguage) {
            AppLanguage.FRENCH -> "Conditions d'Utilisation"
            AppLanguage.ARABIC -> "شروط الخدمة"
            else -> "Terms of Service"
        }
        LegalType.PRIVACY -> when (currentLanguage) {
            AppLanguage.FRENCH -> "Politique de Confidentialité"
            AppLanguage.ARABIC -> "سياسة الخصوصية"
            else -> "Privacy Policy"
        }
    }

    val content = remember(legalType, currentLanguage) {
        val resourceId = when (legalType) {
            LegalType.TERMS -> when (currentLanguage) {
                AppLanguage.FRENCH -> R.raw.terms_fr
                AppLanguage.ARABIC -> R.raw.terms_ar
                else -> R.raw.terms_en
            }
            LegalType.PRIVACY -> when (currentLanguage) {
                AppLanguage.FRENCH -> R.raw.privacy_fr
                AppLanguage.ARABIC -> R.raw.privacy_ar
                else -> R.raw.privacy_en
            }
        }

        try {
            val inputStream = context.resources.openRawResource(resourceId)
            val reader = BufferedReader(InputStreamReader(inputStream))
            reader.readText()
        } catch (e: Exception) {
            "Content not available"
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = title,
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
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = BackgroundSecondary
                )
            )
        },
        containerColor = BackgroundSecondary
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(horizontal = Spacing.screenPadding)
                .verticalScroll(rememberScrollState())
        ) {
            Spacer(modifier = Modifier.height(Spacing.md))

            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = CardBackground)
            ) {
                Text(
                    text = content,
                    style = PreuvelyTypography.body,
                    color = TextPrimary,
                    textAlign = if (currentLanguage == AppLanguage.ARABIC) TextAlign.Right else TextAlign.Start,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(Spacing.lg)
                )
            }

            Spacer(modifier = Modifier.height(Spacing.xxl))
        }
    }
}
