# Hell Timer - 디아블로4 월드 이벤트 알림 앱 PRD

## 1. 프로젝트 개요

### 1.1 앱 이름
- **Hell Timer** (helltimer)

### 1.2 목적
디아블로4 플레이어가 월드보스, 지옥물결, 군단 이벤트의 타이밍을 놓치지 않도록 직관적인 위젯과 알림을 제공하는 iOS 앱

### 1.3 핵심 가치
- **오프라인 우선**: 비행기 모드에서도 완벽 동작
- **위젯 중심**: 앱 실행 없이 한눈에 이벤트 확인
- **선택적 알림**: 원하는 이벤트만 알림 수신

---

## 2. 기능 요구사항

### 2.1 이벤트 타이머 시스템

#### 2.1.1 지옥물결 (Helltide)
| 항목 | 상세 |
|------|------|
| 계산 방식 | 로컬 계산 (100% 예측 가능) |
| 주기 | 매시 정각 시작, 55분 지속, 5분 휴식 |
| 표시 정보 | 활성 상태, 남은 시간, 다음 시작 시간 |

#### 2.1.2 군단 이벤트 (Legion)
| 항목 | 상세 |
|------|------|
| 계산 방식 | 로컬 계산 (앵커 타임 기반) |
| 주기 | 25분 간격 |
| 앵커 관리 | **사용자가 마지막으로 본 군단 시간 직접 입력** |
| 표시 정보 | 다음 이벤트까지 남은 시간 |

#### 2.1.3 월드보스 (World Boss)
| 항목 | 상세 |
|------|------|
| 계산 방식 | API 우선, 로컬 Fallback |
| 주기 | 210분 (3시간 30분) 간격 |
| API | `https://diablo4.life/api/trackers/worldBoss/reportHistory` |
| 표시 정보 | 보스 이름, 위치, 다음 스폰까지 남은 시간 |
| 보스 종류 | Ashava, Avarice, Wandering Death, Azmodan |

### 2.2 위젯 시스템

#### 2.2.1 Small Widget (홈스크린용)
- 가장 임박한 1개 이벤트 표시
- 이벤트 아이콘 + 남은 시간 카운트다운
- 활성 상태 표시 (지옥물결이 진행 중일 경우)

#### 2.2.2 Medium Widget
- 3가지 이벤트 모두 한눈에 표시
- 각 이벤트별 남은 시간
- 월드보스의 경우 보스 이름 표시

#### 2.2.3 Large Widget
- 3가지 이벤트 상세 정보
- 월드보스: 보스 이름 + 스폰 위치
- 다음 2~3개 이벤트 일정 미리보기
- 마지막 동기화 시간 표시

### 2.3 알림 시스템

#### 2.3.1 알림 설정
- **이벤트별 개별 ON/OFF**: 월드보스, 지옥물결, 군단 각각 선택
- **알림 시간 사용자 설정**: 1분, 5분, 10분, 15분, 30분 중 선택 (다중 선택 가능)
- **무알림**: 하나도 등록하지 않으면 알림 없음

#### 2.3.2 알림 내용
```
[월드보스] Wandering Death - 5분 후 스폰!
위치: Fields of Desecration

[지옥물결] 새로운 지옥물결 시작!
55분간 진행됩니다

[군단] 군단 이벤트 10분 후 시작!
```

### 2.4 메인 앱 화면

#### 2.4.1 대시보드 (메인 화면)
- 3가지 이벤트 카드 형태로 표시
- 실시간 카운트다운
- Pull-to-refresh로 월드보스 API 새로고침

#### 2.4.2 설정 화면
- 알림 ON/OFF 토글 (이벤트별)
- 알림 시간 설정 (다중 선택)
- 군단 앵커 타임 입력 (날짜/시간 선택기)
- 월드보스 앵커 타임 입력 (Fallback용)
- 테마: 시스템 설정 따름 (다크/라이트 자동 전환)

---

## 3. 기술 요구사항

### 3.1 개발 환경
| 항목 | 상세 |
|------|------|
| 언어 | Swift 5.0+ |
| UI 프레임워크 | SwiftUI |
| 데이터 저장 | SwiftData |
| 최소 iOS | iOS 17.0+ (WidgetKit 최신 기능) |
| 아키텍처 | MVVM + Repository Pattern |

### 3.2 SOLID 원칙 적용

#### 3.2.1 Single Responsibility
- `HelltideCalculator`: 지옥물결 시간 계산만 담당
- `LegionCalculator`: 군단 시간 계산만 담당
- `WorldBossService`: 월드보스 API + Fallback 담당
- `NotificationManager`: 알림 스케줄링만 담당
- `SettingsRepository`: 사용자 설정 저장/로드만 담당

#### 3.2.2 Open/Closed
- `EventProtocol`: 모든 이벤트가 준수하는 프로토콜
- 새 이벤트 추가 시 기존 코드 수정 없이 확장 가능

#### 3.2.3 Liskov Substitution
- `Helltide`, `Legion`, `WorldBoss` 모두 `GameEvent` 프로토콜 대체 가능

#### 3.2.4 Interface Segregation
- `TimeCalculatable`: 시간 계산 인터페이스
- `APIFetchable`: API 호출 인터페이스
- `Notifiable`: 알림 가능 인터페이스

#### 3.2.5 Dependency Inversion
- Service 클래스들은 Protocol에 의존
- DI Container 통한 의존성 주입

### 3.3 비행기 모드 지원
- 지옥물결, 군단: 100% 오프라인 동작
- 월드보스: 마지막 API 응답 캐싱 + 로컬 계산 Fallback
- UserDefaults에 앵커 타임 영구 저장

### 3.4 테스트 요구사항

#### 3.4.1 Unit Tests
- `HelltideCalculatorTests`: 지옥물결 계산 정확성
- `LegionCalculatorTests`: 군단 계산 정확성 (앵커 타임 기반)
- `WorldBossCalculatorTests`: 월드보스 Fallback 계산
- `NotificationSchedulerTests`: 알림 스케줄링 로직

#### 3.4.2 Integration Tests
- API 응답 파싱 테스트
- 오프라인 Fallback 동작 테스트

#### 3.4.3 UI Tests
- 위젯 렌더링 테스트
- 설정 화면 상호작용 테스트

---

## 4. 데이터 모델

### 4.1 Event Models
```swift
protocol GameEvent {
    var eventType: EventType { get }
    var nextEventTime: Date { get }
    var isActive: Bool { get }
    var displayName: String { get }
}

enum EventType: String, CaseIterable {
    case helltide = "지옥물결"
    case legion = "군단"
    case worldBoss = "월드보스"
}

struct WorldBossInfo {
    let name: String        // "Wandering Death"
    let location: String    // "Fields of Desecration"
    let spawnTime: Date
}
```

### 4.2 Settings Model
```swift
struct UserSettings: Codable {
    var helltideNotificationEnabled: Bool
    var legionNotificationEnabled: Bool
    var worldBossNotificationEnabled: Bool
    var notificationMinutesBefore: [Int]  // [5, 15]
    var legionAnchorTime: Date?
    var worldBossAnchorTime: Date?
}
```

---

## 5. 프로젝트 구조

```
helltimer/
├── App/
│   └── helltimerApp.swift
├── Features/
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   └── DashboardViewModel.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   └── SettingsViewModel.swift
│   └── Shared/
│       └── EventCardView.swift
├── Core/
│   ├── Models/
│   │   ├── GameEvent.swift
│   │   ├── Helltide.swift
│   │   ├── Legion.swift
│   │   └── WorldBoss.swift
│   ├── Services/
│   │   ├── EventCalculators/
│   │   │   ├── HelltideCalculator.swift
│   │   │   ├── LegionCalculator.swift
│   │   │   └── WorldBossCalculator.swift
│   │   ├── Network/
│   │   │   ├── APIClient.swift
│   │   │   └── WorldBossAPIService.swift
│   │   └── Notification/
│   │       └── NotificationManager.swift
│   ├── Repositories/
│   │   └── SettingsRepository.swift
│   └── Protocols/
│       ├── TimeCalculatable.swift
│       └── APIFetchable.swift
├── Widget/
│   ├── HellTimerWidget.swift
│   ├── SmallWidgetView.swift
│   ├── MediumWidgetView.swift
│   └── LargeWidgetView.swift
├── Resources/
│   ├── Assets.xcassets/
│   └── Localizable.strings
└── Tests/
    ├── HelltideCalculatorTests.swift
    ├── LegionCalculatorTests.swift
    ├── WorldBossCalculatorTests.swift
    └── NotificationManagerTests.swift
```

---

## 6. API 명세

### 6.1 World Boss API
**Endpoint**: `GET https://diablo4.life/api/trackers/worldBoss/reportHistory`

**Response Example**:
```json
{
  "reports": [
    {
      "reportTime": 1735772400000,
      "spawnTime": 1735772400000,
      "name": "Wandering Death",
      "location": "Fields of Desecration"
    }
  ]
}
```

### 6.2 Helltide API (참고용, 로컬 계산 우선)
**Endpoint**: `GET https://diablo4.life/api/trackers/helltide/reportHistory`

---

## 7. 위젯 디자인 가이드

### 7.1 컬러 스킴
| 이벤트 | 색상 | HEX |
|--------|------|-----|
| 지옥물결 | 붉은색 | #FF4444 |
| 군단 | 보라색 | #9944FF |
| 월드보스 | 주황색 | #FF8800 |
| 배경 | 시스템 | 다크/라이트 자동 |

### 7.2 SF Symbols 아이콘
| 이벤트 | SF Symbol |
|--------|-----------|
| 지옥물결 | flame.fill |
| 군단 | person.3.fill |
| 월드보스 | crown.fill |

---

## 8. 구현 우선순위

### Phase 1: Core (MVP)
1. 이벤트 계산 로직 구현 (Helltide, Legion, WorldBoss)
2. 메인 대시보드 UI
3. 기본 설정 화면

### Phase 2: Widget
4. Widget Extension 추가
5. Small/Medium/Large 위젯 구현
6. App Group 설정 (앱-위젯 데이터 공유)

### Phase 3: Notification
7. Local Notification 구현
8. 알림 스케줄링 로직
9. 알림 설정 UI

### Phase 4: Polish
10. 단위 테스트 작성
11. UI 테스트 작성
12. 에러 처리 및 엣지 케이스

---

## 9. 타이머 계산 로직

### 9.1 지옥물결 (100% 예측 가능)
```swift
// 매시 정각 시작, 55분 지속, 5분 휴식
func getHelltideStatus() -> HelltideStatus {
    let now = Date()
    let calendar = Calendar.current
    let minutes = calendar.component(.minute, from: now)

    if minutes < 55 {
        // 활성 상태: 55 - 현재분 = 남은 시간
        return HelltideStatus(
            isActive: true,
            remainingMinutes: 54 - minutes,
            nextStartTime: nil
        )
    } else {
        // 휴식 상태: 다음 정각까지
        return HelltideStatus(
            isActive: false,
            remainingMinutes: nil,
            nextStartTime: calendar.nextDate(
                after: now,
                matching: DateComponents(minute: 0),
                matchingPolicy: .nextTime
            )
        )
    }
}
```

### 9.2 군단 (앵커 타임 기반)
```swift
// 25분 주기
let LEGION_INTERVAL: TimeInterval = 25 * 60

func getNextLegion(anchorTime: Date) -> Date {
    let now = Date()
    let elapsed = now.timeIntervalSince(anchorTime)
    let cyclesPassed = Int(elapsed / LEGION_INTERVAL)
    return anchorTime.addingTimeInterval(Double(cyclesPassed + 1) * LEGION_INTERVAL)
}
```

### 9.3 월드보스 (API + Fallback)
```swift
// 210분 (3.5시간) 주기
let WORLD_BOSS_INTERVAL: TimeInterval = 210 * 60

func getNextWorldBoss(lastKnownSpawn: Date) -> Date {
    let now = Date()
    let elapsed = now.timeIntervalSince(lastKnownSpawn)
    let cyclesPassed = Int(elapsed / WORLD_BOSS_INTERVAL)
    return lastKnownSpawn.addingTimeInterval(Double(cyclesPassed + 1) * WORLD_BOSS_INTERVAL)
}
```

---

## 10. 제약 사항 및 고려사항

1. **API Rate Limiting**: diablo4.life API 호출은 3분 간격 권장
2. **위젯 갱신 주기**: iOS 위젯은 시스템이 갱신 시점 결정 (Timeline Provider 사용)
3. **백그라운드 제한**: iOS 백그라운드 제한으로 정확한 타이밍 알림은 Local Notification 필수
4. **시간대 처리**: 모든 이벤트는 글로벌 동기화 → UTC 기준 계산 후 로컬 시간대 표시
5. **앵커 타임 영구 저장**: UserDefaults (App Group) 사용하여 앱 종료 후에도 유지

---

## 11. 초기 앵커 타임 (참고용)

| 이벤트 | 앵커 타임 | 비고 |
|--------|-----------|------|
| 군단 | 2025-01-02 20:35 KST | 사용자 입력으로 업데이트 |
| 월드보스 | 2025-01-02 21:15 KST | API 또는 사용자 입력으로 업데이트 |
