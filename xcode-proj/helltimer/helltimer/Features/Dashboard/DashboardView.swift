import SwiftUI

/// 대시보드 메인 뷰
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 활성 이벤트 배너
                    if !viewModel.activeEvents.isEmpty {
                        ActiveEventBanner(events: viewModel.activeEvents)
                    }

                    // 이벤트 카드들
                    VStack(spacing: 16) {
                        EventCardView(event: viewModel.helltideEvent)
                        EventCardView(event: viewModel.legionEvent)
                        EventCardView(event: viewModel.worldBossEvent)
                    }

                    // 마지막 업데이트 시간
                    HStack {
                        Spacer()
                        Text("업데이트: \(formatDate(viewModel.lastUpdated))")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Hell Timer")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                }
            }
            .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("확인") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
        .task {
            await viewModel.refresh()
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

// MARK: - Active Event Banner

struct ActiveEventBanner: View {
    let events: [any GameEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.green)
                Text("진행 중인 이벤트")
                    .font(.headline)
            }

            ForEach(events.indices, id: \.self) { index in
                let event = events[index]
                HStack {
                    Image(systemName: event.eventType.iconName)
                        .foregroundStyle(event.eventType.color)
                    Text(event.eventType.displayName)
                        .fontWeight(.medium)

                    Spacer()

                    if let helltide = event as? HelltideEvent,
                       let remaining = helltide.remainingActiveTime {
                        Text("종료까지 \(formatTime(remaining))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Preview

#Preview {
    DashboardView()
}
