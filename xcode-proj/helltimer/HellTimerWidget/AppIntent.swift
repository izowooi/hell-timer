//
//  AppIntent.swift
//  HellTimerWidget
//
//  Created by izowooi on 1/2/26.
//

import WidgetKit
import AppIntents

/// 위젯 표시 모드
enum DisplayMode: String, AppEnum {
    case all = "모든 이벤트"
    case helltide = "지옥물결만"
    case legion = "군단만"
    case worldBoss = "월드보스만"

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "표시 모드"

    static var caseDisplayRepresentations: [DisplayMode: DisplayRepresentation] = [
        .all: "모든 이벤트",
        .helltide: "지옥물결만",
        .legion: "군단만",
        .worldBoss: "월드보스만"
    ]
}

/// 위젯 설정 Intent
struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Hell Timer 설정"
    static var description = IntentDescription("디아블로4 이벤트 타이머")

    @Parameter(title: "표시할 이벤트", default: .all)
    var displayMode: DisplayMode
}
