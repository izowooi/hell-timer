import Foundation
import Combine
import SwiftUI
import WidgetKit

/// 대시보드 뷰모델
@MainActor
final class DashboardViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var helltideEvent: HelltideEvent
    @Published var legionEvent: LegionEvent
    @Published var worldBossEvent: WorldBossEvent
    @Published var isLoading = false
    @Published var lastUpdated = Date()

    // MARK: - Private Properties

    private let settingsRepository: SettingsRepository
    private let worldBossAPIService: WorldBossAPIService
    private var timerCancellable: AnyCancellable?
    private var settingsCancellable: AnyCancellable?

    // MARK: - Initialization

    init(
        settingsRepository: SettingsRepository = .shared,
        worldBossAPIService: WorldBossAPIService = .shared
    ) {
        self.settingsRepository = settingsRepository
        self.worldBossAPIService = worldBossAPIService

        // 초기값 설정
        self.helltideEvent = HelltideCalculator.shared.getCurrentStatus()
        self.legionEvent = Self.calculateLegionEvent(settings: settingsRepository.settings)
        self.worldBossEvent = Self.calculateWorldBossEvent(settings: settingsRepository.settings)

        setupTimer()
        setupSettingsObserver()
    }

    // MARK: - Public Methods

    /// 이벤트 정보 새로고침
    func refresh() async {
        isLoading = true

        // API에서 월드보스 정보 가져오기
        await fetchWorldBossFromAPI()

        // 모든 이벤트 재계산
        updateAllEvents()

        isLoading = false
        lastUpdated = Date()
    }

    /// 수동 새로고침 (Pull-to-refresh)
    func manualRefresh() {
        Task {
            await refresh()
        }
    }

    // MARK: - Private Methods

    private func setupTimer() {
        // 1초마다 이벤트 상태 업데이트
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateAllEvents()
            }
    }

    private func setupSettingsObserver() {
        // 설정 변경 감지
        settingsCancellable = settingsRepository.$settings
            .dropFirst()
            .sink { [weak self] _ in
                self?.updateAllEvents()
            }
    }

    private func updateAllEvents() {
        helltideEvent = HelltideCalculator.shared.getCurrentStatus()
        legionEvent = Self.calculateLegionEvent(settings: settingsRepository.settings)
        worldBossEvent = Self.calculateWorldBossEvent(settings: settingsRepository.settings)

        // 위젯 데이터 업데이트 (30초마다)
        updateWidgetDataIfNeeded()
    }

    private var lastWidgetUpdate: Date?

    private func updateWidgetDataIfNeeded() {
        let now = Date()
        if let lastUpdate = lastWidgetUpdate, now.timeIntervalSince(lastUpdate) < 30 {
            return // 30초 이내면 스킵
        }

        lastWidgetUpdate = now
        SharedDataManager.shared.updateWidgetData()
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func fetchWorldBossFromAPI() async {
        do {
            let response = try await worldBossAPIService.fetchWorldBossInfo()

            if let reports = response.reports, let latestReport = reports.first {
                settingsRepository.cacheWorldBossData(
                    name: latestReport.name,
                    location: latestReport.location,
                    spawnTime: latestReport.spawnDate
                )
            }
        } catch {
            // API 실패 시 조용히 fallback 로직 사용 (경고 표시 안함)
            print("World Boss API failed, using fallback: \(error)")
        }
    }

    // MARK: - Static Helpers

    private static func calculateLegionEvent(settings: UserSettings) -> LegionEvent {
        // UTC 기반 고정 앵커 사용 (사용자 입력 불필요)
        return LegionCalculator.shared.getNextEvent()
    }

    private static func calculateWorldBossEvent(settings: UserSettings) -> WorldBossEvent {
        return WorldBossCalculator.shared.getNextEvent(
            cachedSpawnTime: settings.cachedWorldBossSpawnTime,
            cachedBossName: settings.cachedWorldBossName,
            cachedLocation: settings.cachedWorldBossLocation,
            anchorTime: settings.worldBossAnchorTime
        )
    }
}

// MARK: - Computed Properties

extension DashboardViewModel {
    /// 가장 임박한 이벤트
    var nextUpcomingEvent: any GameEvent {
        let events: [any GameEvent] = [helltideEvent, legionEvent, worldBossEvent]
        return events.min(by: { $0.timeUntilNext < $1.timeUntilNext }) ?? helltideEvent
    }

    /// 현재 활성화된 이벤트들
    var activeEvents: [any GameEvent] {
        var active: [any GameEvent] = []
        if helltideEvent.isActive { active.append(helltideEvent) }
        if legionEvent.isActive { active.append(legionEvent) }
        if worldBossEvent.isActive { active.append(worldBossEvent) }
        return active
    }

    /// 설정 저장소 접근
    var settings: UserSettings {
        settingsRepository.settings
    }
}
