import Foundation

/// 월드보스 시간 계산기
/// - 105분 (1시간 45분) 주기 (글로벌 UTC 기반)
/// - 전 세계 동일한 시간에 발생
final class WorldBossCalculator {

    // MARK: - Constants

    /// 월드보스 스폰 주기 (105분 = 1시간 45분)
    static let intervalMinutes = 105
    static let intervalSeconds: TimeInterval = 105 * 60  // 6300초

    /// UTC 기반 고정 앵커 타임스탬프
    /// - 검증: 2026-01-06 21:30 KST = 12:30 UTC
    /// - Unix timestamp: 1767702600
    static let anchorTimestamp: TimeInterval = 1767702600

    // MARK: - Singleton

    static let shared = WorldBossCalculator()

    private init() {}

    // MARK: - Public Methods

    /// 다음 월드보스 이벤트 시간 계산 (UTC 기반 자동 계산)
    /// - Parameter date: 기준 시간 (기본값: 현재 시간)
    /// - Returns: WorldBossEvent
    func getNextEvent(at date: Date = Date()) -> WorldBossEvent {
        let nextEventTime = calculateNextEventTime(from: date)
        let timeRemaining = max(0, nextEventTime.timeIntervalSince(date))

        return WorldBossEvent(
            nextEventTime: nextEventTime,
            isActive: false,
            timeRemaining: timeRemaining
        )
    }

    /// 다음 월드보스까지 남은 시간 계산
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
}

// MARK: - Convenience Extensions

extension WorldBossCalculator {
    /// 다음 N개의 월드보스 스케줄 (UTC 기반 자동 계산)
    /// - Parameters:
    ///   - count: 가져올 이벤트 수
    ///   - date: 기준 시간
    /// - Returns: 스폰 시간 배열
    func getUpcomingEvents(count: Int, from date: Date = Date()) -> [Date] {
        var events: [Date] = []
        var nextEvent = calculateNextEventTime(from: date)

        for _ in 0..<count {
            events.append(nextEvent)
            nextEvent = nextEvent.addingTimeInterval(Self.intervalSeconds)
        }

        return events
    }

    /// 하루에 예상되는 월드보스 횟수 (약 13-14회)
    static var estimatedDailyCount: Int {
        Int(ceil(24 * 60 / Double(intervalMinutes)))
    }
}
