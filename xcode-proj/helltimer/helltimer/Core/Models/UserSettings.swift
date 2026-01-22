import Foundation

/// 앱 테마 설정
enum AppTheme: String, Codable, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"

    var displayName: String {
        switch self {
        case .light: return String(localized: "theme.light")
        case .dark: return String(localized: "theme.dark")
        case .system: return String(localized: "theme.system")
        }
    }

    var iconName: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }
}

/// 사용자 설정 모델
struct UserSettings: Codable, Equatable {
    // MARK: - 화면 설정

    /// 앱 테마
    var appTheme: AppTheme

    // MARK: - 알림 설정

    /// 지옥물결 알림 활성화
    var helltideNotificationEnabled: Bool

    /// 군단 알림 활성화
    var legionNotificationEnabled: Bool

    /// 월드보스 알림 활성화
    var worldBossNotificationEnabled: Bool

    /// 알림 시간 (분 단위, 이벤트 시작 전)
    var notificationMinutesBefore: [Int]

    // MARK: - 기본값

    static let `default` = UserSettings(
        appTheme: .system,
        helltideNotificationEnabled: false,
        legionNotificationEnabled: false,
        worldBossNotificationEnabled: false,
        notificationMinutesBefore: [5]
    )

    // MARK: - 편의 속성

    /// 알림이 하나라도 활성화되어 있는지
    var hasAnyNotificationEnabled: Bool {
        helltideNotificationEnabled || legionNotificationEnabled || worldBossNotificationEnabled
    }

    /// 사용 가능한 알림 시간 옵션
    static let availableNotificationMinutes = [1, 5, 10, 15, 30]
}

