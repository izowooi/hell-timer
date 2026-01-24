//
//  helltimerApp.swift
//  helltimer
//
//  Created by izowooi on 1/2/26.
//

import SwiftUI
import UserNotifications

@main
struct helltimerApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var settingsRepository = SettingsRepository.shared

    init() {
        // 초기 설정
        setupAppearance()
        setupNotifications()
    }

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .preferredColorScheme(preferredColorScheme)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            handleScenePhaseChange(from: oldPhase, to: newPhase)
        }
    }

    private var preferredColorScheme: ColorScheme? {
        switch settingsRepository.settings.appTheme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }

    // MARK: - Setup

    private func setupAppearance() {
        // 기본 외관 설정 (필요시 커스터마이즈)
    }

    private func setupNotifications() {
        // 알림 카테고리 설정
        let helltideCategory = UNNotificationCategory(
            identifier: "HELLTIDE",
            actions: [],
            intentIdentifiers: [],
            options: []
        )

        let legionCategory = UNNotificationCategory(
            identifier: "LEGION",
            actions: [],
            intentIdentifiers: [],
            options: []
        )

        let worldBossCategory = UNNotificationCategory(
            identifier: "WORLDBOSS",
            actions: [],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([
            helltideCategory,
            legionCategory,
            worldBossCategory
        ])
    }

    // MARK: - Scene Phase

    private func handleScenePhaseChange(from oldPhase: ScenePhase, to newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            // 앱이 포그라운드로 돌아올 때
            Task { @MainActor in
                NotificationManager.shared.onAppBecomeActive()
                SharedDataManager.shared.updateWidgetData()
                LiveActivityManager.shared.checkAndStartIfNeeded()
            }

        case .background:
            // 앱이 백그라운드로 갈 때 위젯 데이터 업데이트
            Task { @MainActor in
                SharedDataManager.shared.updateWidgetData()
            }

        case .inactive:
            break

        @unknown default:
            break
        }
    }
}
