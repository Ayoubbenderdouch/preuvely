import SwiftUI

/// iPad Layout Helper - Provides utilities for responsive layouts across iPhone and iPad
///
/// Usage:
/// ```swift
/// struct MyView: View {
///     @Environment(\.horizontalSizeClass) private var horizontalSizeClass
///
///     var body: some View {
///         ContentView()
///             .iPadOptimized() // Centers content with max width
///     }
/// }
/// ```
struct iPadLayout {

    // MARK: - Device Detection

    /// Returns true if running on iPad (based on device idiom)
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    // MARK: - Maximum Content Widths

    /// Maximum width for main content on iPad
    static let maxContentWidth: CGFloat = 700

    /// Maximum width for wide content (like full-width banners)
    static let maxWideContentWidth: CGFloat = 900

    /// Maximum width for forms and text input areas
    static let maxFormWidth: CGFloat = 600

    /// Maximum width for cards in a grid
    static let maxCardWidth: CGFloat = 320

    // MARK: - Grid Columns

    /// Returns the number of columns for category grid based on horizontal size class
    static func categoryGridColumns(for sizeClass: UserInterfaceSizeClass?) -> Int {
        sizeClass == .regular ? 6 : 4
    }

    /// Returns the number of columns for store grid based on horizontal size class
    static func storeGridColumns(for sizeClass: UserInterfaceSizeClass?) -> Int {
        sizeClass == .regular ? 3 : 2
    }

    /// Returns the number of columns for all categories sheet based on horizontal size class
    static func allCategoriesColumns(for sizeClass: UserInterfaceSizeClass?) -> Int {
        sizeClass == .regular ? 5 : 4
    }

    // MARK: - Banner Heights

    /// Returns the banner carousel height based on horizontal size class
    static func bannerHeight(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        sizeClass == .regular ? 220 : 150
    }

    /// Returns the banner placeholder height based on horizontal size class
    static func bannerPlaceholderHeight(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        sizeClass == .regular ? 220 : 150
    }

    // MARK: - Spacing

    /// Returns horizontal padding based on horizontal size class
    static func horizontalPadding(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        sizeClass == .regular ? 40 : 20
    }

    /// Returns section spacing based on horizontal size class
    static func sectionSpacing(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        sizeClass == .regular ? 32 : 24
    }

    /// Returns grid spacing based on horizontal size class
    static func gridSpacing(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        sizeClass == .regular ? 20 : 12
    }

    // MARK: - Font Scaling

    /// Returns a font scaling factor based on horizontal size class
    static func fontScale(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        sizeClass == .regular ? 1.15 : 1.0
    }

    /// Returns icon scaling factor based on horizontal size class
    static func iconScale(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        sizeClass == .regular ? 1.25 : 1.0
    }
}

// MARK: - View Extensions for iPad Optimization

extension View {

    /// Centers content on iPad with a maximum width constraint
    /// On iPhone, content uses full width
    func iPadOptimized(maxWidth: CGFloat = iPadLayout.maxContentWidth) -> some View {
        modifier(iPadOptimizedModifier(maxWidth: maxWidth))
    }

    /// Applies iPad-specific frame constraints while maintaining flexibility
    func iPadFrame(maxWidth: CGFloat = iPadLayout.maxContentWidth) -> some View {
        self.frame(maxWidth: maxWidth)
    }

    /// Applies different padding for iPad vs iPhone
    func adaptivePadding(_ sizeClass: UserInterfaceSizeClass?) -> some View {
        self.padding(.horizontal, iPadLayout.horizontalPadding(for: sizeClass))
    }

    /// Applies scaling for iPad
    func iPadScaled(_ sizeClass: UserInterfaceSizeClass?, factor: CGFloat? = nil) -> some View {
        let scale = factor ?? iPadLayout.fontScale(for: sizeClass)
        return self.scaleEffect(scale)
    }
}

// MARK: - iPad Optimized Modifier

struct iPadOptimizedModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let maxWidth: CGFloat

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            if horizontalSizeClass == .regular {
                // iPad: Center content with max width
                content
                    .frame(maxWidth: min(maxWidth, geometry.size.width))
                    .frame(width: geometry.size.width, alignment: .center)
            } else {
                // iPhone: Full width
                content
                    .frame(width: geometry.size.width)
            }
        }
    }
}

// MARK: - Adaptive Grid Helper

struct AdaptiveGrid<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let iPhoneColumns: Int
    let iPadColumns: Int
    let spacing: CGFloat?
    let content: () -> Content

    init(
        iPhoneColumns: Int = 2,
        iPadColumns: Int = 3,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.iPhoneColumns = iPhoneColumns
        self.iPadColumns = iPadColumns
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        let columnCount = horizontalSizeClass == .regular ? iPadColumns : iPhoneColumns
        let gridSpacing = spacing ?? iPadLayout.gridSpacing(for: horizontalSizeClass)
        let columns = Array(repeating: GridItem(.flexible(), spacing: gridSpacing), count: columnCount)

        LazyVGrid(columns: columns, spacing: gridSpacing) {
            content()
        }
    }
}

// MARK: - Size Class Environment Key Helper

struct SizeClassAwareView<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let content: (UserInterfaceSizeClass?) -> Content

    init(@ViewBuilder content: @escaping (UserInterfaceSizeClass?) -> Content) {
        self.content = content
    }

    var body: some View {
        content(horizontalSizeClass)
    }
}

// MARK: - Preview

#Preview("iPad Layout Helper") {
    SizeClassAwareView { sizeClass in
        ScrollView {
            VStack(spacing: iPadLayout.sectionSpacing(for: sizeClass)) {
                Text("Horizontal Size Class: \(sizeClass == .regular ? "Regular (iPad)" : "Compact (iPhone)")")
                    .font(.headline)

                Text("Category Grid Columns: \(iPadLayout.categoryGridColumns(for: sizeClass))")
                Text("Store Grid Columns: \(iPadLayout.storeGridColumns(for: sizeClass))")
                Text("Banner Height: \(Int(iPadLayout.bannerHeight(for: sizeClass)))")
                Text("Horizontal Padding: \(Int(iPadLayout.horizontalPadding(for: sizeClass)))")

                AdaptiveGrid(iPhoneColumns: 2, iPadColumns: 4) {
                    ForEach(0..<8) { index in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.primaryGreen.opacity(0.3))
                            .frame(height: 100)
                            .overlay(Text("\(index + 1)"))
                    }
                }
                .padding(.horizontal, iPadLayout.horizontalPadding(for: sizeClass))
            }
            .padding(.vertical)
        }
    }
}
