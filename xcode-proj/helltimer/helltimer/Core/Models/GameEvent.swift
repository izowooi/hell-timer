import Foundation

/// 게임 이벤트 프로토콜
protocol GameEvent {
    var eventType: EventType { get }
    var nextEventTime: Date { get }
    var isActive: Bool { get }
    var displayName: String { get }

    /// 다음 이벤트까지 남은 시간 (초)
    var timeUntilNext: TimeInterval { get }
}

extension GameEvent {
    var displayName: String {
        eventType.displayName
    }

    var timeUntilNext: TimeInterval {
        max(0, nextEventTime.timeIntervalSinceNow)
    }
}

// MARK: - Helltide Event

/// 지옥물결 이벤트 상태
struct HelltideEvent: GameEvent {
    let eventType: EventType = .helltide
    let nextEventTime: Date
    let isActive: Bool
    let remainingActiveTime: TimeInterval? // 활성 상태일 때 남은 시간

    init(nextEventTime: Date, isActive: Bool, remainingActiveTime: TimeInterval? = nil) {
        self.nextEventTime = nextEventTime
        self.isActive = isActive
        self.remainingActiveTime = remainingActiveTime
    }
}

// MARK: - Legion Event

/// 군단 이벤트 상태
struct LegionEvent: GameEvent {
    let eventType: EventType = .legion
    let nextEventTime: Date
    let isActive: Bool
    let timeRemaining: TimeInterval // 남은 시간 (초)

    init(nextEventTime: Date, isActive: Bool = false, timeRemaining: TimeInterval? = nil) {
        self.nextEventTime = nextEventTime
        self.isActive = isActive
        self.timeRemaining = timeRemaining ?? max(0, nextEventTime.timeIntervalSinceNow)
    }

    var timeUntilNext: TimeInterval {
        timeRemaining
    }
}

// MARK: - World Boss Event

/// 월드보스 이벤트 상태
struct WorldBossEvent: GameEvent {
    let eventType: EventType = .worldBoss
    let nextEventTime: Date
    let isActive: Bool
    let timeRemaining: TimeInterval // 남은 시간 (초)

    init(nextEventTime: Date, isActive: Bool = false, timeRemaining: TimeInterval? = nil) {
        self.nextEventTime = nextEventTime
        self.isActive = isActive
        self.timeRemaining = timeRemaining ?? max(0, nextEventTime.timeIntervalSinceNow)
    }

    var timeUntilNext: TimeInterval {
        timeRemaining
    }
}

// MARK: - Event Summary

/// 모든 이벤트 요약 정보
struct EventSummary {
    let helltide: HelltideEvent
    let legion: LegionEvent
    let worldBoss: WorldBossEvent
    let lastUpdated: Date

    /// 가장 임박한 이벤트
    var nextUpcomingEvent: any GameEvent {
        let events: [any GameEvent] = [helltide, legion, worldBoss]
        return events.min(by: { $0.timeUntilNext < $1.timeUntilNext }) ?? helltide
    }

    /// 현재 활성화된 이벤트들
    var activeEvents: [any GameEvent] {
        var active: [any GameEvent] = []
        if helltide.isActive { active.append(helltide) }
        if legion.isActive { active.append(legion) }
        if worldBoss.isActive { active.append(worldBoss) }
        return active
    }
}
