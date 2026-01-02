//
//  SharedDataManager.swift
//  helltimer
//
//  앱과 위젯 간 데이터 공유 관리자 - 메인 앱 전용
//

import Foundation
import WidgetKit

/// 앱과 위젯 간 데이터 공유 관리자
@MainActor
final class SharedDataManager {
    static let shared = SharedDataManager()

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        self.userDefaults = SharedUserDefaults.shared.userDefaults
    }

    // MARK: - Event Data

    /// 위젯용 이벤트 데이터 저장
    func saveEventData(_ data: WidgetEventData) {
        do {
            let encoded = try encoder.encode(data)
            userDefaults.set(encoded, forKey: AppGroupConstants.Keys.cachedEventData)
            userDefaults.set(Date(), forKey: AppGroupConstants.Keys.lastWidgetUpdate)
        } catch {
            print("Failed to save widget event data: \(error)")
        }
    }

    /// 위젯용 이벤트 데이터 로드
    func loadEventData() -> WidgetEventData? {
        guard let data = userDefaults.data(forKey: AppGroupConstants.Keys.cachedEventData) else {
            return nil
        }

        do {
            return try decoder.decode(WidgetEventData.self, from: data)
        } catch {
            print("Failed to load widget event data: \(error)")
            return nil
        }
    }

    /// 마지막 위젯 업데이트 시간
    var lastWidgetUpdate: Date? {
        userDefaults.object(forKey: AppGroupConstants.Keys.lastWidgetUpdate) as? Date
    }

    // MARK: - Generate Current Event Data

    /// 현재 이벤트 상태로 WidgetEventData 생성
    func generateCurrentEventData(settings: UserSettings) -> WidgetEventData {
        // Helltide
        let helltideStatus = HelltideCalculator.shared.getCurrentStatus()
        let helltideData = WidgetEventData.WidgetHelltideData(
            isActive: helltideStatus.isActive,
            nextStartTime: helltideStatus.nextEventTime,
            remainingActiveSeconds: helltideStatus.remainingActiveTime
        )

        // Legion
        let legionAnchor = settings.legionAnchorTime ?? LegionCalculator.shared.createDefaultAnchorTime()
        let legionEvent = LegionCalculator.shared.getNextEvent(anchorTime: legionAnchor)
        let legionData = WidgetEventData.WidgetLegionData(
            nextEventTime: legionEvent.nextEventTime
        )

        // World Boss
        let worldBossEvent = WorldBossCalculator.shared.getNextEvent(
            cachedSpawnTime: settings.cachedWorldBossSpawnTime,
            cachedBossName: settings.cachedWorldBossName,
            cachedLocation: settings.cachedWorldBossLocation,
            anchorTime: settings.worldBossAnchorTime
        )
        let worldBossData = WidgetEventData.WidgetWorldBossData(
            nextEventTime: worldBossEvent.nextEventTime,
            bossName: worldBossEvent.bossName,
            location: worldBossEvent.location,
            isFromAPI: worldBossEvent.isFromAPI
        )

        return WidgetEventData(
            helltide: helltideData,
            legion: legionData,
            worldBoss: worldBossData,
            lastUpdated: Date()
        )
    }

    /// 앱에서 위젯 데이터 업데이트
    func updateWidgetData() {
        let settings = SettingsRepository.shared.settings
        let eventData = generateCurrentEventData(settings: settings)
        saveEventData(eventData)

        // 위젯 타임라인 갱신 요청
        WidgetCenter.shared.reloadAllTimelines()
    }
}
