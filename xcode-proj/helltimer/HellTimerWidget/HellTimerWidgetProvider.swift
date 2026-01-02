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
        // SharedDataManager에서 캐시된 데이터 로드 시도
        if let cachedData = loadCachedData() {
            return HellTimerWidgetEntry(
                date: date,
                helltide: HelltideWidgetData(
                    isActive: isHelltideActive(at: date),
                    nextStartTime: getNextHelltideStart(from: date),
                    remainingActiveSeconds: getHelltideRemainingTime(at: date)
                ),
                legion: LegionWidgetData(
                    nextEventTime: cachedData.legion.nextEventTime
                ),
                worldBoss: WorldBossWidgetData(
                    nextEventTime: cachedData.worldBoss.nextEventTime,
                    bossName: cachedData.worldBoss.bossName,
                    location: cachedData.worldBoss.location,
                    isFromAPI: cachedData.worldBoss.isFromAPI
                ),
                configuration: configuration
            )
        }

        // 캐시가 없으면 로컬 계산
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
                nextEventTime: date.addingTimeInterval(210 * 60),
                bossName: nil,
                location: nil,
                isFromAPI: false
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

    // MARK: - Legion Calculations (기본값 사용)

    private func getNextLegionTime(from date: Date) -> Date {
        // 기본 앵커 타임 사용 (25분 단위로 내림)
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: date)
        let roundedMinutes = (minutes / 25) * 25

        var components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        components.minute = roundedMinutes

        guard let anchorTime = calendar.date(from: components) else {
            return date.addingTimeInterval(25 * 60)
        }

        // 다음 이벤트 계산
        let elapsed = date.timeIntervalSince(anchorTime)
        let cyclesPassed = Int(elapsed / (25 * 60))
        return anchorTime.addingTimeInterval(Double(cyclesPassed + 1) * 25 * 60)
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
