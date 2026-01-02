import Foundation

/// 사용자 설정 모델
struct UserSettings: Codable, Equatable {
    // MARK: - 알림 설정

    /// 지옥물결 알림 활성화
    var helltideNotificationEnabled: Bool

    /// 군단 알림 활성화
    var legionNotificationEnabled: Bool

    /// 월드보스 알림 활성화
    var worldBossNotificationEnabled: Bool

    /// 알림 시간 (분 단위, 이벤트 시작 전)
    var notificationMinutesBefore: [Int]

    // MARK: - 앵커 타임 설정

    /// 군단 앵커 타임 (사용자가 마지막으로 본 군단 시간)
    var legionAnchorTime: Date?

    /// 월드보스 앵커 타임 (API 실패 시 Fallback용)
    var worldBossAnchorTime: Date?

    // MARK: - 캐시된 API 데이터

    /// 마지막 월드보스 API 응답 데이터
    var cachedWorldBossName: String?
    var cachedWorldBossLocation: String?
    var cachedWorldBossSpawnTime: Date?
    var lastAPIFetchTime: Date?

    // MARK: - 기본값

    static let `default` = UserSettings(
        helltideNotificationEnabled: false,
        legionNotificationEnabled: false,
        worldBossNotificationEnabled: false,
        notificationMinutesBefore: [5],
        legionAnchorTime: nil,
        worldBossAnchorTime: nil,
        cachedWorldBossName: nil,
        cachedWorldBossLocation: nil,
        cachedWorldBossSpawnTime: nil,
        lastAPIFetchTime: nil
    )

    // MARK: - 편의 속성

    /// 알림이 하나라도 활성화되어 있는지
    var hasAnyNotificationEnabled: Bool {
        helltideNotificationEnabled || legionNotificationEnabled || worldBossNotificationEnabled
    }

    /// 사용 가능한 알림 시간 옵션
    static let availableNotificationMinutes = [1, 5, 10, 15, 30]
}

// MARK: - API Response Models

/// 월드보스 API 응답 모델
struct WorldBossAPIResponse: Codable {
    let reports: [WorldBossReport]?

    struct WorldBossReport: Codable {
        let reportTime: Int64?
        let spawnTime: Int64?
        let name: String?
        let location: String?

        /// spawnTime을 Date로 변환
        var spawnDate: Date? {
            guard let spawnTime = spawnTime else { return nil }
            return Date(timeIntervalSince1970: TimeInterval(spawnTime) / 1000)
        }
    }
}

/// 지옥물결 API 응답 모델 (참고용)
struct HelltideAPIResponse: Codable {
    let reports: [HelltideReport]?

    struct HelltideReport: Codable {
        let reportTime: Int64?
        let spawnTime: Int64?
        let location: String?
    }
}
