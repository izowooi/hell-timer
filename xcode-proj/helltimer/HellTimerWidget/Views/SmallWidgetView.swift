//
//  SmallWidgetView.swift
//  HellTimerWidget
//
//  Small 위젯 뷰 - 월드보스 이벤트만 표시
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
        return ("월드보스", "crown.fill")
    }

    private var eventColor: Color {
        return Color(red: 1.0, green: 0.53, blue: 0.0) // 월드보스 색상 (주황색)
    }

    private var timerText: String {
        let remaining = entry.worldBoss.timeRemaining(from: entry.date)
        return formatTimeInterval(remaining)
    }

    private var nextTimeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: entry.worldBoss.nextEventTime)
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
