//
//  HellTimerWidgetEntry.swift
//  HellTimerWidget
//
//  위젯 타임라인 엔트리
//

import WidgetKit
import Foundation

/// 위젯 타임라인 엔트리
struct HellTimerWidgetEntry: TimelineEntry {
    let date: Date
    let helltide: HelltideWidgetData
    let legion: LegionWidgetData
    let worldBoss: WorldBossWidgetData
    let configuration: ConfigurationAppIntent

    /// 가장 임박한 이벤트 타입
    var nextUpcomingEventType: WidgetEventType {
        let events: [(WidgetEventType, Date)] = [
            (.helltide, helltide.isActive ? date.addingTimeInterval(3600) : helltide.nextStartTime),
            (.legion, legion.nextEventTime),
            (.worldBoss, worldBoss.nextEventTime)
        ]

        return events.min(by: { $0.1 < $1.1 })?.0 ?? .helltide
    }
}

// MARK: - Widget Event Type

enum WidgetEventType: String {
    case helltide
    case legion
    case worldBoss

    var displayName: String {
        switch self {
        case .helltide: return "지옥물결"
        case .legion: return "군단"
        case .worldBoss: return "월드보스"
        }
    }

    var iconName: String {
        switch self {
        case .helltide: return "flame.fill"
        case .legion: return "person.3.fill"
        case .worldBoss: return "crown.fill"
        }
    }

    var colorHex: String {
        switch self {
        case .helltide: return "#FF4444"
        case .legion: return "#9944FF"
        case .worldBoss: return "#FF8800"
        }
    }
}

// MARK: - Helltide Widget Data

struct HelltideWidgetData {
    let isActive: Bool
    let nextStartTime: Date
    let remainingActiveSeconds: TimeInterval?

    /// 상태 텍스트
    var statusText: String {
        isActive ? "진행 중" : "대기 중"
    }

    /// 남은 시간 (활성 시 종료까지, 비활성 시 시작까지)
    func timeRemaining(from date: Date) -> TimeInterval {
        if isActive, let remaining = remainingActiveSeconds {
            return max(0, remaining - date.timeIntervalSinceNow)
        } else {
            return max(0, nextStartTime.timeIntervalSince(date))
        }
    }

    static let placeholder = HelltideWidgetData(
        isActive: true,
        nextStartTime: Date().addingTimeInterval(3600),
        remainingActiveSeconds: 1800
    )
}

// MARK: - Legion Widget Data

struct LegionWidgetData {
    let nextEventTime: Date

    func timeRemaining(from date: Date) -> TimeInterval {
        max(0, nextEventTime.timeIntervalSince(date))
    }

    static let placeholder = LegionWidgetData(
        nextEventTime: Date().addingTimeInterval(900)
    )
}

// MARK: - World Boss Widget Data

struct WorldBossWidgetData {
    let nextEventTime: Date

    func timeRemaining(from date: Date) -> TimeInterval {
        max(0, nextEventTime.timeIntervalSince(date))
    }

    static let placeholder = WorldBossWidgetData(
        nextEventTime: Date().addingTimeInterval(7200)
    )
}

// MARK: - Placeholder Entry

extension HellTimerWidgetEntry {
    static var placeholder: HellTimerWidgetEntry {
        HellTimerWidgetEntry(
            date: Date(),
            helltide: .placeholder,
            legion: .placeholder,
            worldBoss: .placeholder,
            configuration: ConfigurationAppIntent()
        )
    }
}
