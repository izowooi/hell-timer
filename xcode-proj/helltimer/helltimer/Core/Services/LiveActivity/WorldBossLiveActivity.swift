//
//  WorldBossLiveActivity.swift
//  helltimer
//
//  월드보스 Live Activity UI
//

import SwiftUI
import WidgetKit
import ActivityKit

/// 월드보스 Live Activity 위젯
@available(iOS 16.1, *)
struct WorldBossLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorldBossActivityAttributes.self) { context in
            // 잠금화면 뷰
            WorldBossLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded 뷰 (길게 누르면 표시)
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.title3)
                            .foregroundStyle(.orange)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.eventTime, style: .timer)
                        .font(.title2.monospacedDigit())
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                        .multilineTextAlignment(.trailing)
                }

                DynamicIslandExpandedRegion(.center) {
                    Text(String(localized: "event.worldBoss"))
                        .font(.headline)
                        .foregroundStyle(.primary)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(String(localized: "liveActivity.startsAt"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(context.state.eventTime, style: .time)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } compactLeading: {
                // Compact 왼쪽 (아이콘)
                Image(systemName: "crown.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            } compactTrailing: {
                // Compact 오른쪽 (타이머)
                Text(context.state.eventTime, style: .timer)
                    .font(.caption.monospacedDigit())
                    .fontWeight(.semibold)
                    .foregroundStyle(.orange)
                    .frame(minWidth: 40)
            } minimal: {
                // Minimal 뷰 (다른 앱과 공유 시)
                Image(systemName: "crown.fill")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
    }
}

// MARK: - Lock Screen View

/// 잠금화면 Live Activity 뷰
@available(iOS 16.1, *)
struct WorldBossLockScreenView: View {
    let context: ActivityViewContext<WorldBossActivityAttributes>

    var body: some View {
        HStack(spacing: 16) {
            // 아이콘
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: "crown.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
            }

            // 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "event.worldBoss"))
                    .font(.headline)
                    .foregroundStyle(.primary)

                HStack(spacing: 4) {
                    Text(String(localized: "liveActivity.startsAt"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(context.state.eventTime, style: .time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // 카운트다운
            VStack(alignment: .trailing, spacing: 2) {
                Text(context.state.eventTime, style: .timer)
                    .font(.title.monospacedDigit())
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)

                Text(String(localized: "liveActivity.remaining"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .activityBackgroundTint(Color(.systemBackground).opacity(0.8))
    }
}

// MARK: - Preview

@available(iOS 16.1, *)
#Preview("Live Activity", as: .content, using: WorldBossActivityAttributes()) {
    WorldBossLiveActivity()
} contentStates: {
    WorldBossActivityAttributes.ContentState(eventTime: Date().addingTimeInterval(300))
}
