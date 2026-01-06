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
        let testDate = Date()

        // When
        let events = LegionCalculator.shared.getUpcomingEvents(count: 3, from: testDate)

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

    @Test("군단 - 다음 이벤트 계산")
    func legionNextEvent() {
        // Given
        let testDate = Date()

        // When
        let event = LegionCalculator.shared.getNextEvent(at: testDate)

        // Then: 다음 이벤트는 25분 이내
        let timeUntilNext = event.nextEventTime.timeIntervalSince(testDate)
        #expect(timeUntilNext >= 0)
        #expect(timeUntilNext <= 25 * 60)
    }

    @Test("군단 - 경과된 사이클 수")
    func legionCyclesPassed() {
        // Given
        let testDate = Date()

        // When
        let cycles = LegionCalculator.shared.getCyclesPassed(at: testDate)

        // Then: 사이클 수는 0 이상
        #expect(cycles >= 0)
    }
}

// MARK: - World Boss Calculator Tests

struct WorldBossCalculatorTests {

    @Test("월드보스 - 105분 주기")
    func worldBossIntervalIs105Minutes() {
        // Given
        let testDate = Date()

        // When
        let events = WorldBossCalculator.shared.getUpcomingEvents(count: 2, from: testDate)

        // Then: 간격이 105분
        #expect(events.count == 2)

        if events.count >= 2 {
            let interval = events[1].timeIntervalSince(events[0])
            #expect(abs(interval - 105 * 60) < 1)
        }
    }

    @Test("월드보스 - 다음 이벤트 계산")
    func worldBossNextEvent() {
        // Given
        let testDate = Date()

        // When
        let event = WorldBossCalculator.shared.getNextEvent(at: testDate)

        // Then: 다음 이벤트는 105분 이내
        let timeUntilNext = event.nextEventTime.timeIntervalSince(testDate)
        #expect(timeUntilNext >= 0)
        #expect(timeUntilNext <= 105 * 60)
    }

    @Test("월드보스 - 고정 앵커 기반 계산")
    func worldBossFixedAnchorCalculation() {
        // Given: UTC 기반 고정 앵커 (2026-01-06 12:30 UTC = 21:30 KST)
        let anchorTimestamp: TimeInterval = 1767702600

        // When
        let event = WorldBossCalculator.shared.getNextEvent()

        // Then: 고정 앵커 기준 105분 주기로 계산됨
        let nextTimestamp = event.nextEventTime.timeIntervalSince1970
        let elapsed = nextTimestamp - anchorTimestamp

        // 다음 이벤트는 앵커의 배수 시점이어야 함
        let cycles = elapsed / (105 * 60)
        let remainder = elapsed.truncatingRemainder(dividingBy: 105 * 60)
        #expect(abs(remainder) < 1) // 오차 1초 이내
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
        #expect(EventType.worldBoss.intervalSeconds == 105 * 60)
    }
}
