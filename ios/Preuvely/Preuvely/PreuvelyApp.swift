//
//  PreuvelyApp.swift
//  Preuvely
//
//  Created for Preuvely - Trust through proof
//

import SwiftUI
import Combine
import UIKit

// MARK: - UIWindow Extension for Shake Detection

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            ShakeDetector.shared.shakeDetected()
        }
    }
}

// MARK: - Main App

@main
struct PreuvelyApp: App {
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var apiClient = APIClient.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showShakeReport = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(localizationManager)
            .environmentObject(apiClient)
            .environment(\.layoutDirection, localizationManager.layoutDirection)
            .preferredColorScheme(.light)
            .onReceive(ShakeDetector.shared.shakePublisher) {
                // Only show shake report if onboarding is complete
                if hasCompletedOnboarding {
                    showShakeReport = true
                }
            }
            .sheet(isPresented: $showShakeReport) {
                ShakeReportSheet()
            }
            .onAppear {
                #if DEBUG
                print("[Preuvely] API Environment: \(APIConfig.environment.name)")
                print("[Preuvely] Base URL: \(APIConfig.baseURL)")
                print("[Preuvely] Shake to Report: Enabled")
                #endif
            }
        }
    }
}
