package com.preuvely.app

import android.content.Context
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.hilt.navigation.compose.hiltViewModel
import com.preuvely.app.navigation.PreuvelyNavHost
import com.preuvely.app.ui.screens.onboarding.OnboardingScreen
import com.preuvely.app.ui.theme.PreuvelyTheme
import com.preuvely.app.utils.LocalizationManager
import com.preuvely.app.utils.SessionManager
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    @Inject
    lateinit var sessionManager: SessionManager

    override fun attachBaseContext(newBase: Context) {
        val language = LocalizationManager.getSavedLanguage(newBase)
        val context = LocalizationManager.setLocale(newBase, language)
        super.attachBaseContext(context)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        val currentLanguage = LocalizationManager.getSavedLanguage(this)
        val layoutDirection = LocalizationManager.getLayoutDirection(currentLanguage)

        setContent {
            CompositionLocalProvider(LocalLayoutDirection provides layoutDirection) {
                val hasCompletedOnboarding by sessionManager.hasCompletedOnboarding.collectAsState(initial = null)

                PreuvelyTheme {
                    Surface(
                        modifier = Modifier.fillMaxSize(),
                        color = MaterialTheme.colorScheme.background
                    ) {
                        when (hasCompletedOnboarding) {
                            null -> {
                                // Loading state - show nothing or splash
                            }
                            false -> {
                                OnboardingScreen(
                                    onComplete = {
                                        sessionManager.setOnboardingCompleted()
                                    }
                                )
                            }
                            true -> {
                                PreuvelyNavHost()
                            }
                        }
                    }
                }
            }
        }
    }
}
