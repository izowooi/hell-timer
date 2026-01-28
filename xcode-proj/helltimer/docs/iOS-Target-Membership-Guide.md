# iOS Target Membership 가이드 (Android 개발자를 위한)

## iOS Target vs Android Module 비교

| iOS (Xcode) | Android (Gradle) |
|-------------|------------------|
| **Target** | **Module** (`:app`, `:feature`, etc.) |
| Target Membership | `implementation project(":shared")` |
| Widget Extension Target | 별도 모듈 (`:widget`) |
| App Groups (IPC) | ContentProvider / SharedPreferences |

## Target이란?

Xcode에서 **Target**은 빌드할 제품(앱, 위젯, 테스트 등)을 정의합니다. Android의 Gradle 모듈과 유사한 개념입니다.

```
helltimer.xcodeproj
├── helltimer (Target: 메인 앱)
├── HellTimerWidgetExtension (Target: 위젯/Live Activity)
├── helltimerTests (Target: 유닛 테스트)
└── helltimerUITests (Target: UI 테스트)
```

## Target Membership이란?

Xcode에서는 **하나의 소스 파일을 여러 Target에서 공유**할 수 있습니다. 이것이 Target Membership입니다.

### 설정 방법

1. Xcode 좌측 파일 네비게이터에서 파일 선택
2. 우측 **File Inspector** 열기 (단축키: `⌥⌘1`)
3. **Target Membership** 섹션에서 원하는 Target 체크박스 활성화

### 예시

```
WorldBossLiveActivity.swift
├── ☑ helltimer (메인 앱)           ← 체크됨
└── ☑ HellTimerWidgetExtension     ← 체크 필요
```

### Android와의 비교

Android에서 모듈 간 코드 공유:
```kotlin
// :widget 모듈의 build.gradle.kts
dependencies {
    implementation(project(":shared"))  // 공통 모듈 의존성 추가
}
```

iOS에서는 파일의 Target Membership 체크박스만 활성화하면 됩니다. 별도의 공통 모듈 없이도 파일을 여러 Target에서 공유할 수 있어서 이 부분은 더 간단합니다.

## Live Activity (다이나믹 아일랜드) 아키텍처

### 구성 요소

| 구성 요소 | 위치 | 역할 |
|----------|------|------|
| `ActivityAttributes` | 양쪽 Target | 데이터 모델 정의 |
| `LiveActivityManager` | 메인 앱 | Activity 시작/종료 제어 |
| `WorldBossLiveActivity` | Widget Extension | UI 렌더링 |
| `WidgetBundle` | Widget Extension | Widget/LiveActivity 등록 |

### 동작 흐름

```
┌─────────────────────┐                      ┌──────────────────────────┐
│      메인 앱         │                      │    Widget Extension      │
│                     │                      │                          │
│  LiveActivityManager │  Activity.request() │  WorldBossLiveActivity   │
│         │           │ ──────────────────→  │         │                │
│         ↓           │                      │         ↓                │
│  Activity 시작/종료   │     App Groups      │  다이나믹 아일랜드 렌더링   │
│                     │ ←─────────────────→  │  잠금화면 Live Activity   │
└─────────────────────┘    (데이터 공유)       └──────────────────────────┘
```

### 필수 파일의 Target Membership

Live Activity가 동작하려면 다음 파일들이 **양쪽 Target 모두**에 포함되어야 합니다:

| 파일 | 메인 앱 | Widget Extension |
|------|--------|------------------|
| `WorldBossActivityAttributes.swift` | ☑ | ☑ |
| `WorldBossLiveActivity.swift` | ☑ | ☑ |
| `LiveActivityManager.swift` | ☑ | ☐ (메인 앱만) |

## WidgetBundle 등록

Widget Extension에서 Live Activity를 사용하려면 `WidgetBundle`에 등록해야 합니다:

```swift
@main
struct HellTimerWidgetBundle: WidgetBundle {
    var body: some Widget {
        WorldBossWidget()
        SanctuaryWidget()
        if #available(iOS 16.1, *) {
            WorldBossLiveActivity()  // Live Activity 등록
        }
    }
}
```

## Live Activity 기기 요구사항

| 기능 | 최소 요구사항 |
|------|-------------|
| 다이나믹 아일랜드 | iPhone 14 Pro / Pro Max 이상 |
| 잠금화면 Live Activity | iOS 16.1+ (iPhone 8 이상) |

## 체크리스트

Live Activity가 동작하지 않을 때 확인할 사항:

- [ ] `Info.plist`에 `NSSupportsLiveActivities = YES` 설정
- [ ] `ActivityAttributes` 파일이 양쪽 Target에 포함
- [ ] `LiveActivity` 위젯 파일이 Widget Extension Target에 포함
- [ ] `WidgetBundle`에 Live Activity 등록
- [ ] 앱 설정에서 Live Activity 활성화
- [ ] iOS 설정 > 앱 > Live Activities 허용
- [ ] 지원 기기인지 확인 (다이나믹 아일랜드: iPhone 14 Pro+)

## 참고 자료

- [Apple Developer - ActivityKit](https://developer.apple.com/documentation/activitykit)
- [Human Interface Guidelines - Live Activities](https://developer.apple.com/design/human-interface-guidelines/live-activities)
