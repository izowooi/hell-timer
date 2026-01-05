import Foundation

/// 군단 이벤트 시간 계산기
/// - 25분 고정 주기 (글로벌 UTC 기반)
/// - 전 세계 동일한 시간에 발생
final class LegionCalculator {

    // MARK: - Constants

    /// 군단 이벤트 주기 (25분)
    static let intervalMinutes = 25
    static let intervalSeconds: TimeInterval = 25 * 60  // 1500초

    /// UTC 기반 고정 앵커 타임스탬프
    /// - 검증: 2026-01-05 21:05 KST = 12:05 UTC 기준 역산
    /// - Unix epoch + 1200초 (1970-01-01 00:20:00 UTC) 기준
    /// - 이 앵커로 이벤트가 :05, :30, :55, :20, :45... 패턴 (날짜에 따라 변동)
    static let anchorTimestamp: TimeInterval = 1200

    // MARK: - Singleton

    static let shared = LegionCalculator()

    private init() {}

    // MARK: - Public Methods

    /// 다음 군단 이벤트 시간 계산 (UTC 기반 자동 계산)
    /// - Parameter date: 기준 시간 (기본값: 현재 시간)
    /// - Returns: LegionEvent
    func getNextEvent(at date: Date = Date()) -> LegionEvent {
        let nextEventTime = calculateNextEventTime(from: date)
        let isActive = checkIfActive(nextEventTime: nextEventTime, at: date)
        let timeRemaining = max(0, nextEventTime.timeIntervalSince(date))

        return LegionEvent(
            nextEventTime: nextEventTime,
            isActive: isActive,
            timeRemaining: timeRemaining
        )
    }

    /// 다음 군단 이벤트까지 남은 시간 계산
    /// - Parameter date: 기준 시간
    /// - Returns: 남은 시간 (초)
    func getTimeUntilNext(at date: Date = Date()) -> TimeInterval {
        let nextEventTime = calculateNextEventTime(from: date)
        return max(0, nextEventTime.timeIntervalSince(date))
    }

    /// 현재 시점으로부터 경과된 사이클 수 계산
    /// - Parameter date: 기준 시간
    /// - Returns: 경과된 사이클 수
    func getCyclesPassed(at date: Date = Date()) -> Int {
        let currentTimestamp = date.timeIntervalSince1970
        let elapsed = currentTimestamp - Self.anchorTimestamp
        guard elapsed >= 0 else { return 0 }
        return Int(elapsed / Self.intervalSeconds)
    }

    // MARK: - Private Methods

    /// 다음 이벤트 시간 계산 (UTC 기반)
    private func calculateNextEventTime(from date: Date) -> Date {
        let currentTimestamp = date.timeIntervalSince1970
        let elapsed = currentTimestamp - Self.anchorTimestamp

        // ceil을 사용하여 다음 이벤트 시간 계산
        let cyclesPassed = ceil(elapsed / Self.intervalSeconds)
        let nextEventTimestamp = Self.anchorTimestamp + (cyclesPassed * Self.intervalSeconds)

        return Date(timeIntervalSince1970: nextEventTimestamp)
    }

    /// 현재 군단 이벤트가 진행 중인지 확인
    /// - 군단 이벤트는 약 3-4분간 진행
    /// - 이벤트 시작 후 4분 이내면 활성 상태로 간주
    private func checkIfActive(nextEventTime: Date, at date: Date) -> Bool {
        // 이전 이벤트 시간 계산
        let previousEventTime = nextEventTime.addingTimeInterval(-Self.intervalSeconds)
        let timeSincePrevious = date.timeIntervalSince(previousEventTime)

        // 이벤트 시작 후 4분 이내면 활성 상태
        let eventDuration: TimeInterval = 4 * 60
        return timeSincePrevious >= 0 && timeSincePrevious < eventDuration
    }
}

// MARK: - Convenience Extensions

extension LegionCalculator {
    /// 다음 N개의 군단 이벤트 스케줄 (UTC 기반 자동 계산)
    /// - Parameters:
    ///   - count: 가져올 이벤트 수
    ///   - date: 기준 시간
    /// - Returns: 이벤트 시간 배열
    func getUpcomingEvents(count: Int, from date: Date = Date()) -> [Date] {
        var events: [Date] = []
        var nextEvent = calculateNextEventTime(from: date)

        for _ in 0..<count {
            events.append(nextEvent)
            nextEvent = nextEvent.addingTimeInterval(Self.intervalSeconds)
        }

        return events
    }
}
