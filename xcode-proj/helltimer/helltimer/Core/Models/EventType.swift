import SwiftUI

/// 디아블로4 월드 이벤트 타입
enum EventType: String, CaseIterable, Codable {
    case helltide = "helltide"
    case legion = "legion"
    case worldBoss = "worldBoss"

    /// 한국어 표시명
    var displayName: String {
        switch self {
        case .helltide:
            return "지옥물결"
        case .legion:
            return "군단"
        case .worldBoss:
            return "월드보스"
        }
    }

    /// SF Symbol 아이콘 이름
    var iconName: String {
        switch self {
        case .helltide:
            return "flame.fill"
        case .legion:
            return "person.3.fill"
        case .worldBoss:
            return "crown.fill"
        }
    }

    /// 이벤트별 테마 색상
    var color: Color {
        switch self {
        case .helltide:
            return Color(red: 1.0, green: 0.27, blue: 0.27) // #FF4444
        case .legion:
            return Color(red: 0.6, green: 0.27, blue: 1.0) // #9944FF
        case .worldBoss:
            return Color(red: 1.0, green: 0.53, blue: 0.0) // #FF8800
        }
    }

    /// 이벤트 주기 (초)
    var intervalSeconds: TimeInterval {
        switch self {
        case .helltide:
            return 60 * 60 // 1시간 (55분 활성 + 5분 휴식)
        case .legion:
            return 25 * 60 // 25분
        case .worldBoss:
            return 210 * 60 // 3시간 30분
        }
    }
}
