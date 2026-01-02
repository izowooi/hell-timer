//
//  SmallWidgetView.swift
//  HellTimerWidget
//
//  Small 위젯 뷰 - 가장 임박한 1개 이벤트 표시
//

import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: HellTimerWidgetEntry

    var body: some View {
        ZStack {
            // 배경 그라데이션
            ContainerRelativeShape()
                .fill(backgroundGradient)

            VStack(alignment: .leading, spacing: 8) {
                // 이벤트 아이콘 및 이름
                HStack(spacing: 6) {
                    Image(systemName: currentEvent.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(eventColor)

                    Text(currentEvent.displayName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)

                    Spacer()
                }

                Spacer()

                // 상태 표시
                if isHelltideActive {
                    Text("진행 중")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.green)
                }

                // 타이머
                Text(timerText)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.7)

                // 시작 시간
                Text(nextTimeText)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .padding(12)
        }
    }

    // MARK: - Computed Properties

    private var currentEvent: (displayName: String, iconName: String) {
        switch entry.nextUpcomingEventType {
        case .helltide:
            return ("지옥물결", "flame.fill")
        case .legion:
            return ("군단", "person.3.fill")
        case .worldBoss:
            return ("월드보스", "crown.fill")
        }
    }

    private var eventColor: Color {
        switch entry.nextUpcomingEventType {
        case .helltide:
            return Color(red: 1.0, green: 0.27, blue: 0.27)
        case .legion:
            return Color(red: 0.6, green: 0.27, blue: 1.0)
        case .worldBoss:
            return Color(red: 1.0, green: 0.53, blue: 0.0)
        }
    }

    private var isHelltideActive: Bool {
        entry.nextUpcomingEventType == .helltide && entry.helltide.isActive
    }

    private var timerText: String {
        let remaining: TimeInterval

        switch entry.nextUpcomingEventType {
        case .helltide:
            if entry.helltide.isActive, let activeRemaining = entry.helltide.remainingActiveSeconds {
                remaining = activeRemaining
            } else {
                remaining = entry.helltide.timeRemaining(from: entry.date)
            }
        case .legion:
            remaining = entry.legion.timeRemaining(from: entry.date)
        case .worldBoss:
            remaining = entry.worldBoss.timeRemaining(from: entry.date)
        }

        return formatTimeInterval(remaining)
    }

    private var nextTimeText: String {
        let nextTime: Date

        switch entry.nextUpcomingEventType {
        case .helltide:
            if entry.helltide.isActive {
                return "종료까지"
            }
            nextTime = entry.helltide.nextStartTime
        case .legion:
            nextTime = entry.legion.nextEventTime
        case .worldBoss:
            nextTime = entry.worldBoss.nextEventTime
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: nextTime)
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(.systemBackground).opacity(0.95)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Helpers

    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

// MARK: - Preview

#Preview("Small Widget", as: .systemSmall) {
    HellTimerWidget()
} timeline: {
    HellTimerWidgetEntry.placeholder
}
