//
//  WorldBossActivityAttributes.swift
//  helltimer
//
//  Live Activity 데이터 모델
//

import ActivityKit
import Foundation

/// 월드보스 Live Activity 속성
struct WorldBossActivityAttributes: ActivityAttributes {

    /// 동적 상태 (실시간 업데이트 가능)
    public struct ContentState: Codable, Hashable {
        /// 월드보스 시작 시간
        var eventTime: Date
    }

    /// 이벤트 이름 (정적)
    var eventName: String = "World Boss"
}
