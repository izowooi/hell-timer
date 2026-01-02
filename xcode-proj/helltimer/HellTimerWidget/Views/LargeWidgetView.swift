//
//  LargeWidgetView.swift
//  HellTimerWidget
//
//  Large 위젯 뷰 - 상세 정보 및 다음 일정 미리보기
//

import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
    let entry: HellTimerWidgetEntry

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(Color(.systemBackground))

            VStack(spacing: 12) {
                // 헤더
                HStack {
                    Text("Hell Timer")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)

                    Spacer()

                    Text(formatTime(entry.date))
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                }

                Divider()

                // 이벤트 카드들
                VStack(spacing: 10) {
                    // 지옥물결
                    LargeEventRow(
                        iconName: "flame.fill",
                        title: "지옥물결",
                        color: Color(red: 1.0, green: 0.27, blue: 0.27),
                        isActive: entry.helltide.isActive,
                        timeText: helltideTimeText,
                        nextTime: entry.helltide.nextStartTime,
                        subtitle: entry.helltide.isActive ? "종료까지" : nil
                    )

                    // 군단
                    LargeEventRow(
                        iconName: "person.3.fill",
                        title: "군단",
                        color: Color(red: 0.6, green: 0.27, blue: 1.0),
                        isActive: false,
                        timeText: formatTimeInterval(entry.legion.timeRemaining(from: entry.date)),
                        nextTime: entry.legion.nextEventTime,
                        subtitle: nil
                    )

                    // 월드보스
                    LargeEventRow(
                        iconName: "crown.fill",
                        title: "월드보스",
                        color: Color(red: 1.0, green: 0.53, blue: 0.0),
                        isActive: false,
                        timeText: formatTimeInterval(entry.worldBoss.timeRemaining(from: entry.date)),
                        nextTime: entry.worldBoss.nextEventTime,
                        subtitle: worldBossSubtitle
                    )
                }

                Divider()

                // 월드보스 상세 정보
                if entry.worldBoss.bossName != nil || entry.worldBoss.location != nil {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("월드보스 정보")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)

                        HStack(spacing: 16) {
                            if let bossName = entry.worldBoss.bossName {
                                HStack(spacing: 4) {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 10))
                                    Text(bossName)
                                        .font(.system(size: 11))
                                }
                                .foregroundStyle(.primary)
                            }

                            if let location = entry.worldBoss.location {
                                HStack(spacing: 4) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.system(size: 10))
                                    Text(location)
                                        .font(.system(size: 11))
                                }
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()

                // 하단 정보
                HStack {
                    if !entry.worldBoss.isFromAPI {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 10))
                            Text("오프라인 모드")
                                .font(.system(size: 10))
                        }
                        .foregroundStyle(.orange)
                    }

                    Spacer()

                    Text("업데이트: \(formatTime(entry.date))")
                        .font(.system(size: 10))
                        .foregroundStyle(.quaternary)
                }
            }
            .padding(16)
        }
    }

    // MARK: - Computed Properties

    private var helltideTimeText: String {
        if entry.helltide.isActive, let remaining = entry.helltide.remainingActiveSeconds {
            return formatTimeInterval(remaining)
        }
        return formatTimeInterval(entry.helltide.timeRemaining(from: entry.date))
    }

    private var worldBossSubtitle: String? {
        if let name = entry.worldBoss.bossName {
            return name
        }
        return nil
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

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Large Event Row

struct LargeEventRow: View {
    let iconName: String
    let title: String
    let color: Color
    let isActive: Bool
    let timeText: String
    let nextTime: Date
    let subtitle: String?

    var body: some View {
        HStack(spacing: 12) {
            // 아이콘
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(color)
            }

            // 정보
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)

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
                }

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // 타이머
            VStack(alignment: .trailing, spacing: 2) {
                Text(timeText)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundStyle(.primary)

                Text(formatNextTime(nextTime))
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func formatNextTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview("Large Widget", as: .systemLarge) {
    HellTimerWidget()
} timeline: {
    HellTimerWidgetEntry.placeholder
}
