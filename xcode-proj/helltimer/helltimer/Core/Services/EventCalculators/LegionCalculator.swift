import Foundation

/// 군단 이벤트 시간 계산기
/// - 25분 주기
/// - 앵커 타임 기반 계산
final class LegionCalculator {

    // MARK: - Constants

    /// 군단 이벤트 주기 (25분)
    static let intervalMinutes = 25
    static let intervalSeconds: TimeInterval = 25 * 60

    // MARK: - Singleton

    static let shared = LegionCalculator()

    private init() {}

    // MARK: - Public Methods

    /// 다음 군단 이벤트 시간 계산
    /// - Parameters:
    ///   - anchorTime: 앵커 타임 (마지막으로 확인된 군단 시간)
    ///   - date: 기준 시간 (기본값: 현재 시간)
    /// - Returns: LegionEvent
    func getNextEvent(anchorTime: Date, at date: Date = Date()) -> LegionEvent {
        let nextEventTime = calculateNextEventTime(anchorTime: anchorTime, from: date)
        let isActive = checkIfActive(nextEventTime: nextEventTime, at: date)

        return LegionEvent(
            nextEventTime: nextEventTime,
            isActive: isActive
        )
    }

    /// 다음 군단 이벤트까지 남은 시간 계산
    /// - Parameters:
    ///   - anchorTime: 앵커 타임
    ///   - date: 기준 시간
    /// - Returns: 남은 시간 (초)
    func getTimeUntilNext(anchorTime: Date, at date: Date = Date()) -> TimeInterval {
        let nextEventTime = calculateNextEventTime(anchorTime: anchorTime, from: date)
        return max(0, nextEventTime.timeIntervalSince(date))
    }

    /// 앵커 타임으로부터 경과된 사이클 수 계산
    /// - Parameters:
    ///   - anchorTime: 앵커 타임
    ///   - date: 기준 시간
    /// - Returns: 경과된 사이클 수
    func getCyclesPassed(anchorTime: Date, at date: Date = Date()) -> Int {
        let elapsed = date.timeIntervalSince(anchorTime)
        guard elapsed >= 0 else { return 0 }
        return Int(elapsed / Self.intervalSeconds)
    }

    // MARK: - Private Methods

    /// 다음 이벤트 시간 계산
    private func calculateNextEventTime(anchorTime: Date, from date: Date) -> Date {
        let elapsed = date.timeIntervalSince(anchorTime)

        if elapsed < 0 {
            // 앵커 타임이 미래인 경우, 앵커 타임 반환
            return anchorTime
        }

        let cyclesPassed = Int(elapsed / Self.intervalSeconds)
        let nextEventTime = anchorTime.addingTimeInterval(Double(cyclesPassed + 1) * Self.intervalSeconds)

        return nextEventTime
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
    /// 다음 N개의 군단 이벤트 스케줄
    /// - Parameters:
    ///   - count: 가져올 이벤트 수
    ///   - anchorTime: 앵커 타임
    ///   - date: 기준 시간
    /// - Returns: 이벤트 시간 배열
    func getUpcomingEvents(count: Int, anchorTime: Date, from date: Date = Date()) -> [Date] {
        var events: [Date] = []
        var nextEvent = calculateNextEventTime(anchorTime: anchorTime, from: date)

        for _ in 0..<count {
            events.append(nextEvent)
            nextEvent = nextEvent.addingTimeInterval(Self.intervalSeconds)
        }

        return events
    }

    /// 기본 앵커 타임 생성 (현재 시간 기준으로 가장 가까운 25분 배수)
    func createDefaultAnchorTime(from date: Date = Date()) -> Date {
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: date)

        // 현재 분을 25분 단위로 내림
        let roundedMinutes = (minutes / Self.intervalMinutes) * Self.intervalMinutes

        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        components.minute = roundedMinutes
        components.second = 0

        return calendar.date(from: components) ?? date
    }
}
