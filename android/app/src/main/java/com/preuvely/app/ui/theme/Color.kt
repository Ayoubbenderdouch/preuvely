package com.preuvely.app.ui.theme

import androidx.compose.ui.graphics.Color

// Primary Brand Colors - Matching iOS exactly
val PrimaryGreen = Color(0xFF007359)
val PrimaryGreenLight = Color(0xFF008C72)
val PrimaryGreenDark = Color(0xFF005945)

// Star Rating Color
val StarYellow = Color(0xFFFFCC00)

// Status Colors
val SuccessGreen = Color(0xFF34C759)
val WarningOrange = Color(0xFFFF9500)
val ErrorRed = Color(0xFFFF3B30)

// Platform Brand Colors
val InstagramPink = Color(0xFFE03570)
val FacebookBlue = Color(0xFF3B5899)
val TikTokBlack = Color(0xFF000000)
val WhatsAppGreen = Color(0xFF25AD60)

// Neutral Colors
val White = Color(0xFFFFFFFF)
val Black = Color(0xFF000000)

// Gray Scale (Matching iOS systemGray)
val Gray1 = Color(0xFF8E8E93)
val Gray2 = Color(0xFFAEAEB2)
val Gray3 = Color(0xFFC7C7CC)
val Gray4 = Color(0xFFD1D1D6)
val Gray5 = Color(0xFFE5E5EA)
val Gray6 = Color(0xFFF2F2F7)

// Background Colors
val BackgroundPrimary = Color(0xFFFFFFFF)
val BackgroundSecondary = Color(0xFFF2F2F7)
val BackgroundTertiary = Color(0xFFE5E5EA)

// Text Colors
val TextPrimary = Color(0xFF000000)
val TextSecondary = Color(0xFF8E8E93)
val TextTertiary = Color(0xFFC7C7CC)

// Card Colors
val CardBackground = Color(0xFFFFFFFF)
val CardShadow = Color(0x14000000) // Black at 8% opacity

// Divider
val Divider = Color(0xFFE5E5EA)

// Light Theme Colors
val LightBackground = Color(0xFFFFFFFF)
val LightSurface = Color(0xFFFFFFFF)
val LightSurfaceVariant = Color(0xFFF2F2F7)
val LightOnBackground = Color(0xFF000000)
val LightOnSurface = Color(0xFF000000)
val LightOnSurfaceVariant = Color(0xFF8E8E93)

// Extension function to parse hex color
fun Color.Companion.fromHex(hex: String): Color {
    val colorString = hex.removePrefix("#")
    return Color(android.graphics.Color.parseColor("#$colorString"))
}
