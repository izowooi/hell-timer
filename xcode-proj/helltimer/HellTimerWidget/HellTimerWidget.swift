//
//  HellTimerWidget.swift
//  HellTimerWidget
//
//  Created by izowooi on 1/2/26.
//

import WidgetKit
import SwiftUI

/// Hell Timer 위젯 정의
struct HellTimerWidget: Widget {
    let kind: String = "HellTimerWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: HellTimerWidgetProvider()
        ) { entry in
            HellTimerWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Hell Timer")
        .description("디아블로4 이벤트 타이머")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
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

#Preview("Small", as: .systemSmall) {
    HellTimerWidget()
} timeline: {
    HellTimerWidgetEntry.placeholder
}

#Preview("Medium", as: .systemMedium) {
    HellTimerWidget()
} timeline: {
    HellTimerWidgetEntry.placeholder
}

#Preview("Large", as: .systemLarge) {
    HellTimerWidget()
} timeline: {
    HellTimerWidgetEntry.placeholder
}
