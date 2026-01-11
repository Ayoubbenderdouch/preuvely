import SwiftUI
import Combine

struct PlatformBadge: View {
    let platform: Platform
    var size: BadgeSize = .medium

    private var badgeSize: CGFloat {
        switch size {
        case .small: return 28
        case .medium: return 36
        case .large: return 44
        }
    }

    private var iconSize: CGFloat {
        switch size {
        case .small: return 20
        case .medium: return 28
        case .large: return 36
        }
    }

    private var customIconName: String? {
        switch platform {
        case .instagram: return "Instagram"
        case .facebook: return "facebook"
        case .tiktok: return "Tiktok"
        case .whatsapp: return "Whatsapp"
        case .website: return nil
        }
    }

    private var backgroundColor: Color {
        switch platform {
        case .instagram: return .instagramPink
        case .facebook: return .facebookBlue
        case .tiktok: return .black
        case .website: return .primaryGreen
        case .whatsapp: return .whatsappGreen
        }
    }

    var body: some View {
        Group {
            if let iconName = customIconName {
                // Custom asset icon
                Image(iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: iconSize, height: iconSize)
                    .clipShape(Circle())
            } else {
                // SF Symbol fallback for website
                Image(systemName: platform.sfSymbol)
                    .font(.system(size: iconSize * 0.5))
                    .foregroundColor(.white)
                    .frame(width: badgeSize, height: badgeSize)
                    .background(backgroundColor)
                    .clipShape(Circle())
            }
        }
        .accessibilityLabel(Text(platform.displayName))
    }
}

// MARK: - Platform Link Button

struct PlatformLinkButton: View {
    let link: StoreLink
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                PlatformBadge(platform: link.platform)

                VStack(alignment: .leading, spacing: 2) {
                    Text(link.platform.displayName)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.primary)

                    if let handle = link.handle {
                        Text(handle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(Spacing.md)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(Spacing.radiusMedium)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 10) {
            ForEach(Platform.allCases) { platform in
                PlatformBadge(platform: platform, size: .small)
            }
        }

        HStack(spacing: 10) {
            ForEach(Platform.allCases) { platform in
                PlatformBadge(platform: platform, size: .medium)
            }
        }

        VStack(spacing: 10) {
            PlatformLinkButton(
                link: StoreLink(id: 1, platform: .instagram, url: "https://instagram.com/store", handle: "@mystore")
            ) {}

            PlatformLinkButton(
                link: StoreLink(id: 2, platform: .facebook, url: "https://facebook.com/store", handle: nil)
            ) {}
        }
        .padding()
    }
    .padding()
}
