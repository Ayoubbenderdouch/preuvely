import SwiftUI
import Combine

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject private var localizationManager: LocalizationManager

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Content
            Group {
                switch selectedTab {
                case 0:
                    HomeView()
                case 1:
                    SearchView()
                case 2:
                    NavigationStack {
                        AddStoreView()
                    }
                case 3:
                    ProfileView()
                default:
                    HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 90) // Space for floating tab bar

            // Beautiful Floating Tab Bar
            FloatingTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
        .ignoresSafeArea(.keyboard)
        .environment(\.layoutDirection, localizationManager.layoutDirection)
    }
}

// MARK: - Floating Tab Bar

struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    @Namespace private var animation

    private var tabs: [(iconName: String, titleKey: String, index: Int)] {
        [
            ("homeicon", "tab_home", 0),
            ("searchicon", "tab_search", 1),
            ("addicon", "tab_add", 2),
            ("profilicon", "tab_account", 3)
        ]
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.index) { tab in
                TabButton(
                    iconName: tab.iconName,
                    titleKey: tab.titleKey,
                    isSelected: selectedTab == tab.index,
                    animation: animation
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab.index
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                .shadow(color: .primaryGreen.opacity(0.1), radius: 30, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.3), .white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
    }
}

// MARK: - Regular Tab Button

struct TabButton: View {
    let iconName: String
    let titleKey: String
    let isSelected: Bool
    let animation: Namespace.ID
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        } label: {
            VStack(spacing: 4) {
                Image(iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
                    .opacity(isSelected ? 1.0 : 0.5)

                Text(titleKey.localized)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .primaryGreen : Color(.systemGray))
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(isPressed ? 0.92 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = false
            }
        }
    }
}

// MARK: - Special Add Button

struct AddTabButton: View {
    let iconName: String
    let isSelected: Bool
    let action: () -> Void

    @State private var isPressed = false
    @State private var rotation: Double = 0

    var body: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()

            // Fun rotation animation
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                rotation += 90
            }

            action()
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.primaryGreen.opacity(isSelected ? 0.4 : 0.2),
                                    Color.primaryGreen.opacity(0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 30
                            )
                        )
                        .frame(width: 60, height: 60)
                        .scaleEffect(isSelected ? 1.1 : 1.0)

                    // Main button
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.primaryGreen,
                                    Color.primaryGreen.opacity(0.85)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(color: .primaryGreen.opacity(0.4), radius: 8, x: 0, y: 4)

                    // Custom icon
                    Image(iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .rotationEffect(.degrees(rotation))
                }
                .offset(y: -8) // Lift the add button up

                Text("tab_add".localized)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .primaryGreen : Color(.systemGray))
                    .offset(y: -8)
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(.plain)
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isPressed = false
            }
        }
    }
}

// MARK: - Legacy Tab Bar (kept for reference)

struct CustomTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        FloatingTabBar(selectedTab: $selectedTab)
    }
}

// MARK: - Tab Bar Item (Legacy)

struct TabBarItem: View {
    let iconName: String
    let title: String
    let isSelected: Bool
    let iconSize: CGFloat
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            action()
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(Color.primaryGreen.opacity(isSelected ? 0.15 : 0))
                        .frame(width: iconSize + 16, height: iconSize + 16)
                        .scaleEffect(isSelected ? 1.0 : 0.5)

                    Image(iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize, height: iconSize)
                }

                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .primaryGreen : Color(.systemGray))

                Circle()
                    .fill(Color.primaryGreen)
                    .frame(width: 5, height: 5)
                    .opacity(isSelected ? 1.0 : 0)
                    .scaleEffect(isSelected ? 1.0 : 0.1)
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.35, dampingFraction: 0.65, blendDuration: 0), value: isSelected)
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isPressed = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
        .environmentObject(LocalizationManager.shared)
}
