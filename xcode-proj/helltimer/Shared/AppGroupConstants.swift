//
//  AppGroupConstants.swift
//  helltimer
//
//  App Group 상수 및 공유 데이터 - 앱과 위젯 모두에서 사용
//

import Foundation

/// App Group 상수
enum AppGroupConstants {
    /// App Group Identifier
    /// Xcode에서 앱과 위젯 모두에 이 App Group을 추가해야 합니다
    static let suiteName = "group.com.izowooi.helltimer"

    /// UserDefaults Keys
    enum Keys {
        static let userSettings = "userSettings"
        static let lastWidgetUpdate = "lastWidgetUpdate"
        static let cachedEventData = "cachedEventData"
    }
}

/// App Group UserDefaults 접근자
final class SharedUserDefaults {
    static let shared = SharedUserDefaults()

    let userDefaults: UserDefaults

    private init() {
        // App Group UserDefaults 사용, 없으면 standard 사용
        self.userDefaults = UserDefaults(suiteName: AppGroupConstants.suiteName) ?? .standard
    }
}

/// 위젯에서 사용할 이벤트 데이터 (Codable)
struct WidgetEventData: Codable {
    let helltide: WidgetHelltideData
    let legion: WidgetLegionData
    let worldBoss: WidgetWorldBossData
    let lastUpdated: Date

    struct WidgetHelltideData: Codable {
        let isActive: Bool
        let nextStartTime: Date
        let remainingActiveSeconds: TimeInterval?
    }

    struct WidgetLegionData: Codable {
        let nextEventTime: Date
    }

    struct WidgetWorldBossData: Codable {
        let nextEventTime: Date
    }
}
