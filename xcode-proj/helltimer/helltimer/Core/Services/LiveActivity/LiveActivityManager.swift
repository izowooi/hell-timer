//
//  LiveActivityManager.swift
//  helltimer
//
//  Live Activity 라이프사이클 관리
//

import Foundation
import ActivityKit
import Combine

/// Live Activity 관리자
@MainActor
final class LiveActivityManager: ObservableObject {

    // MARK: - Singleton

    static let shared = LiveActivityManager()

    // MARK: - Published Properties

    @Published private(set) var isActivityActive: Bool = false

    // MARK: - Private Properties

    private var currentActivity: Activity<WorldBossActivityAttributes>?
    private var currentEventTime: Date?

    // MARK: - Constants

    /// Live Activity 시작 시간 (이벤트 5분 전)
    private static let startBeforeSeconds: TimeInterval = 5 * 60

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Properties

    /// Live Activity 지원 여부 확인
    var isLiveActivitySupported: Bool {
        if #available(iOS 16.1, *) {
            return ActivityAuthorizationInfo().areActivitiesEnabled
        }
        return false
    }

    /// Live Activity 권한 여부 확인
    var areActivitiesEnabled: Bool {
        if #available(iOS 16.1, *) {
            return ActivityAuthorizationInfo().areActivitiesEnabled
        }
        return false
    }

    // MARK: - Public Methods

    /// 월드보스 Live Activity 시작 필요 여부 확인 및 시작
    func checkAndStartIfNeeded() {
        guard isLiveActivitySupported else { return }
        guard SettingsRepository.shared.settings.liveActivityEnabled else {
            // 설정이 꺼져있으면 기존 Activity 종료
            endActivity()
            return
        }

        let worldBossEvent = WorldBossCalculator.shared.getNextEvent()
        let timeUntilEvent = worldBossEvent.timeUntilNext

        // 5분(300초) 이내이고 아직 시작하지 않았으면 시작
        if timeUntilEvent <= Self.startBeforeSeconds && timeUntilEvent > 0 {
            if currentActivity == nil || currentEventTime != worldBossEvent.nextEventTime {
                startWorldBossActivity(eventTime: worldBossEvent.nextEventTime)
            }
        }

        // 이벤트 시간이 지났으면 종료
        if timeUntilEvent <= 0 {
            endActivity()
        }
    }

    /// Live Activity 시작
    func startWorldBossActivity(eventTime: Date) {
        guard #available(iOS 16.1, *) else { return }
        guard isLiveActivitySupported else { return }

        // 기존 Activity가 있으면 종료
        endActivity()

        let attributes = WorldBossActivityAttributes()
        let contentState = WorldBossActivityAttributes.ContentState(eventTime: eventTime)

        do {
            let activity = try Activity<WorldBossActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: eventTime),
                pushType: nil
            )

            currentActivity = activity
            currentEventTime = eventTime
            isActivityActive = true

            print("Live Activity started for World Boss at \(eventTime)")
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    /// Live Activity 업데이트
    func updateActivity() {
        guard #available(iOS 16.1, *) else { return }
        guard let activity = currentActivity,
              let eventTime = currentEventTime else { return }

        let contentState = WorldBossActivityAttributes.ContentState(eventTime: eventTime)

        Task {
            await activity.update(
                ActivityContent(state: contentState, staleDate: eventTime)
            )
        }
    }

    /// Live Activity 종료
    func endActivity() {
        guard #available(iOS 16.1, *) else { return }

        if let activity = currentActivity {
            Task {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }

        currentActivity = nil
        currentEventTime = nil
        isActivityActive = false
    }

    /// 모든 Live Activity 종료
    func endAllActivities() {
        guard #available(iOS 16.1, *) else { return }

        Task {
            for activity in Activity<WorldBossActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }

        currentActivity = nil
        currentEventTime = nil
        isActivityActive = false
    }
}
