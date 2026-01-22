//
//  HellTimerWidget.swift
//  HellTimerWidget
//
//  Created by izowooi on 1/2/26.
//

import WidgetKit
import SwiftUI

/// Small 위젯 - 월드보스
struct WorldBossWidget: Widget {
    let kind: String = "WorldBossWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: HellTimerWidgetProvider()
        ) { entry in
            SmallWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(String(localized: "widget.worldBoss.name"))
        .description(String(localized: "widget.worldBoss.description"))
        .supportedFamilies([.systemSmall])
    }
}

/// Medium, Large 위젯 - 성역은지금
struct SanctuaryWidget: Widget {
    let kind: String = "SanctuaryWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: HellTimerWidgetProvider()
        ) { entry in
            HellTimerWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(String(localized: "widget.sanctuary.name"))
        .description(String(localized: "widget.sanctuary.description"))
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

/// 위젯 엔트리 뷰 - 크기에 따라 다른 뷰 표시
struct HellTimerWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: HellTimerWidgetEntry

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Previews

#Preview("Small - 월드보스", as: .systemSmall) {
    WorldBossWidget()
} timeline: {
    HellTimerWidgetEntry.placeholder
}

#Preview("Medium - 성역은지금", as: .systemMedium) {
    SanctuaryWidget()
} timeline: {
    HellTimerWidgetEntry.placeholder
}

#Preview("Large - 성역은지금", as: .systemLarge) {
    SanctuaryWidget()
} timeline: {
    HellTimerWidgetEntry.placeholder
}
