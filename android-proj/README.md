# Hell Timer - Diablo 4 이벤트 타이머

<div align="center">

[![Kotlin](https://img.shields.io/badge/Kotlin-1.9-purple?style=for-the-badge&logo=kotlin)](https://kotlinlang.org/)
[![Jetpack Compose](https://img.shields.io/badge/Jetpack_Compose-1.5-green?style=for-the-badge&logo=jetpackcompose)](https://developer.android.com/jetpack/compose)
[![Android](https://img.shields.io/badge/Android-11+-3DDC84?style=for-the-badge&logo=android)](https://developer.android.com/)
[![Glance](https://img.shields.io/badge/Glance-Widget-blue?style=for-the-badge&logo=android)](https://developer.android.com/jetpack/compose/glance)

**Diablo 4의 주요 이벤트 시간을 놓치지 마세요!**

[이벤트 규칙](#-이벤트-시간-규칙) | [기술 스택](#%EF%B8%8F-기술-스택) | [프로젝트 구조](#-프로젝트-구조) | [위젯](#-위젯-시스템)

</div>

---

## 프로젝트 소개

Hell Timer는 **Diablo 4의 주요 월드 이벤트 시간을 추적하는 Android 앱**입니다.

지옥물결, 군단, 월드보스 세 가지 이벤트의 다음 시작 시간을 실시간으로 계산하고, 홈 화면 위젯과 푸시 알림으로 편리하게 확인할 수 있습니다.

### 주요 기능

- **실시간 타이머** - 세 가지 이벤트의 남은 시간 및 다음 시작 시간 표시
- **홈 화면 위젯** - Glance 기반 위젯으로 앱 실행 없이 확인
- **푸시 알림** - 이벤트 시작 전 알림 (1, 5, 10, 15, 30분 전)
- **오프라인 동작** - 네트워크 없이 100% 로컬 계산
- **글로벌 동기화** - UTC 기반으로 전 세계 동일한 시간 표시

---

## 이벤트 시간 규칙

Hell Timer는 세 가지 Diablo 4 월드 이벤트의 시간을 추적합니다. 각 이벤트는 고유한 주기와 계산 방식을 가지고 있습니다.

### 이벤트 비교 요약

| 이벤트 | 주기 | 계산 방식 | 특징 |
|:------:|:----:|:---------:|:----:|
| 지옥물결 | 60분 | 로컬 시간 | 매시 정각 시작 |
| 군단 | 25분 | UTC 앵커 | 전 세계 동기화 |
| 월드보스 | 105분 | UTC 앵커 | 하루 약 14회 |

---

### 1. 지옥물결 (Helltide)

지옥물결은 **가장 예측하기 쉬운 이벤트**입니다. 매 시간 정각에 시작하여 55분간 지속됩니다.

#### 규칙

| 항목 | 값 |
|:----:|:--:|
| 주기 | 60분 (1시간) |
| 활성 시간 | 00분 ~ 54분 (55분간) |
| 휴식 시간 | 55분 ~ 59분 (5분간) |
| 계산 기준 | 로컬 시간의 분(minute) |

#### 시간 사이클

```
┌─────────────────────────────────────────────────────────────┐
│  00:00                                    54:59   55:00  59:59
│    ├──────────── 활성 (55분) ──────────────┤├── 휴식 (5분) ──┤
│    🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥│     💤💤💤     │
└─────────────────────────────────────────────────────────────┘
```

#### 계산 로직

```kotlin
// HelltideCalculator.kt
fun getCurrentStatus(currentTimeSeconds: Long): HelltideEvent {
    val zonedDateTime = ZonedDateTime.ofInstant(
        Instant.ofEpochSecond(currentTimeSeconds),
        ZoneId.systemDefault()
    )
    val minutes = zonedDateTime.minute

    return if (minutes < 55) {
        // 활성 상태 (0~54분)
        HelltideEvent(isActive = true, remainingActiveTime = ...)
    } else {
        // 휴식 상태 (55~59분)
        HelltideEvent(isActive = false, nextEventTime = 다음 정각)
    }
}
```

---

### 2. 군단 (Legion)

군단은 **25분 고정 주기**로 발생하며, UTC 기반의 글로벌 타임스탬프를 사용합니다.

#### 규칙

| 항목 | 값 |
|:----:|:--:|
| 주기 | 25분 (1,500초) |
| 앵커 타임스탬프 | 1,200초 (1970-01-01 00:20:00 UTC) |
| 활성 시간 | 이벤트 시작 후 약 4분 |
| 계산 기준 | Unix 타임스탬프 |

#### 계산 공식

```
다음 이벤트 시간 = 앵커 + ⌈(현재 - 앵커) / 주기⌉ × 주기
```

#### 계산 로직

```kotlin
// LegionCalculator.kt
const val ANCHOR_TIMESTAMP = 1200L      // 고정 앵커
const val INTERVAL_SECONDS = 25L * 60   // 1500초

fun calculateNextEventTime(currentTimeSeconds: Long): Long {
    val elapsed = currentTimeSeconds - ANCHOR_TIMESTAMP
    val cyclesPassed = ceil(elapsed.toDouble() / INTERVAL_SECONDS).toLong()
    return ANCHOR_TIMESTAMP + (cyclesPassed * INTERVAL_SECONDS)
}
```

---

### 3. 월드보스 (World Boss)

월드보스는 **105분(1시간 45분) 주기**로 스폰되며, 하루에 약 13-14회 등장합니다.

#### 규칙

| 항목 | 값 |
|:----:|:--:|
| 주기 | 105분 (6,300초) |
| 앵커 타임스탬프 | 1,767,702,600 (2026-01-06 12:30 UTC) |
| 일일 횟수 | 약 13-14회 |
| 계산 기준 | Unix 타임스탬프 |

#### 계산 로직

```kotlin
// WorldBossCalculator.kt
const val ANCHOR_TIMESTAMP = 1767702600L  // 2026-01-06 12:30 UTC
const val INTERVAL_SECONDS = 105L * 60    // 6300초

fun calculateNextEventTime(currentTimeSeconds: Long): Long {
    val elapsed = currentTimeSeconds - ANCHOR_TIMESTAMP
    val cyclesPassed = ceil(elapsed.toDouble() / INTERVAL_SECONDS).toLong()
    return ANCHOR_TIMESTAMP + (cyclesPassed * INTERVAL_SECONDS)
}
```

---

## 기술 스택

<div align="center">

| 카테고리 | 기술 |
|:--------:|:----:|
| **언어** | Kotlin 1.9 |
| **UI 프레임워크** | Jetpack Compose |
| **위젯** | Glance (Compose 기반) |
| **알림** | AlarmManager + NotificationManager |
| **아키텍처** | MVVM |
| **데이터 저장** | DataStore Preferences |
| **최소 지원** | Android 11 (API 30)+ |

</div>

---

## 프로젝트 구조

```
android-proj/
├── 📂 app/src/main/java/com/izowooi/helltimer/
│   ├── 📄 HellTimerApplication.kt        # 앱 진입점
│   ├── 📄 MainActivity.kt                # Compose 호스트
│   │
│   ├── 📂 domain/
│   │   ├── 📂 model/
│   │   │   ├── 📄 EventType.kt           # 이벤트 타입 Enum
│   │   │   └── 📄 GameEvent.kt           # 이벤트 모델 (sealed interface)
│   │   └── 📂 calculator/
│   │       ├── 📄 HelltideCalculator.kt  # 지옥물결 계산
│   │       ├── 📄 LegionCalculator.kt    # 군단 계산
│   │       └── 📄 WorldBossCalculator.kt # 월드보스 계산
│   │
│   ├── 📂 presentation/
│   │   ├── 📂 theme/
│   │   │   ├── 📄 Color.kt               # 색상 정의
│   │   │   ├── 📄 Theme.kt               # 앱 테마
│   │   │   └── 📄 Type.kt                # 타이포그래피
│   │   └── 📂 dashboard/
│   │       ├── 📄 DashboardScreen.kt     # 메인 화면
│   │       ├── 📄 DashboardViewModel.kt  # ViewModel
│   │       └── 📂 components/
│   │           ├── 📄 EventCard.kt       # 이벤트 카드
│   │           ├── 📄 StatusBadge.kt     # 상태 배지
│   │           └── 📄 ActiveEventBanner.kt
│   │
│   ├── 📂 widget/
│   │   ├── 📄 HellTimerWidget.kt         # Glance 위젯
│   │   └── 📄 HellTimerWidgetReceiver.kt # 위젯 리시버
│   │
│   ├── 📂 notification/
│   │   ├── 📄 NotificationChannels.kt    # 알림 채널
│   │   ├── 📄 NotificationScheduler.kt   # 알림 스케줄러
│   │   ├── 📄 EventAlarmReceiver.kt      # 알람 리시버
│   │   └── 📄 BootReceiver.kt            # 부팅 완료 리시버
│   │
│   └── 📂 util/
│       └── 📄 TimeFormatter.kt           # 시간 포맷팅
│
├── 📂 app/src/main/res/
│   ├── 📂 drawable/                      # 이벤트 아이콘
│   ├── 📂 layout/                        # 위젯 레이아웃
│   ├── 📂 values/                        # strings, colors
│   ├── 📂 values-ko/                     # 한국어 리소스
│   └── 📂 xml/                           # 위젯 메타데이터
│
├── 📄 build.gradle.kts                   # 앱 빌드 설정
└── 📄 gradle/libs.versions.toml          # 버전 카탈로그
```

---

## 위젯 시스템

Hell Timer는 Glance API를 사용한 Compose 기반 홈 화면 위젯을 제공합니다.

### 지원 크기

| 크기 | 표시 내용 |
|:----:|:----------|
| **Small** | 월드보스 타이머 |
| **Medium** | 3개 이벤트 병렬 표시 |

### 위젯 갱신

```kotlin
// HellTimerWidget.kt
class HellTimerWidget : GlanceAppWidget() {

    override val sizeMode = SizeMode.Exact

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            GlanceTheme {
                WidgetContent()  // 실시간 이벤트 계산
            }
        }
    }
}
```

### 위젯 데이터 구조

위젯은 각 이벤트 Calculator를 직접 호출하여 실시간으로 시간을 계산합니다.

```kotlin
val helltide = HelltideCalculator.getCurrentStatus(currentTime)
val legion = LegionCalculator.getNextEvent(currentTime)
val worldBoss = WorldBossCalculator.getNextEvent(currentTime)
```

---

## 알림 시스템

### 알림 채널

| 채널 | 용도 |
|:----:|:-----|
| `helltide_channel` | 지옥물결 알림 |
| `legion_channel` | 군단 알림 |
| `worldboss_channel` | 월드보스 알림 |

### 알림 스케줄링

AlarmManager를 사용하여 정확한 시간에 알림을 전송합니다.

```kotlin
// NotificationScheduler.kt
alarmManager.setExactAndAllowWhileIdle(
    AlarmManager.RTC_WAKEUP,
    triggerTimeMillis,
    pendingIntent
)
```

### 부팅 시 재등록

```kotlin
// BootReceiver.kt
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            NotificationScheduler(context).scheduleAllNotifications()
        }
    }
}
```

---

## 빌드 방법

### 요구사항

- Android Studio Hedgehog 이상
- JDK 17
- Android SDK 34

### 빌드 명령어

```bash
# Debug APK 빌드
./gradlew assembleDebug

# Release APK 빌드
./gradlew assembleRelease

# 테스트 실행
./gradlew test
```

---

## 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다.

---

## 만든 사람

**izowooi**

궁금한 점이나 제안사항이 있으시면 Issue를 남겨주세요!

---

<div align="center">

**지옥물결이 시작됩니다! 준비하세요!**

Made with ❤️ for Diablo 4 Players

</div>
