//
//  helltimerTests.swift
//  helltimerTests
//
//  Created by izowooi on 1/2/26.
//

import Testing
import Foundation
@testable import helltimer

// MARK: - Helltide Calculator Tests

struct HelltideCalculatorTests {

    @Test("지옥물결 - 정각에 활성화")
    func helltideActiveAtTopOfHour() {
        // Given: 정각 (0분)
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: Date())
        components.minute = 0
        components.second = 0
        let testDate = calendar.date(from: components)!

        // When
        let status = HelltideCalculator.shared.getCurrentStatus(at: testDate)

        // Then
        #expect(status.isActive == true)
        #expect(status.remainingActiveTime != nil)
    }

    @Test("지옥물결 - 54분에 활성화")
    func helltideActiveAt54Minutes() {
        // Given: 54분
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: Date())
        components.minute = 54
        components.second = 0
        let testDate = calendar.date(from: components)!

        // When
        let status = HelltideCalculator.shared.getCurrentStatus(at: testDate)

        // Then
        #expect(status.isActive == true)
    }

    @Test("지옥물결 - 55분에 비활성화")
    func helltideInactiveAt55Minutes() {
        // Given: 55분
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: Date())
        components.minute = 55
        components.second = 0
        let testDate = calendar.date(from: components)!

        // When
        let status = HelltideCalculator.shared.getCurrentStatus(at: testDate)

        // Then
        #expect(status.isActive == false)
        #expect(status.remainingActiveTime == nil)
    }

    @Test("지옥물결 - 59분에 비활성화")
    func helltideInactiveAt59Minutes() {
        // Given: 59분
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: Date())
        components.minute = 59
        components.second = 0
        let testDate = calendar.date(from: components)!

        // When
        let status = HelltideCalculator.shared.getCurrentStatus(at: testDate)

        // Then
        #expect(status.isActive == false)
    }

    @Test("지옥물결 - 남은 시간 계산")
    func helltideRemainingTimeCalculation() {
        // Given: 30분
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: Date())
        components.minute = 30
        components.second = 0
        let testDate = calendar.date(from: components)!

        // When
        let remaining = HelltideCalculator.shared.getRemainingActiveTime(at: testDate)

        // Then: 55분 - 30분 = 25분 (실제로는 54-30 = 24분 + 60초)
        #expect(remaining != nil)
        // 약 24분 정도 남아야 함
        if let remaining = remaining {
            #expect(remaining > 23 * 60)
            #expect(remaining < 26 * 60)
        }
    }

    @Test("지옥물결 - 다음 시작 시간은 정각")
    func helltideNextStartIsTopOfHour() {
        // Given
        let testDate = Date()

        // When
        let nextStart = HelltideCalculator.shared.getNextStartTime(from: testDate)

        // Then: 다음 시작은 정각
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: nextStart)
        let seconds = calendar.component(.second, from: nextStart)

        #expect(minutes == 0)
        #expect(seconds == 0)
    }
}

// MARK: - Legion Calculator Tests

struct LegionCalculatorTests {

    @Test("군단 - 25분 주기 계산")
    func legionIntervalIs25Minutes() {
        // Given
        let anchorTime = Date()

        // When
        let events = LegionCalculator.shared.getUpcomingEvents(count: 3, anchorTime: anchorTime)

        // Then: 각 이벤트 간격이 25분
        #expect(events.count == 3)

        if events.count >= 2 {
            let interval1 = events[1].timeIntervalSince(events[0])
            #expect(abs(interval1 - 25 * 60) < 1) // 25분 (오차 1초 허용)
        }

        if events.count >= 3 {
            let interval2 = events[2].timeIntervalSince(events[1])
            #expect(abs(interval2 - 25 * 60) < 1)
        }
    }

    @Test("군단 - 앵커 타임 기반 다음 이벤트")
    func legionNextEventFromAnchor() {
        // Given: 10분 전 앵커
        let anchorTime = Date().addingTimeInterval(-10 * 60)

        // When
        let event = LegionCalculator.shared.getNextEvent(anchorTime: anchorTime)

        // Then: 다음 이벤트는 앵커로부터 25분 후 (현재로부터 약 15분 후)
        let timeUntilNext = event.nextEventTime.timeIntervalSinceNow
        #expect(timeUntilNext > 14 * 60)
        #expect(timeUntilNext < 16 * 60)
    }

    @Test("군단 - 경과된 사이클 수")
    func legionCyclesPassed() {
        // Given: 50분 전 앵커 (25분 * 2 = 50분 = 2사이클)
        let anchorTime = Date().addingTimeInterval(-50 * 60)

        // When
        let cycles = LegionCalculator.shared.getCyclesPassed(anchorTime: anchorTime)

        // Then
        #expect(cycles == 2)
    }

    @Test("군단 - 미래 앵커 타임")
    func legionFutureAnchorTime() {
        // Given: 10분 후 앵커
        let anchorTime = Date().addingTimeInterval(10 * 60)

        // When
        let event = LegionCalculator.shared.getNextEvent(anchorTime: anchorTime)

        // Then: 앵커 타임이 그대로 반환됨
        #expect(abs(event.nextEventTime.timeIntervalSince(anchorTime)) < 1)
    }
}

// MARK: - World Boss Calculator Tests

struct WorldBossCalculatorTests {

    @Test("월드보스 - 210분 주기")
    func worldBossIntervalIs210Minutes() {
        // Given
        let anchorTime = Date()

        // When
        let events = WorldBossCalculator.shared.getUpcomingEvents(count: 2, anchorTime: anchorTime)

        // Then: 간격이 210분
        #expect(events.count == 2)

        if events.count >= 2 {
            let interval = events[1].timeIntervalSince(events[0])
            #expect(abs(interval - 210 * 60) < 1)
        }
    }

    @Test("월드보스 - 캐시 데이터 우선")
    func worldBossUseCachedData() {
        // Given: 미래의 캐시된 스폰 시간
        let cachedSpawnTime = Date().addingTimeInterval(60 * 60) // 1시간 후
        let cachedBossName = "Wandering Death"
        let cachedLocation = "Fields of Desecration"

        // When
        let event = WorldBossCalculator.shared.getNextEvent(
            cachedSpawnTime: cachedSpawnTime,
            cachedBossName: cachedBossName,
            cachedLocation: cachedLocation,
            anchorTime: nil
        )

        // Then: 캐시된 데이터 사용
        #expect(event.isFromAPI == true)
        #expect(event.bossName == cachedBossName)
        #expect(event.location == cachedLocation)
        #expect(abs(event.nextEventTime.timeIntervalSince(cachedSpawnTime)) < 1)
    }

    @Test("월드보스 - Fallback 계산")
    func worldBossFallbackCalculation() {
        // Given: 캐시 없음, 앵커만 있음
        let anchorTime = Date().addingTimeInterval(-30 * 60) // 30분 전

        // When
        let event = WorldBossCalculator.shared.getNextEvent(
            cachedSpawnTime: nil,
            cachedBossName: nil,
            cachedLocation: nil,
            anchorTime: anchorTime
        )

        // Then: Fallback 계산 사용
        #expect(event.isFromAPI == false)
        #expect(event.bossName == nil)

        // 다음 스폰은 앵커로부터 210분 후 (현재로부터 약 180분 후)
        let timeUntilNext = event.nextEventTime.timeIntervalSinceNow
        #expect(timeUntilNext > 170 * 60)
        #expect(timeUntilNext < 190 * 60)
    }

    @Test("월드보스 - 데이터 없음 시 기본값")
    func worldBossNoDataDefault() {
        // Given: 아무 데이터 없음

        // When
        let event = WorldBossCalculator.shared.getNextEvent(
            cachedSpawnTime: nil,
            cachedBossName: nil,
            cachedLocation: nil,
            anchorTime: nil
        )

        // Then: 기본값 (현재 + 3.5시간)
        let timeUntilNext = event.nextEventTime.timeIntervalSinceNow
        #expect(timeUntilNext > 200 * 60)
        #expect(timeUntilNext < 220 * 60)
    }
}

// MARK: - User Settings Tests

struct UserSettingsTests {

    @Test("설정 - 기본값")
    func defaultSettings() {
        // Given
        let settings = UserSettings.default

        // Then
        #expect(settings.helltideNotificationEnabled == false)
        #expect(settings.legionNotificationEnabled == false)
        #expect(settings.worldBossNotificationEnabled == false)
        #expect(settings.notificationMinutesBefore == [5])
        #expect(settings.legionAnchorTime == nil)
        #expect(settings.worldBossAnchorTime == nil)
    }

    @Test("설정 - 알림 활성화 체크")
    func hasAnyNotificationEnabled() {
        // Given
        var settings = UserSettings.default

        // Then: 기본값은 모두 비활성화
        #expect(settings.hasAnyNotificationEnabled == false)

        // When: 하나 활성화
        settings.helltideNotificationEnabled = true

        // Then
        #expect(settings.hasAnyNotificationEnabled == true)
    }
}

// MARK: - Event Type Tests

struct EventTypeTests {

    @Test("이벤트 타입 - 표시 이름")
    func displayNames() {
        #expect(EventType.helltide.displayName == "지옥물결")
        #expect(EventType.legion.displayName == "군단")
        #expect(EventType.worldBoss.displayName == "월드보스")
    }

    @Test("이벤트 타입 - 아이콘 이름")
    func iconNames() {
        #expect(EventType.helltide.iconName == "flame.fill")
        #expect(EventType.legion.iconName == "person.3.fill")
        #expect(EventType.worldBoss.iconName == "crown.fill")
    }

    @Test("이벤트 타입 - 주기")
    func intervals() {
        #expect(EventType.helltide.intervalSeconds == 60 * 60)
        #expect(EventType.legion.intervalSeconds == 25 * 60)
        #expect(EventType.worldBoss.intervalSeconds == 210 * 60)
    }
}
