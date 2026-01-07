//
//  HellTimerWidgetProvider.swift
//  HellTimerWidget
//
//  위젯 타임라인 프로바이더
//

import WidgetKit
import AppIntents
import Foundation

/// 위젯 타임라인 프로바이더
struct HellTimerWidgetProvider: AppIntentTimelineProvider {

    // MARK: - Placeholder

    func placeholder(in context: Context) -> HellTimerWidgetEntry {
        .placeholder
    }

    // MARK: - Snapshot

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> HellTimerWidgetEntry {
        createEntry(for: configuration, date: Date())
    }

    // MARK: - Timeline

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<HellTimerWidgetEntry> {
        var entries: [HellTimerWidgetEntry] = []
        let currentDate = Date()

        // 다음 1시간 동안 1분마다 엔트리 생성
        for minuteOffset in 0..<60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = createEntry(for: configuration, date: entryDate)
            entries.append(entry)
        }

        // 1시간 후 타임라인 갱신
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!

        return Timeline(entries: entries, policy: .after(nextUpdate))
    }

    // MARK: - Create Entry

    private func createEntry(for configuration: ConfigurationAppIntent, date: Date) -> HellTimerWidgetEntry {
        // 모든 이벤트를 항상 실시간으로 계산
        // (캐시된 시간은 과거가 될 수 있으므로 사용하지 않음)
        return HellTimerWidgetEntry(
            date: date,
            helltide: HelltideWidgetData(
                isActive: isHelltideActive(at: date),
                nextStartTime: getNextHelltideStart(from: date),
                remainingActiveSeconds: getHelltideRemainingTime(at: date)
            ),
            legion: LegionWidgetData(
                nextEventTime: getNextLegionTime(from: date)
            ),
            worldBoss: WorldBossWidgetData(
                nextEventTime: getNextWorldBossTime(from: date)
            ),
            configuration: configuration
        )
    }

    // MARK: - Helltide Calculations (로컬 계산 - 100% 정확)

    private func isHelltideActive(at date: Date) -> Bool {
        let minutes = Calendar.current.component(.minute, from: date)
        return minutes < 55
    }

    private func getNextHelltideStart(from date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        components.minute = 0
        components.second = 0

        guard let currentHourStart = calendar.date(from: components) else {
            return date.addingTimeInterval(3600)
        }

        return calendar.date(byAdding: .hour, value: 1, to: currentHourStart) ?? date.addingTimeInterval(3600)
    }

    private func getHelltideRemainingTime(at date: Date) -> TimeInterval? {
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)

        guard minutes < 55 else { return nil }

        let remainingMinutes = 54 - minutes
        let remainingSeconds = 60 - seconds

        return TimeInterval(remainingMinutes * 60 + remainingSeconds)
    }

    // MARK: - Legion Calculations (UTC 기반 고정 앵커)

    private func getNextLegionTime(from date: Date) -> Date {
        // UTC 기반 고정 앵커 타임스탬프
        // - 검증: 2026-01-05 21:05 KST = 12:05 UTC 기준 역산
        // - Unix epoch + 1200초 (1970-01-01 00:20:00 UTC) 기준
        let anchorTimestamp: TimeInterval = 1200
        let intervalSeconds: TimeInterval = 25 * 60  // 1500초

        let currentTimestamp = date.timeIntervalSince1970
        let elapsed = currentTimestamp - anchorTimestamp

        // ceil을 사용하여 다음 이벤트 시간 계산
        let cyclesPassed = ceil(elapsed / intervalSeconds)
        let nextEventTimestamp = anchorTimestamp + (cyclesPassed * intervalSeconds)

        return Date(timeIntervalSince1970: nextEventTimestamp)
    }

    // MARK: - World Boss Calculations (UTC 기반 고정 앵커)

    private func getNextWorldBossTime(from date: Date) -> Date {
        // UTC 기반 고정 앵커 타임스탬프
        // - 검증: 2026-01-06 21:30 KST = 12:30 UTC
        // - Unix timestamp: 1767702600
        let anchorTimestamp: TimeInterval = 1767702600
        let intervalSeconds: TimeInterval = 105 * 60  // 6300초 (1시간 45분)

        let currentTimestamp = date.timeIntervalSince1970
        let elapsed = currentTimestamp - anchorTimestamp

        // ceil을 사용하여 다음 이벤트 시간 계산
        let cyclesPassed = ceil(elapsed / intervalSeconds)
        let nextEventTimestamp = anchorTimestamp + (cyclesPassed * intervalSeconds)

        return Date(timeIntervalSince1970: nextEventTimestamp)
    }

    // MARK: - Load Cached Data

    private func loadCachedData() -> WidgetEventData? {
        let userDefaults = UserDefaults(suiteName: AppGroupConstants.suiteName) ?? .standard
        guard let data = userDefaults.data(forKey: AppGroupConstants.Keys.cachedEventData) else {
            return nil
        }

        return try? JSONDecoder().decode(WidgetEventData.self, from: data)
    }
}
