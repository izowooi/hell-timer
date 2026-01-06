import Foundation
import Combine

/// 사용자 설정 저장소
/// UserDefaults를 사용하여 설정을 영구 저장
final class SettingsRepository: ObservableObject {

    // MARK: - Constants

    private enum Keys {
        static let userSettings = "userSettings"
        static let appGroupIdentifier = "group.com.izowooi.helltimer"
    }

    // MARK: - Published Properties

    @Published private(set) var settings: UserSettings

    // MARK: - Private Properties

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Singleton

    static let shared = SettingsRepository()

    // MARK: - Initialization

    init(userDefaults: UserDefaults? = nil) {
        // App Group UserDefaults 사용 (위젯과 공유를 위해)
        // App Group이 설정되지 않은 경우 standard 사용
        self.userDefaults = userDefaults ?? UserDefaults(suiteName: Keys.appGroupIdentifier) ?? .standard
        self.settings = Self.loadSettings(from: self.userDefaults, decoder: decoder)
    }

    // MARK: - Public Methods

    /// 설정 업데이트
    func updateSettings(_ settings: UserSettings) {
        self.settings = settings
        saveSettings()
    }

    /// 개별 설정 업데이트

    func setHelltideNotification(enabled: Bool) {
        settings.helltideNotificationEnabled = enabled
        saveSettings()
    }

    func setLegionNotification(enabled: Bool) {
        settings.legionNotificationEnabled = enabled
        saveSettings()
    }

    func setWorldBossNotification(enabled: Bool) {
        settings.worldBossNotificationEnabled = enabled
        saveSettings()
    }

    func setNotificationMinutes(_ minutes: [Int]) {
        settings.notificationMinutesBefore = minutes
        saveSettings()
    }

    // MARK: - Reset

    /// 설정 초기화
    func resetToDefaults() {
        settings = .default
        saveSettings()
    }

    // MARK: - Private Methods

    private func saveSettings() {
        do {
            let data = try encoder.encode(settings)
            userDefaults.set(data, forKey: Keys.userSettings)
        } catch {
            print("Failed to save settings: \(error)")
        }
    }

    private static func loadSettings(from userDefaults: UserDefaults, decoder: JSONDecoder) -> UserSettings {
        guard let data = userDefaults.data(forKey: Keys.userSettings) else {
            return .default
        }

        do {
            return try decoder.decode(UserSettings.self, from: data)
        } catch {
            print("Failed to load settings: \(error)")
            return .default
        }
    }
}

// MARK: - Convenience Extensions

extension SettingsRepository {
    /// 알림이 활성화된 이벤트 타입 목록
    var enabledNotificationTypes: [EventType] {
        var types: [EventType] = []
        if settings.helltideNotificationEnabled { types.append(.helltide) }
        if settings.legionNotificationEnabled { types.append(.legion) }
        if settings.worldBossNotificationEnabled { types.append(.worldBoss) }
        return types
    }

    /// 특정 이벤트 타입의 알림이 활성화되어 있는지
    func isNotificationEnabled(for eventType: EventType) -> Bool {
        switch eventType {
        case .helltide:
            return settings.helltideNotificationEnabled
        case .legion:
            return settings.legionNotificationEnabled
        case .worldBoss:
            return settings.worldBossNotificationEnabled
        }
    }

    /// 특정 이벤트 타입의 알림 설정 토글
    func toggleNotification(for eventType: EventType) {
        switch eventType {
        case .helltide:
            setHelltideNotification(enabled: !settings.helltideNotificationEnabled)
        case .legion:
            setLegionNotification(enabled: !settings.legionNotificationEnabled)
        case .worldBoss:
            setWorldBossNotification(enabled: !settings.worldBossNotificationEnabled)
        }
    }
}
