package com.preuvely.app.ui.theme

import androidx.compose.ui.unit.dp

// Spacing system matching iOS exactly (4pt base grid)
object Spacing {
    val xxs = 2.dp   // Minimal spacing
    val xs = 4.dp    // Extra small
    val sm = 8.dp    // Small
    val md = 12.dp   // Medium
    val lg = 16.dp   // Large (standard padding)
    val xl = 20.dp   // Extra large
    val xxl = 24.dp  // Double large
    val xxxl = 32.dp // Triple large

    // Component specific
    val cardPadding = 16.dp
    val cardInternalSpacing = 12.dp
    val sectionSpacing = 24.dp
    val screenPadding = 16.dp

    // Corner Radius
    val radiusSmall = 8.dp    // Badges, small components
    val radiusMedium = 12.dp  // Cards, buttons, inputs
    val radiusLarge = 16.dp   // Large components
    val radiusXLarge = 20.dp  // Extra large
    val radiusRound = 100.dp  // Fully rounded (capsules)

    // Specific sizes
    val avatarSmall = 40.dp
    val avatarMedium = 56.dp
    val avatarLarge = 80.dp
    val avatarXLarge = 120.dp

    val logoSmall = 50.dp
    val logoMedium = 60.dp
    val logoLarge = 100.dp

    val iconSmall = 16.dp
    val iconMedium = 20.dp
    val iconLarge = 24.dp
    val iconXLarge = 32.dp

    val buttonHeight = 48.dp
    val buttonHeightSmall = 36.dp
    val buttonIconSize = 18.dp

    val tabBarHeight = 80.dp
    val tabBarIconSize = 36.dp
    val tabBarCornerRadius = 28.dp

    // Platform badge sizes
    val platformBadgeSmall = 28.dp
    val platformBadgeMedium = 36.dp
    val platformBadgeLarge = 44.dp

    // Star sizes
    val starSmall = 12.dp
    val starMedium = 14.dp
    val starLarge = 18.dp
    val starXLarge = 36.dp
}

// Shadow configuration matching iOS
object Shadows {
    val cardElevation = 4.dp
    val buttonElevation = 2.dp
    val tabBarElevation = 8.dp
}
