//
//  NotificationManager.swift
//  helltimer
//
//  로컬 알림 관리자
//

import Foundation
import UserNotifications
import Combine

/// 알림 관리자
@MainActor
final class NotificationManager: ObservableObject {

    // MARK: - Singleton

    static let shared = NotificationManager()

    // MARK: - Published Properties

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published private(set) var pendingNotifications: [UNNotificationRequest] = []

    // MARK: - Private Properties

    private let notificationCenter = UNUserNotificationCenter.current()
    private let settingsRepository: SettingsRepository

    // MARK: - Notification Identifiers

    private enum NotificationIdentifier {
        static let helltidePrefix = "helltide_"
        static let legionPrefix = "legion_"
        static let worldBossPrefix = "worldboss_"

        static func helltide(minutesBefore: Int) -> String {
            "\(helltidePrefix)\(minutesBefore)"
        }

        static func legion(minutesBefore: Int) -> String {
            "\(legionPrefix)\(minutesBefore)"
        }

        static func worldBoss(minutesBefore: Int) -> String {
            "\(worldBossPrefix)\(minutesBefore)"
        }
    }

    // MARK: - Initialization

    private init(settingsRepository: SettingsRepository = .shared) {
        self.settingsRepository = settingsRepository
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Authorization

    /// 알림 권한 상태 확인
    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    /// 알림 권한 요청
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )

            await checkAuthorizationStatus()
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    /// 알림이 허용되었는지 확인
    var isAuthorized: Bool {
        authorizationStatus == .authorized
    }

    // MARK: - Schedule Notifications

    /// 모든 알림 스케줄 업데이트
    func updateAllNotifications() async {
        // 기존 알림 모두 제거
        await removeAllNotifications()

        let settings = settingsRepository.settings

        // 알림이 하나도 활성화되지 않았으면 중단
        guard settings.hasAnyNotificationEnabled else { return }

        // 권한 확인
        guard isAuthorized else {
            print("Notification not authorized")
            return
        }

        // 각 이벤트별 알림 스케줄링
        if settings.helltideNotificationEnabled {
            await scheduleHelltideNotifications(minutesBefore: settings.notificationMinutesBefore)
        }

        if settings.legionNotificationEnabled {
            await scheduleLegionNotifications(minutesBefore: settings.notificationMinutesBefore)
        }

        if settings.worldBossNotificationEnabled {
            await scheduleWorldBossNotifications(minutesBefore: settings.notificationMinutesBefore)
        }

        // 대기 중인 알림 목록 업데이트
        await updatePendingNotifications()
    }

    // MARK: - Helltide Notifications

    /// 지옥물결 알림 스케줄링
    private func scheduleHelltideNotifications(minutesBefore: [Int]) async {
        let helltideStatus = HelltideCalculator.shared.getCurrentStatus()

        // 다음 24시간 동안의 지옥물결 스케줄
        let schedule = HelltideCalculator.shared.getScheduleForNext24Hours()

        for eventTime in schedule.prefix(10) { // 최대 10개까지만
            for minutes in minutesBefore {
                let notificationTime = eventTime.addingTimeInterval(-TimeInterval(minutes * 60))

                // 과거 시간이면 스킵
                guard notificationTime > Date() else { continue }

                let content = UNMutableNotificationContent()
                content.title = "🔥 지옥물결"
                content.body = minutes == 0 ? "지금 시작됩니다!" : "\(minutes)분 후 시작됩니다"
                content.sound = .default
                content.categoryIdentifier = "HELLTIDE"

                let trigger = UNTimeIntervalNotificationTrigger(
                    timeInterval: notificationTime.timeIntervalSinceNow,
                    repeats: false
                )

                let request = UNNotificationRequest(
                    identifier: "\(NotificationIdentifier.helltidePrefix)\(eventTime.timeIntervalSince1970)_\(minutes)",
                    content: content,
                    trigger: trigger
                )

                do {
                    try await notificationCenter.add(request)
                } catch {
                    print("Failed to schedule helltide notification: \(error)")
                }
            }
        }
    }

    // MARK: - Legion Notifications

    /// 군단 알림 스케줄링
    private func scheduleLegionNotifications(minutesBefore: [Int]) async {
        let settings = settingsRepository.settings
        let anchorTime = settings.legionAnchorTime ?? LegionCalculator.shared.createDefaultAnchorTime()

        // 다음 10개의 군단 이벤트
        let schedule = LegionCalculator.shared.getUpcomingEvents(count: 10, anchorTime: anchorTime)

        for eventTime in schedule {
            for minutes in minutesBefore {
                let notificationTime = eventTime.addingTimeInterval(-TimeInterval(minutes * 60))

                // 과거 시간이면 스킵
                guard notificationTime > Date() else { continue }

                let content = UNMutableNotificationContent()
                content.title = "⚔️ 군단 이벤트"
                content.body = minutes == 0 ? "지금 시작됩니다!" : "\(minutes)분 후 시작됩니다"
                content.sound = .default
                content.categoryIdentifier = "LEGION"

                let trigger = UNTimeIntervalNotificationTrigger(
                    timeInterval: notificationTime.timeIntervalSinceNow,
                    repeats: false
                )

                let request = UNNotificationRequest(
                    identifier: "\(NotificationIdentifier.legionPrefix)\(eventTime.timeIntervalSince1970)_\(minutes)",
                    content: content,
                    trigger: trigger
                )

                do {
                    try await notificationCenter.add(request)
                } catch {
                    print("Failed to schedule legion notification: \(error)")
                }
            }
        }
    }

    // MARK: - World Boss Notifications

    /// 월드보스 알림 스케줄링
    private func scheduleWorldBossNotifications(minutesBefore: [Int]) async {
        let settings = settingsRepository.settings

        let worldBossEvent = WorldBossCalculator.shared.getNextEvent(
            cachedSpawnTime: settings.cachedWorldBossSpawnTime,
            cachedBossName: settings.cachedWorldBossName,
            cachedLocation: settings.cachedWorldBossLocation,
            anchorTime: settings.worldBossAnchorTime
        )

        // 다음 5개의 월드보스 이벤트
        var eventTimes: [Date] = [worldBossEvent.nextEventTime]
        for i in 1..<5 {
            eventTimes.append(worldBossEvent.nextEventTime.addingTimeInterval(TimeInterval(i) * WorldBossCalculator.intervalSeconds))
        }

        for eventTime in eventTimes {
            for minutes in minutesBefore {
                let notificationTime = eventTime.addingTimeInterval(-TimeInterval(minutes * 60))

                // 과거 시간이면 스킵
                guard notificationTime > Date() else { continue }

                let content = UNMutableNotificationContent()
                content.title = "👑 월드보스"

                if let bossName = worldBossEvent.bossName, eventTime == worldBossEvent.nextEventTime {
                    content.body = "\(bossName) - \(minutes)분 후 스폰!"
                    if let location = worldBossEvent.location {
                        content.subtitle = "위치: \(location)"
                    }
                } else {
                    content.body = minutes == 0 ? "지금 스폰됩니다!" : "\(minutes)분 후 스폰 예정"
                }

                content.sound = .default
                content.categoryIdentifier = "WORLDBOSS"

                let trigger = UNTimeIntervalNotificationTrigger(
                    timeInterval: notificationTime.timeIntervalSinceNow,
                    repeats: false
                )

                let request = UNNotificationRequest(
                    identifier: "\(NotificationIdentifier.worldBossPrefix)\(eventTime.timeIntervalSince1970)_\(minutes)",
                    content: content,
                    trigger: trigger
                )

                do {
                    try await notificationCenter.add(request)
                } catch {
                    print("Failed to schedule world boss notification: \(error)")
                }
            }
        }
    }

    // MARK: - Remove Notifications

    /// 모든 알림 제거
    func removeAllNotifications() async {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }

    /// 특정 이벤트 타입의 알림만 제거
    func removeNotifications(for eventType: EventType) async {
        let prefix: String
        switch eventType {
        case .helltide:
            prefix = NotificationIdentifier.helltidePrefix
        case .legion:
            prefix = NotificationIdentifier.legionPrefix
        case .worldBoss:
            prefix = NotificationIdentifier.worldBossPrefix
        }

        let pending = await notificationCenter.pendingNotificationRequests()
        let identifiersToRemove = pending
            .filter { $0.identifier.hasPrefix(prefix) }
            .map { $0.identifier }

        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
    }

    // MARK: - Pending Notifications

    /// 대기 중인 알림 목록 업데이트
    func updatePendingNotifications() async {
        pendingNotifications = await notificationCenter.pendingNotificationRequests()
    }

    /// 대기 중인 알림 수
    var pendingCount: Int {
        pendingNotifications.count
    }
}

// MARK: - Convenience Extensions

extension NotificationManager {
    /// 설정 변경 시 알림 업데이트
    func onSettingsChanged() {
        Task {
            await updateAllNotifications()
        }
    }

    /// 앱 포그라운드 진입 시 호출
    func onAppBecomeActive() {
        Task {
            await checkAuthorizationStatus()
            await updateAllNotifications()
        }
    }
}
