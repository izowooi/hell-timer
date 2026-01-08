import SwiftUI
import UserNotifications

/// 설정 화면
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var repository = SettingsRepository.shared
    @StateObject private var notificationManager = NotificationManager.shared

    @State private var helltideNotification: Bool = false
    @State private var legionNotification: Bool = false
    @State private var worldBossNotification: Bool = false
    @State private var selectedMinutes: Set<Int> = []
    @State private var showingPermissionAlert: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - 알림 권한 상태
                Section {
                    HStack {
                        Image(systemName: notificationStatusIcon)
                            .foregroundStyle(notificationStatusColor)

                        Text("알림 권한")

                        Spacer()

                        Text(notificationStatusText)
                            .foregroundStyle(.secondary)
                    }

                    if !notificationManager.isAuthorized {
                        Button {
                            requestNotificationPermission()
                        } label: {
                            HStack {
                                Image(systemName: "bell.badge")
                                Text("알림 권한 요청")
                            }
                        }

                        if notificationManager.authorizationStatus == .denied {
                            Button {
                                openSettings()
                            } label: {
                                HStack {
                                    Image(systemName: "gear")
                                    Text("설정에서 권한 변경")
                                }
                            }
                        }
                    } else {
                        HStack {
                            Text("예약된 알림")
                            Spacer()
                            Text("\(notificationManager.pendingCount)개")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("알림 상태")
                }

                // MARK: - 알림 설정
                Section {
                    NotificationToggleRow(
                        eventType: .helltide,
                        isEnabled: $helltideNotification,
                        isDisabled: !notificationManager.isAuthorized
                    )

                    NotificationToggleRow(
                        eventType: .legion,
                        isEnabled: $legionNotification,
                        isDisabled: !notificationManager.isAuthorized
                    )

                    NotificationToggleRow(
                        eventType: .worldBoss,
                        isEnabled: $worldBossNotification,
                        isDisabled: !notificationManager.isAuthorized
                    )
                } header: {
                    Text("이벤트별 알림")
                } footer: {
                    if !notificationManager.isAuthorized {
                        Text("알림을 받으려면 먼저 알림 권한을 허용해주세요")
                            .foregroundStyle(.orange)
                    } else {
                        Text("활성화된 이벤트에 대해 알림을 받습니다")
                    }
                }

                // MARK: - 알림 시간 설정
                Section {
                    ForEach(UserSettings.availableNotificationMinutes, id: \.self) { minutes in
                        HStack {
                            Text("\(minutes)분 전")

                            Spacer()

                            if selectedMinutes.contains(minutes) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleMinute(minutes)
                        }
                        .opacity(notificationManager.isAuthorized ? 1 : 0.5)
                        .disabled(!notificationManager.isAuthorized)
                    }
                } header: {
                    Text("알림 시간")
                } footer: {
                    Text("이벤트 시작 전 알림을 받을 시간을 선택하세요 (다중 선택 가능)")
                }

                // MARK: - 앱 정보
                Section {
                    HStack {
                        Text("버전")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("정보")
                }

                // MARK: - 초기화
                Section {
                    Button("모든 알림 취소", role: .destructive) {
                        Task {
                            await notificationManager.removeAllNotifications()
                            await notificationManager.updatePendingNotifications()
                        }
                    }

                    Button("설정 초기화", role: .destructive) {
                        resetSettings()
                    }
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        saveSettings()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadSettings()
                Task {
                    await notificationManager.checkAuthorizationStatus()
                    await notificationManager.updatePendingNotifications()
                }
            }
            .alert("알림 권한", isPresented: $showingPermissionAlert) {
                Button("설정 열기") {
                    openSettings()
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("알림 권한이 거부되었습니다. 설정에서 알림을 허용해주세요.")
            }
        }
    }

    // MARK: - Notification Status

    private var notificationStatusIcon: String {
        switch notificationManager.authorizationStatus {
        case .authorized:
            return "bell.badge.fill"
        case .denied:
            return "bell.slash.fill"
        case .notDetermined:
            return "bell"
        case .provisional:
            return "bell.badge"
        case .ephemeral:
            return "bell.badge"
        @unknown default:
            return "bell"
        }
    }

    private var notificationStatusColor: Color {
        switch notificationManager.authorizationStatus {
        case .authorized:
            return .green
        case .denied:
            return .red
        case .notDetermined:
            return .orange
        default:
            return .secondary
        }
    }

    private var notificationStatusText: String {
        switch notificationManager.authorizationStatus {
        case .authorized:
            return "허용됨"
        case .denied:
            return "거부됨"
        case .notDetermined:
            return "미설정"
        case .provisional:
            return "임시 허용"
        case .ephemeral:
            return "임시"
        @unknown default:
            return "알 수 없음"
        }
    }

    // MARK: - Private Methods

    private func requestNotificationPermission() {
        Task {
            let granted = await notificationManager.requestAuthorization()
            if !granted && notificationManager.authorizationStatus == .denied {
                showingPermissionAlert = true
            }
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    private func loadSettings() {
        let settings = repository.settings

        helltideNotification = settings.helltideNotificationEnabled
        legionNotification = settings.legionNotificationEnabled
        worldBossNotification = settings.worldBossNotificationEnabled
        selectedMinutes = Set(settings.notificationMinutesBefore)
    }

    private func saveSettings() {
        repository.setHelltideNotification(enabled: helltideNotification)
        repository.setLegionNotification(enabled: legionNotification)
        repository.setWorldBossNotification(enabled: worldBossNotification)
        repository.setNotificationMinutes(Array(selectedMinutes).sorted())

        // 알림 업데이트
        notificationManager.onSettingsChanged()
    }

    private func toggleMinute(_ minute: Int) {
        guard notificationManager.isAuthorized else { return }

        if selectedMinutes.contains(minute) {
            selectedMinutes.remove(minute)
        } else {
            selectedMinutes.insert(minute)
        }
    }

    private func resetSettings() {
        repository.resetToDefaults()
        loadSettings()
        Task {
            await notificationManager.removeAllNotifications()
            await notificationManager.updatePendingNotifications()
        }
    }
}

// MARK: - Notification Toggle Row

struct NotificationToggleRow: View {
    let eventType: EventType
    @Binding var isEnabled: Bool
    var isDisabled: Bool = false

    var body: some View {
        Toggle(isOn: $isEnabled) {
            HStack(spacing: 12) {
                Image(systemName: eventType.iconName)
                    .font(.title3)
                    .foregroundStyle(eventType.color)
                    .frame(width: 28)

                Text(eventType.displayName)
            }
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1)
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
