import Foundation

/// 월드보스 시간 계산기
/// - 210분 (3시간 30분) 주기
/// - API 데이터 우선, Fallback으로 앵커 타임 기반 계산
final class WorldBossCalculator {

    // MARK: - Constants

    /// 월드보스 스폰 주기 (210분 = 3시간 30분)
    static let intervalMinutes = 210
    static let intervalSeconds: TimeInterval = 210 * 60

    // MARK: - Singleton

    static let shared = WorldBossCalculator()

    private init() {}

    // MARK: - Public Methods

    /// 월드보스 이벤트 계산 (API 데이터 우선)
    /// - Parameters:
    ///   - cachedSpawnTime: 캐시된 API 스폰 시간
    ///   - cachedBossName: 캐시된 보스 이름
    ///   - cachedLocation: 캐시된 위치
    ///   - anchorTime: Fallback용 앵커 타임
    ///   - date: 기준 시간
    /// - Returns: WorldBossEvent
    func getNextEvent(
        cachedSpawnTime: Date?,
        cachedBossName: String?,
        cachedLocation: String?,
        anchorTime: Date?,
        at date: Date = Date()
    ) -> WorldBossEvent {
        // 1. 캐시된 API 데이터가 있고 아직 유효한 경우
        if let cachedSpawnTime = cachedSpawnTime, cachedSpawnTime > date {
            let timeRemaining = max(0, cachedSpawnTime.timeIntervalSince(date))
            return WorldBossEvent(
                nextEventTime: cachedSpawnTime,
                isActive: false,
                bossName: cachedBossName,
                location: cachedLocation,
                isFromAPI: true,
                timeRemaining: timeRemaining
            )
        }

        // 2. 캐시된 API 데이터를 기반으로 다음 스폰 시간 계산
        if let cachedSpawnTime = cachedSpawnTime {
            let nextEventTime = calculateNextEventTime(anchorTime: cachedSpawnTime, from: date)
            let timeRemaining = max(0, nextEventTime.timeIntervalSince(date))
            return WorldBossEvent(
                nextEventTime: nextEventTime,
                isActive: false,
                bossName: nil, // 다음 보스는 알 수 없음
                location: nil,
                isFromAPI: false,
                timeRemaining: timeRemaining
            )
        }

        // 3. Fallback: 앵커 타임 기반 계산
        if let anchorTime = anchorTime {
            let nextEventTime = calculateNextEventTime(anchorTime: anchorTime, from: date)
            let timeRemaining = max(0, nextEventTime.timeIntervalSince(date))
            return WorldBossEvent(
                nextEventTime: nextEventTime,
                isActive: false,
                bossName: nil,
                location: nil,
                isFromAPI: false,
                timeRemaining: timeRemaining
            )
        }

        // 4. 데이터 없음: 기본값 반환 (현재 시간 + 3.5시간)
        let nextEventTime = date.addingTimeInterval(Self.intervalSeconds)
        let timeRemaining = Self.intervalSeconds
        return WorldBossEvent(
            nextEventTime: nextEventTime,
            isActive: false,
            bossName: nil,
            location: nil,
            isFromAPI: false,
            timeRemaining: timeRemaining
        )
    }

    /// 다음 월드보스 스폰 시간 계산 (앵커 타임 기반)
    /// - Parameters:
    ///   - anchorTime: 앵커 타임
    ///   - date: 기준 시간
    /// - Returns: 다음 스폰 시간
    func calculateNextEventTime(anchorTime: Date, from date: Date) -> Date {
        let elapsed = date.timeIntervalSince(anchorTime)

        if elapsed < 0 {
            // 앵커 타임이 미래인 경우
            return anchorTime
        }

        let cyclesPassed = Int(elapsed / Self.intervalSeconds)
        return anchorTime.addingTimeInterval(Double(cyclesPassed + 1) * Self.intervalSeconds)
    }

    /// 다음 월드보스까지 남은 시간
    /// - Parameters:
    ///   - anchorTime: 앵커 타임
    ///   - date: 기준 시간
    /// - Returns: 남은 시간 (초)
    func getTimeUntilNext(anchorTime: Date, at date: Date = Date()) -> TimeInterval {
        let nextEventTime = calculateNextEventTime(anchorTime: anchorTime, from: date)
        return max(0, nextEventTime.timeIntervalSince(date))
    }
}

// MARK: - API Integration

extension WorldBossCalculator {
    /// API 응답에서 월드보스 이벤트 생성
    /// - Parameter response: API 응답
    /// - Returns: WorldBossEvent (유효한 데이터가 없으면 nil)
    func parseAPIResponse(_ response: WorldBossAPIResponse, at date: Date = Date()) -> WorldBossEvent? {
        guard let reports = response.reports,
              let latestReport = reports.first,
              let spawnDate = latestReport.spawnDate else {
            return nil
        }

        // 스폰 시간이 미래인 경우
        if spawnDate > date {
            let timeRemaining = max(0, spawnDate.timeIntervalSince(date))
            return WorldBossEvent(
                nextEventTime: spawnDate,
                isActive: false,
                bossName: latestReport.name,
                location: latestReport.location,
                isFromAPI: true,
                timeRemaining: timeRemaining
            )
        }

        // 스폰 시간이 과거인 경우, 다음 스폰 시간 계산
        let nextSpawnTime = calculateNextEventTime(anchorTime: spawnDate, from: date)
        let timeRemaining = max(0, nextSpawnTime.timeIntervalSince(date))
        return WorldBossEvent(
            nextEventTime: nextSpawnTime,
            isActive: false,
            bossName: nil, // 다음 보스는 알 수 없음
            location: nil,
            isFromAPI: false,
            timeRemaining: timeRemaining
        )
    }
}

// MARK: - Convenience Extensions

extension WorldBossCalculator {
    /// 다음 N개의 월드보스 스케줄
    /// - Parameters:
    ///   - count: 가져올 이벤트 수
    ///   - anchorTime: 앵커 타임
    ///   - date: 기준 시간
    /// - Returns: 스폰 시간 배열
    func getUpcomingEvents(count: Int, anchorTime: Date, from date: Date = Date()) -> [Date] {
        var events: [Date] = []
        var nextEvent = calculateNextEventTime(anchorTime: anchorTime, from: date)

        for _ in 0..<count {
            events.append(nextEvent)
            nextEvent = nextEvent.addingTimeInterval(Self.intervalSeconds)
        }

        return events
    }

    /// 하루에 예상되는 월드보스 횟수 (약 6-7회)
    static var estimatedDailyCount: Int {
        Int(ceil(24 * 60 / Double(intervalMinutes)))
    }
}
