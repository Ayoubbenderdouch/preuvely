package com.preuvely.app.ui.theme

import android.app.Activity
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Shapes
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.unit.dp
import androidx.core.view.WindowCompat

/**
 * Preuvely Theme Configuration
 *
 * Design System Alignment with iOS:
 * - Primary color: #22C55E (bright green)
 * - Consistent spacing: 4pt base grid
 * - Corner radius: 8dp (small), 12dp (medium), 16dp (large)
 * - Shadows: 8dp radius, 8% opacity, 2dp y-offset
 * - Typography: iOS system font equivalents
 */

// Shapes matching iOS corner radius values
private val PreuvelyShapes = Shapes(
    extraSmall = RoundedCornerShape(4.dp),
    small = RoundedCornerShape(8.dp),      // radiusSmall
    medium = RoundedCornerShape(12.dp),    // radiusMedium - cards, buttons, inputs
    large = RoundedCornerShape(16.dp),     // radiusLarge
    extraLarge = RoundedCornerShape(20.dp) // radiusXLarge
)

// Light color scheme only (matching iOS which forces light mode)
private val LightColorScheme = lightColorScheme(
    primary = PrimaryGreen,
    onPrimary = White,
    primaryContainer = PrimaryGreenLight,
    onPrimaryContainer = White,

    secondary = PrimaryGreen,
    onSecondary = White,
    secondaryContainer = Gray6,
    onSecondaryContainer = TextPrimary,

    tertiary = StarYellow,
    onTertiary = Black,

    background = LightBackground,
    onBackground = LightOnBackground,

    surface = LightSurface,
    onSurface = LightOnSurface,
    surfaceVariant = LightSurfaceVariant,
    onSurfaceVariant = LightOnSurfaceVariant,

    error = ErrorRed,
    onError = White,
    errorContainer = Color(0xFFFFDAD6),
    onErrorContainer = ErrorRed,

    outline = Gray4,
    outlineVariant = Gray5,
    scrim = Black
)

@Composable
fun PreuvelyTheme(
    content: @Composable () -> Unit
) {
    val colorScheme = LightColorScheme
    val view = LocalView.current

    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = White.toArgb()
            window.navigationBarColor = White.toArgb()
            WindowCompat.getInsetsController(window, view).apply {
                isAppearanceLightStatusBars = true
                isAppearanceLightNavigationBars = true
            }
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        shapes = PreuvelyShapes,
        content = content
    )
}
