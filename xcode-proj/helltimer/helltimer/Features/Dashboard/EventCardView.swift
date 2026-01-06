import SwiftUI

/// 이벤트 카드 뷰
struct EventCardView: View {
    let event: any GameEvent
    let showDetails: Bool

    init(event: any GameEvent, showDetails: Bool = true) {
        self.event = event
        self.showDetails = showDetails
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 헤더: 아이콘 + 이름 + 상태
            HStack {
                Image(systemName: event.eventType.iconName)
                    .font(.title2)
                    .foregroundStyle(event.eventType.color)

                Text(event.eventType.displayName)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                if event.isActive {
                    StatusBadge(text: "진행 중", color: .green)
                }
            }

            // 타이머 표시
            VStack(alignment: .leading, spacing: 4) {
                if event.isActive {
                    if let helltide = event as? HelltideEvent,
                       let remaining = helltide.remainingActiveTime {
                        Text("종료까지")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatTimeInterval(remaining))
                            .font(.system(.title, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundStyle(event.eventType.color)
                    }
                } else {
                    Text("다음 시작")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatTimeInterval(event.timeUntilNext))
                        .font(.system(.title, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
            }

            // 시작 시간 표시
            HStack {
                Image(systemName: "clock")
                    .foregroundStyle(.secondary)
                Text(formatEventTime(event.nextEventTime))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(event.isActive ? event.eventType.color : Color.clear, lineWidth: 2)
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

    private func formatEventTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

/// 상태 배지
struct StatusBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.2))
            )
            .foregroundStyle(color)
    }
}

// MARK: - Compact Event Card (위젯용)

struct CompactEventCardView: View {
    let event: any GameEvent

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: event.eventType.iconName)
                .font(.title3)
                .foregroundStyle(event.eventType.color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.eventType.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                if event.isActive {
                    Text("진행 중")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else {
                    Text(formatTimeInterval(event.timeUntilNext))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(formatTimeInterval(event.timeUntilNext))
                .font(.system(.body, design: .monospaced))
                .fontWeight(.semibold)
                .foregroundStyle(event.isActive ? .green : .primary)
        }
        .padding(.vertical, 8)
    }

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

#Preview("Event Card") {
    VStack(spacing: 16) {
        EventCardView(
            event: HelltideEvent(
                nextEventTime: Date().addingTimeInterval(3600),
                isActive: true,
                remainingActiveTime: 1800
            )
        )

        EventCardView(
            event: LegionEvent(
                nextEventTime: Date().addingTimeInterval(900)
            )
        )

        EventCardView(
            event: WorldBossEvent(
                nextEventTime: Date().addingTimeInterval(7200)
            )
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
