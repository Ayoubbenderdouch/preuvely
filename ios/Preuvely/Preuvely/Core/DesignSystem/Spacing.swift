import SwiftUI

/// Preuvely Design System - Spacing Tokens
struct Spacing {

    // MARK: - Base Unit (4pt grid)

    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32

    // MARK: - Component Specific

    static let cardPadding: CGFloat = 16
    static let cardSpacing: CGFloat = 12
    static let sectionSpacing: CGFloat = 24
    static let screenPadding: CGFloat = 16

    // MARK: - Corner Radius

    static let radiusSmall: CGFloat = 8
    static let radiusMedium: CGFloat = 12
    static let radiusLarge: CGFloat = 16
    static let radiusXLarge: CGFloat = 20
    static let radiusRound: CGFloat = 100

    // MARK: - Shadow

    static let shadowRadius: CGFloat = 8
    static let shadowOpacity: Double = 0.08
    static let shadowOffset = CGSize(width: 0, height: 2)
}

// MARK: - Card Style Modifier

struct CardStyle: ViewModifier {
    var padding: CGFloat = Spacing.cardPadding

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color(.systemBackground))
            .cornerRadius(Spacing.radiusMedium)
            .shadow(
                color: .black.opacity(Spacing.shadowOpacity),
                radius: Spacing.shadowRadius,
                x: Spacing.shadowOffset.width,
                y: Spacing.shadowOffset.height
            )
    }
}

extension View {
    func cardStyle(padding: CGFloat = Spacing.cardPadding) -> some View {
        modifier(CardStyle(padding: padding))
    }
}

// MARK: - Section Header Modifier

struct SectionHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title3.weight(.semibold))
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.screenPadding)
            .padding(.top, Spacing.sectionSpacing)
            .padding(.bottom, Spacing.sm)
    }
}

extension View {
    func sectionHeaderStyle() -> some View {
        modifier(SectionHeaderStyle())
    }
}
