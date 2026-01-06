//
//  MediumWidgetView.swift
//  HellTimerWidget
//
//  Medium 위젯 뷰 - 3가지 이벤트 모두 표시
//

import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let entry: HellTimerWidgetEntry

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(Color(.systemBackground))

            HStack(spacing: 0) {
                // 지옥물결
                EventColumn(
                    iconName: "flame.fill",
                    title: "지옥물결",
                    color: Color(red: 1.0, green: 0.27, blue: 0.27),
                    isActive: entry.helltide.isActive,
                    timeText: helltideTimeText,
                    subtitleText: entry.helltide.isActive ? "종료까지" : nextTimeString(entry.helltide.nextStartTime)
                )

                Divider()
                    .padding(.vertical, 12)

                // 군단
                EventColumn(
                    iconName: "person.3.fill",
                    title: "군단",
                    color: Color(red: 0.6, green: 0.27, blue: 1.0),
                    isActive: false,
                    timeText: formatTimeInterval(entry.legion.timeRemaining(from: entry.date)),
                    subtitleText: nextTimeString(entry.legion.nextEventTime)
                )

                Divider()
                    .padding(.vertical, 12)

                // 월드보스
                EventColumn(
                    iconName: "crown.fill",
                    title: "월드보스",
                    color: Color(red: 1.0, green: 0.53, blue: 0.0),
                    isActive: false,
                    timeText: formatTimeInterval(entry.worldBoss.timeRemaining(from: entry.date)),
                    subtitleText: nextTimeString(entry.worldBoss.nextEventTime)
                )
            }
            .padding(.horizontal, 8)
        }
    }

    // MARK: - Computed Properties

    private var helltideTimeText: String {
        if entry.helltide.isActive, let remaining = entry.helltide.remainingActiveSeconds {
            return formatTimeInterval(remaining)
        }
        return formatTimeInterval(entry.helltide.timeRemaining(from: entry.date))
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

    private func nextTimeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Event Column

struct EventColumn: View {
    let iconName: String
    let title: String
    let color: Color
    let isActive: Bool
    let timeText: String
    let subtitleText: String

    var body: some View {
        VStack(spacing: 6) {
            // 아이콘
            Image(systemName: iconName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(color)

            // 타이틀
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)

            // 활성 상태 뱃지
            if isActive {
                Text("진행 중")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(.green)
                    )
            }

            Spacer()

            // 타이머
            Text(timeText)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.6)

            // 서브타이틀
            Text(subtitleText)
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

// MARK: - Preview

#Preview("Medium Widget", as: .systemMedium) {
    HellTimerWidget()
} timeline: {
    HellTimerWidgetEntry.placeholder
}
