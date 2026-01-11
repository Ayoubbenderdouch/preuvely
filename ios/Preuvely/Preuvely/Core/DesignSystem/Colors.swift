import SwiftUI

/// Preuvely Design System - Color Tokens
extension Color {

    // MARK: - Brand Colors

    /// Primary brand color - Dark Emerald Green
    static let preuvelyPrimary = Color("PrimaryGreen", bundle: .main)
    static let preuvelyPrimaryLight = Color("PrimaryGreenLight", bundle: .main)
    static let preuvelyPrimaryDark = Color("PrimaryGreenDark", bundle: .main)

    // MARK: - Semantic Colors

    /// Background colors
    static let preuvelyBackground = Color("Background", bundle: .main)
    static let preuvelySecondaryBackground = Color("SecondaryBackground", bundle: .main)
    static let preuvelyCardBackground = Color("CardBackground", bundle: .main)

    /// Text colors
    static let preuvelyTextPrimary = Color("TextPrimary", bundle: .main)
    static let preuvelyTextSecondary = Color("TextSecondary", bundle: .main)
    static let preuvelyTextTertiary = Color("TextTertiary", bundle: .main)

    // MARK: - Status Colors

    static let preuvelySuccess = Color("Success", bundle: .main)
    static let preuvelyWarning = Color("Warning", bundle: .main)
    static let preuvelyError = Color("Error", bundle: .main)

    // MARK: - Star Rating

    static let preuvelyStar = Color("StarYellow", bundle: .main)
    static let preuvelyStarEmpty = Color("StarEmpty", bundle: .main)

    // MARK: - Platform Colors

    static let platformInstagram = Color("PlatformInstagram", bundle: .main)
    static let platformFacebook = Color("PlatformFacebook", bundle: .main)
    static let platformTikTok = Color("PlatformTikTok", bundle: .main)
    static let platformWhatsApp = Color("PlatformWhatsApp", bundle: .main)
    static let platformWeb = Color("PlatformWeb", bundle: .main)
}

// MARK: - Fallback Colors (when asset catalog not available)

extension Color {

    // Programmatic fallbacks
    static let primaryGreen = Color(red: 0.0, green: 0.45, blue: 0.35) // #007359 - Dark Emerald
    static let primaryGreenLight = Color(red: 0.0, green: 0.55, blue: 0.45)
    static let primaryGreenDark = Color(red: 0.0, green: 0.35, blue: 0.27)

    static let starYellow = Color(red: 1.0, green: 0.8, blue: 0.0)

    static let instagramPink = Color(red: 0.88, green: 0.19, blue: 0.42)
    static let facebookBlue = Color(red: 0.23, green: 0.35, blue: 0.6)
    static let tiktokBlack = Color.black
    static let whatsappGreen = Color(red: 0.15, green: 0.68, blue: 0.38)
}

// MARK: - Theme Provider

struct PreuvelyColors {

    // Brand
    let primary: Color
    let primaryLight: Color
    let primaryDark: Color

    // Backgrounds
    let background: Color
    let secondaryBackground: Color
    let cardBackground: Color

    // Text
    let textPrimary: Color
    let textSecondary: Color
    let textTertiary: Color

    // Status
    let success: Color
    let warning: Color
    let error: Color

    // Stars
    let star: Color
    let starEmpty: Color

    static let light = PreuvelyColors(
        primary: .primaryGreen,
        primaryLight: .primaryGreenLight,
        primaryDark: .primaryGreenDark,
        background: Color(.systemBackground),
        secondaryBackground: Color(.secondarySystemBackground),
        cardBackground: .white,
        textPrimary: Color(.label),
        textSecondary: Color(.secondaryLabel),
        textTertiary: Color(.tertiaryLabel),
        success: .green,
        warning: .orange,
        error: .red,
        star: .starYellow,
        starEmpty: Color(.systemGray4)
    )

    static let dark = PreuvelyColors(
        primary: .primaryGreenLight,
        primaryLight: .primaryGreen,
        primaryDark: .primaryGreenDark,
        background: Color(.systemBackground),
        secondaryBackground: Color(.secondarySystemBackground),
        cardBackground: Color(.secondarySystemBackground),
        textPrimary: Color(.label),
        textSecondary: Color(.secondaryLabel),
        textTertiary: Color(.tertiaryLabel),
        success: .green,
        warning: .orange,
        error: .red,
        star: .starYellow,
        starEmpty: Color(.systemGray4)
    )
}
