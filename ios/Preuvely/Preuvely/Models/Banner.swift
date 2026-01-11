import Foundation
import SwiftUI

// MARK: - Banner Model

struct Banner: Codable, Identifiable, Equatable {
    let id: Int
    let title: String?
    let subtitle: String?
    let imageUrl: String
    let backgroundColor: String
    let linkType: LinkType
    let linkValue: String?

    enum LinkType: String, Codable {
        case none
        case store
        case category
        case url
    }

    // Note: Using JSONDecoder with .convertFromSnakeCase strategy
    // No explicit CodingKeys needed - snake_case is auto-converted to camelCase

    /// Convert hex color string to SwiftUI Color
    var color: Color {
        Color(hex: backgroundColor) ?? .primaryGreen
    }

    /// Check if banner has a valid link
    var hasLink: Bool {
        linkType != .none && linkValue != nil && !linkValue!.isEmpty
    }
}

// MARK: - Preview Data

#if DEBUG
extension Banner {
    static let samples: [Banner] = []
}
#endif

// MARK: - Color Extension for Hex

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
