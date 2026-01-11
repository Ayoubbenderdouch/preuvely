package com.preuvely.app.utils

import android.content.Context
import android.content.res.Configuration
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.compositionLocalOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.unit.LayoutDirection
import java.util.Locale

enum class AppLanguage(
    val code: String,
    val displayName: String,
    val nativeName: String,
    val isRtl: Boolean,
    val flagResId: Int
) {
    ENGLISH("en", "English", "English", false, com.preuvely.app.R.drawable.flag_uk),
    FRENCH("fr", "French", "Français", false, com.preuvely.app.R.drawable.flag_france),
    ARABIC("ar", "Arabic", "العربية", true, com.preuvely.app.R.drawable.flag_algeria);

    companion object {
        fun fromCode(code: String): AppLanguage {
            return entries.find { it.code == code } ?: ENGLISH
        }
    }
}

val LocalAppLanguage = compositionLocalOf { AppLanguage.ENGLISH }

object LocalizationManager {
    private const val PREFS_NAME = "preuvely_prefs"
    private const val KEY_LANGUAGE = "selected_language"

    fun getSavedLanguage(context: Context): AppLanguage {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val code = prefs.getString(KEY_LANGUAGE, null)
        return if (code != null) {
            AppLanguage.fromCode(code)
        } else {
            getSystemLanguage()
        }
    }

    fun saveLanguage(context: Context, language: AppLanguage) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putString(KEY_LANGUAGE, language.code).apply()
    }

    private fun getSystemLanguage(): AppLanguage {
        val systemLocale = Locale.getDefault().language
        return when {
            systemLocale.startsWith("ar") -> AppLanguage.ARABIC
            systemLocale.startsWith("fr") -> AppLanguage.FRENCH
            else -> AppLanguage.ENGLISH
        }
    }

    fun setLocale(context: Context, language: AppLanguage): Context {
        val locale = Locale(language.code)
        Locale.setDefault(locale)

        val config = Configuration(context.resources.configuration)
        config.setLocale(locale)
        config.setLayoutDirection(locale)

        return context.createConfigurationContext(config)
    }

    fun getLayoutDirection(language: AppLanguage): LayoutDirection {
        return if (language.isRtl) LayoutDirection.Rtl else LayoutDirection.Ltr
    }
}

@Composable
fun LocalizedApp(
    language: AppLanguage,
    content: @Composable () -> Unit
) {
    val context = LocalContext.current
    val localizedContext = remember(language) {
        LocalizationManager.setLocale(context, language)
    }

    val layoutDirection = LocalizationManager.getLayoutDirection(language)

    CompositionLocalProvider(
        LocalAppLanguage provides language,
        LocalLayoutDirection provides layoutDirection
    ) {
        content()
    }
}

class LanguageState(
    private val context: Context,
    initialLanguage: AppLanguage = LocalizationManager.getSavedLanguage(context)
) {
    var currentLanguage by mutableStateOf(initialLanguage)
        private set

    fun setLanguage(language: AppLanguage) {
        currentLanguage = language
        LocalizationManager.saveLanguage(context, language)
    }
}

@Composable
fun rememberLanguageState(): LanguageState {
    val context = LocalContext.current
    return remember {
        LanguageState(context)
    }
}
