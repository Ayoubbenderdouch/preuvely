import SwiftUI

/// Preuvely Design System - Typography
struct PreuvelyTypography {

    // MARK: - Display

    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title1 = Font.title.weight(.semibold)
    static let title2 = Font.title2.weight(.semibold)
    static let title3 = Font.title3.weight(.medium)

    // MARK: - Headlines

    static let headline = Font.headline
    static let subheadline = Font.subheadline

    // MARK: - Body

    static let body = Font.body
    static let bodyBold = Font.body.weight(.semibold)
    static let callout = Font.callout
    static let calloutBold = Font.callout.weight(.semibold)

    // MARK: - Captions

    static let footnote = Font.footnote
    static let caption1 = Font.caption
    static let caption2 = Font.caption2
}

// MARK: - Text Style Modifiers

extension View {

    func preuvelyLargeTitle() -> some View {
        self.font(PreuvelyTypography.largeTitle)
            .foregroundColor(.primary)
    }

    func preuvelyTitle() -> some View {
        self.font(PreuvelyTypography.title2)
            .foregroundColor(.primary)
    }

    func preuvelyHeadline() -> some View {
        self.font(PreuvelyTypography.headline)
            .foregroundColor(.primary)
    }

    func preuvelyBody() -> some View {
        self.font(PreuvelyTypography.body)
            .foregroundColor(.primary)
    }

    func preuvelySecondary() -> some View {
        self.font(PreuvelyTypography.callout)
            .foregroundColor(.secondary)
    }

    func preuvelyCaption() -> some View {
        self.font(PreuvelyTypography.caption1)
            .foregroundColor(.secondary)
    }
}
