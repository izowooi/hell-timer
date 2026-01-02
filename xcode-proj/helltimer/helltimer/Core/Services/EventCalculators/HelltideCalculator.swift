import Foundation

/// 지옥물결 시간 계산기
/// - 매시 정각 시작
/// - 55분 지속
/// - 5분 휴식
final class HelltideCalculator {

    // MARK: - Constants

    /// 지옥물결 활성 시간 (55분)
    static let activeDurationMinutes = 55

    /// 지옥물결 휴식 시간 (5분)
    static let breakDurationMinutes = 5

    // MARK: - Singleton

    static let shared = HelltideCalculator()

    private init() {}

    // MARK: - Public Methods

    /// 현재 지옥물결 상태 계산
    /// - Parameter date: 기준 시간 (기본값: 현재 시간)
    /// - Returns: HelltideEvent
    func getCurrentStatus(at date: Date = Date()) -> HelltideEvent {
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)

        if minutes < Self.activeDurationMinutes {
            // 활성 상태 (0~54분)
            let remainingMinutes = Self.activeDurationMinutes - 1 - minutes
            let remainingSeconds = 60 - seconds
            let remainingTime = TimeInterval(remainingMinutes * 60 + remainingSeconds)

            // 다음 시작 시간 = 현재 시간의 다음 정각
            let nextStart = getNextHourStart(from: date)

            return HelltideEvent(
                nextEventTime: nextStart,
                isActive: true,
                remainingActiveTime: remainingTime
            )
        } else {
            // 휴식 상태 (55~59분)
            let nextStart = getNextHourStart(from: date)

            return HelltideEvent(
                nextEventTime: nextStart,
                isActive: false,
                remainingActiveTime: nil
            )
        }
    }

    /// 다음 지옥물결 시작 시간
    /// - Parameter date: 기준 시간
    /// - Returns: 다음 정각 시간
    func getNextStartTime(from date: Date = Date()) -> Date {
        return getNextHourStart(from: date)
    }

    /// 지옥물결이 현재 활성화 상태인지
    /// - Parameter date: 기준 시간
    /// - Returns: 활성화 여부
    func isActive(at date: Date = Date()) -> Bool {
        let minutes = Calendar.current.component(.minute, from: date)
        return minutes < Self.activeDurationMinutes
    }

    /// 지옥물결 종료까지 남은 시간 (활성 상태일 때만)
    /// - Parameter date: 기준 시간
    /// - Returns: 남은 시간 (초), 비활성 상태면 nil
    func getRemainingActiveTime(at date: Date = Date()) -> TimeInterval? {
        guard isActive(at: date) else { return nil }

        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)

        let remainingMinutes = Self.activeDurationMinutes - 1 - minutes
        let remainingSeconds = 60 - seconds

        return TimeInterval(remainingMinutes * 60 + remainingSeconds)
    }

    /// 다음 지옥물결까지 남은 시간 (비활성 상태일 때만)
    /// - Parameter date: 기준 시간
    /// - Returns: 남은 시간 (초), 활성 상태면 nil
    func getTimeUntilNextStart(at date: Date = Date()) -> TimeInterval? {
        guard !isActive(at: date) else { return nil }

        let nextStart = getNextHourStart(from: date)
        return nextStart.timeIntervalSince(date)
    }

    // MARK: - Private Methods

    /// 다음 정각 시간 계산
    private func getNextHourStart(from date: Date) -> Date {
        let calendar = Calendar.current

        // 현재 시간의 분/초를 0으로 설정한 후 1시간 추가
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        components.minute = 0
        components.second = 0

        guard let currentHourStart = calendar.date(from: components) else {
            return date
        }

        return calendar.date(byAdding: .hour, value: 1, to: currentHourStart) ?? date
    }
}

// MARK: - Convenience Extensions

extension HelltideCalculator {
    /// 오늘의 지옥물결 스케줄 (다음 24시간)
    func getScheduleForNext24Hours(from date: Date = Date()) -> [Date] {
        var schedule: [Date] = []
        var currentDate = getNextHourStart(from: date)

        for _ in 0..<24 {
            schedule.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate) ?? currentDate
        }

        return schedule
    }
}
