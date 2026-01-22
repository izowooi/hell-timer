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
    @State private var selectedTheme: AppTheme = .system
    @State private var showingPermissionAlert: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - 화면 테마
                Section {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        HStack {
                            Image(systemName: theme.iconName)
                                .foregroundStyle(theme == .light ? .orange : (theme == .dark ? .indigo : .secondary))
                                .frame(width: 24)

                            Text(theme.displayName)

                            Spacer()

                            if selectedTheme == theme {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedTheme = theme
                        }
                    }
                } header: {
                    Text(String(localized: "settings.theme"))
                }

                // MARK: - 알림 권한 상태
                Section {
                    HStack {
                        Image(systemName: notificationStatusIcon)
                            .foregroundStyle(notificationStatusColor)

                        Text(String(localized: "settings.notificationPermission"))

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
                                Text(String(localized: "settings.requestPermission"))
                            }
                        }

                        if notificationManager.authorizationStatus == .denied {
                            Button {
                                openSettings()
                            } label: {
                                HStack {
                                    Image(systemName: "gear")
                                    Text(String(localized: "settings.changeInSettings"))
                                }
                            }
                        }
                    } else {
                        HStack {
                            Text(String(localized: "settings.scheduledNotifications"))
                            Spacer()
                            Text("\(notificationManager.pendingCount)\(String(localized: "settings.scheduledCountSuffix"))")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text(String(localized: "settings.notificationStatus"))
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
                    Text(String(localized: "settings.eventNotifications"))
                } footer: {
                    if !notificationManager.isAuthorized {
                        Text(String(localized: "settings.enablePermissionFirst"))
                            .foregroundStyle(.orange)
                    } else {
                        Text(String(localized: "settings.enabledEventsNotice"))
                    }
                }

                // MARK: - 알림 시간 설정
                Section {
                    ForEach(UserSettings.availableNotificationMinutes, id: \.self) { minutes in
                        HStack {
                            Text("\(minutes)\(String(localized: "settings.minutesBefore"))")

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
                    Text(String(localized: "settings.notificationTime"))
                } footer: {
                    Text(String(localized: "settings.selectNotificationTime"))
                }

                // MARK: - 앱 정보
                Section {
                    HStack {
                        Text(String(localized: "settings.version"))
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        if let url = URL(string: "https://github.com/izowooi/hell-timer/tree/main/xcode-proj/helltimer") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left.forwardslash.chevron.right")
                                .foregroundStyle(.primary)
                            Text(String(localized: "settings.sourceCode"))
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text(String(localized: "settings.info"))
                }

                // MARK: - 초기화
                Section {
                    Button(String(localized: "settings.cancelAllNotifications"), role: .destructive) {
                        Task {
                            await notificationManager.removeAllNotifications()
                            await notificationManager.updatePendingNotifications()
                        }
                    }

                    Button(String(localized: "settings.resetSettings"), role: .destructive) {
                        resetSettings()
                    }
                }
            }
            .navigationTitle(String(localized: "settings.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "settings.done")) {
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
            .alert(String(localized: "alert.notificationPermission"), isPresented: $showingPermissionAlert) {
                Button(String(localized: "alert.openSettings")) {
                    openSettings()
                }
                Button(String(localized: "alert.cancel"), role: .cancel) {}
            } message: {
                Text(String(localized: "alert.permissionDeniedMessage"))
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
            return String(localized: "permission.authorized")
        case .denied:
            return String(localized: "permission.denied")
        case .notDetermined:
            return String(localized: "permission.notDetermined")
        case .provisional:
            return String(localized: "permission.provisional")
        case .ephemeral:
            return String(localized: "permission.ephemeral")
        @unknown default:
            return String(localized: "permission.unknown")
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

        selectedTheme = settings.appTheme
        helltideNotification = settings.helltideNotificationEnabled
        legionNotification = settings.legionNotificationEnabled
        worldBossNotification = settings.worldBossNotificationEnabled
        selectedMinutes = Set(settings.notificationMinutesBefore)
    }

    private func saveSettings() {
        repository.setAppTheme(selectedTheme)
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
