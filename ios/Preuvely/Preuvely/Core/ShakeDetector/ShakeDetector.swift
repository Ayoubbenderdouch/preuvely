import SwiftUI
import UIKit
import Combine

// MARK: - Shake Detector

/// A singleton class that detects device shake gestures and publishes events
/// Usage: The UIWindow extension in PreuvelyApp.swift calls shakeDetected() when device is shaken
final class ShakeDetector: ObservableObject {
    static let shared = ShakeDetector()

    /// Publisher that emits when device is shaken
    let shakePublisher = PassthroughSubject<Void, Never>()

    /// Whether shake detection is enabled
    @Published var isEnabled: Bool = true

    /// Cooldown to prevent multiple triggers
    private var lastShakeTime: Date = .distantPast
    private let cooldownInterval: TimeInterval = 1.5

    private init() {}

    /// Call this when a shake is detected
    func shakeDetected() {
        guard isEnabled else { return }

        let now = Date()
        guard now.timeIntervalSince(lastShakeTime) > cooldownInterval else { return }

        lastShakeTime = now

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)

        // Publish shake event
        DispatchQueue.main.async {
            self.shakePublisher.send()
        }
    }

    /// Temporarily disable shake detection (e.g., during sensitive operations)
    func disable() {
        isEnabled = false
    }

    /// Re-enable shake detection
    func enable() {
        isEnabled = true
    }
}

// MARK: - View Modifier for Shake Detection

/// View modifier that responds to shake gestures
struct OnShakeModifier: ViewModifier {
    let action: () -> Void

    @State private var cancellable: AnyCancellable?

    func body(content: Content) -> some View {
        content
            .onAppear {
                cancellable = ShakeDetector.shared.shakePublisher
                    .receive(on: DispatchQueue.main)
                    .sink { action() }
            }
            .onDisappear {
                cancellable?.cancel()
            }
    }
}

extension View {
    /// Performs an action when the device is shaken
    func onShake(perform action: @escaping () -> Void) -> some View {
        modifier(OnShakeModifier(action: action))
    }
}
