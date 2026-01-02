# 디아블로4 월드 이벤트 알림 앱 개발 기술 문서

**공식 Blizzard API는 존재하지 않지만**, d4armory.io가 실시간 서버 데이터를 제공하는 사실상의 표준 API로 자리잡았습니다. 월드보스는 **3.5시간 주기**, 군단은 **25분 주기**, 지옥물결은 **매시 정각 시작 55분 지속** 패턴을 따르며, 이 고정된 타이밍을 기반으로 정확한 알림 앱 개발이 가능합니다.

---

## 핵심 이벤트 타이머 규칙 요약

디아블로4의 세 가지 주요 월드 이벤트는 모두 **글로벌 동기화**되어 전 세계 서버가 동일한 시간에 이벤트를 진행합니다. 아래 표는 각 이벤트의 핵심 타이밍 정보입니다.

| 이벤트 | 스폰 주기 | 지속 시간 | 사전 알림 |
|--------|-----------|-----------|-----------|
| **월드보스** | 3시간 30분 (210분) | 15분 | 60분 전 맵 표시, 15분 전 알림 |
| **군단 이벤트** | 25분 | 3-4분 | 10분 전 카운트다운 |
| **지옥물결** | 매시 정각 시작 | 55분 (5분 휴식) | 없음 (고정 스케줄) |

---

## 월드보스 스폰 시스템 상세

### 스폰 주기와 타이머 계산

월드보스는 **210분(3시간 30분)** 간격으로 스폰되며, 이는 시즌 2(2023년 10월) 패치 1.2.0에서 기존 6시간에서 단축된 것입니다. 하루에 약 **6-7회** 스폰되며, 마지막 확인된 스폰 시간을 기준점(anchor)으로 삼아 계산합니다.

```javascript
const SPAWN_INTERVAL_MS = 210 * 60 * 1000; // 3.5시간

function calculateNextWorldBoss(lastKnownSpawnTime) {
    const now = Date.now();
    const elapsed = now - lastKnownSpawnTime;
    const cyclesPassed = Math.floor(elapsed / SPAWN_INTERVAL_MS);
    return lastKnownSpawnTime + ((cyclesPassed + 1) * SPAWN_INTERVAL_MS);
}

function getTimeUntilNextBoss(lastKnownSpawnTime) {
    const nextSpawn = calculateNextWorldBoss(lastKnownSpawnTime);
    const remaining = nextSpawn - Date.now();
    return {
        hours: Math.floor(remaining / 3600000),
        minutes: Math.floor((remaining % 3600000) / 60000),
        seconds: Math.floor((remaining % 60000) / 1000)
    };
}
```

### 월드보스 종류와 스폰 위치

**현재 보스 (시즌 11 기준, 2025년 12월~)**:
- Ashava, the Pestilent (독 공격)
- Avarice, the Gold Cursed (보물상자 해머)
- Wandering Death, Death Given Life (영혼/뼈 공격)
- **Azmodan, Lord of Sin** (시즌 11 신규 추가, 화염 공격)

**스폰 위치 (6개)**:

| 위치명 | 지역 | 인접 웨이포인트 |
|--------|------|-----------------|
| The Crucible | 서리찬 봉우리 | Corbach |
| Caen Adar | 스코스글렌 | - |
| Saraan Caldera | 건조한 평원 | - |
| Seared Basin | 케지스탄 | - |
| Fields of Desecration | 하웨자르 | Zarbinzet |
| The Cauldron | 나한투 (VoH DLC) | Ichorfall |

### 보스 로테이션 패턴 (시즌 11 이전, 3보스 시스템)

보스는 **3-2-3-2 반복 패턴**을 따랐습니다:

```javascript
const BOSS_ORDER = ['Wandering Death', 'Avarice', 'Ashava'];
const REPEAT_PATTERN = [3, 2, 3, 2]; // 연속 등장 횟수

function getBossForSpawnIndex(spawnIndex) {
    let bossIdx = 0, count = 0, patternIdx = 0;
    
    for (let i = 0; i < spawnIndex; i++) {
        count++;
        if (count >= REPEAT_PATTERN[patternIdx % REPEAT_PATTERN.length]) {
            count = 0;
            bossIdx = (bossIdx + 1) % BOSS_ORDER.length;
            patternIdx++;
        }
    }
    return BOSS_ORDER[bossIdx];
}
```

**시즌 11부터 Azmodan 추가**로 4보스 로테이션이 되었으나, 정확한 패턴은 아직 커뮤니티에서 분석 중입니다.

---

## 군단 이벤트(Gathering Legions) 스폰 시스템

### 스폰 주기와 타이머

군단 이벤트는 **25분 간격**으로 발생하며(시즌 2에서 30분→25분으로 단축), 시작 **10분 전**에 맵에 카운트다운이 표시됩니다.

```javascript
const LEGION_INTERVAL_MS = 25 * 60 * 1000; // 25분

function calculateNextLegion(lastKnownSpawnTime) {
    const now = Date.now();
    const elapsed = now - lastKnownSpawnTime;
    const cyclesPassed = Math.floor(elapsed / LEGION_INTERVAL_MS);
    return lastKnownSpawnTime + ((cyclesPassed + 1) * LEGION_INTERVAL_MS);
}
```

### 스폰 위치 (10개)

군단 위치는 월드보스와 달리 **랜덤 선택**되며, 일부는 거점 클리어가 필요합니다:

| 지역 | 위치 | 보스 | 거점 필요 |
|------|------|------|----------|
| 서리찬 봉우리 | Kor Dragan | Blood Bishop | ✅ |
| 스코스글렌 | Carrowcrest Ruins | Khazra Abomination | ❌ |
| 건조한 평원 | Norgoi Vigil | Khazra Abomination | ❌ |
| 건조한 평원 | Temple of Rot | - | ✅ |
| 케지스탄 | Dilapidated Aqueducts | Drowned Seahag | ❌ |
| 케지스탄 | Alcarnus | Tomb Lord | ✅ |
| 하웨자르 | Haunted Wreckage | Drowned Seahag | ❌ |
| 하웨자르 | Crusader's Monument | Tomb Lord | ✅ |
| 나한투 | Chakir 지역 | Soul Basin 호위 | ✅ |
| 나한투 | Central Nahantu | Soul Basin 호위 | ❌ |

### 이벤트 진행 구조

총 **3-4분** 소요되며, 3명의 Servant of Hell을 처치 후 최종 보스(Overlord)와 전투합니다. 각 Servant 처치 시 **Radiant Chest** 1개를 획득하여 최대 3개까지 보상을 받을 수 있습니다.

---

## 지옥물결(Helltide) 스폰 시스템

### 활성화 주기 (시즌 4 이후 현재 시스템)

지옥물결은 **매시 정각에 시작**하여 **55분간 지속**, 이후 **5분 휴식** 후 다음 시간 정각에 재시작됩니다. 이 단순한 패턴으로 인해 타이머 계산이 매우 용이합니다.

```javascript
function getHelltideStatus() {
    const now = new Date();
    const minutes = now.getMinutes();
    const seconds = now.getSeconds();
    
    if (minutes < 55) {
        return {
            isActive: true,
            remainingMinutes: 54 - minutes,
            remainingSeconds: 60 - seconds,
            nextBreakIn: (55 - minutes) * 60 - seconds
        };
    } else {
        return {
            isActive: false,
            nextStartMinutes: 60 - minutes - 1,
            nextStartSeconds: 60 - seconds,
            nextStartIn: (60 - minutes) * 60 - seconds
        };
    }
}

// 간단한 상태 체크
const isHelltideActive = () => new Date().getMinutes() < 55;
```

### 존 로테이션과 미스터리 상자

**활성화 지역 (6개)**: 서리찬 봉우리, 건조한 평원, 스코스글렌, 하웨자르, 케지스탄, 나한투(VoH DLC)

- 각 지옥물결당 **단일 지역 내 4개 존**이 활성화
- **미스터리 상자**: 일반 지역 2개, 케지스탄 3개 동시 활성
- 존 선택은 **서버 측 결정**으로 클라이언트에서 예측 불가 → 커뮤니티 리포트 필요

### 저주받은 의식(Accursed Ritual)과 피의 여인(Blood Maiden)

시즌 4에서 추가된 콘텐츠로, **플레이어가 직접 트리거**하는 이벤트입니다:

- **요구 조건**: Baneful Hearts 3개 (미스터리 상자, Hellborne 적 처치 시 획득)
- **고정 위치**: 각 지역당 1개씩 총 5개 의식 장소
- **보스**: Blood Maiden - 웨이브 클리어 후 등장

---

## 시즌별 주요 변경 이력

| 시즌/패치 | 날짜 | 변경 내용 |
|----------|------|-----------|
| **런칭** | 2023.06 | 월드보스 6시간 주기, 지옥물결 2시간 15분 주기 |
| **시즌 2** | 2023.10 | 월드보스 3.5시간으로 단축, 군단 25분으로 단축 |
| **시즌 3** | 2024.01 | 지옥물결 55분/5분 주기로 변경 (거의 상시 활성화) |
| **시즌 4** | 2024.05 | 지옥물결 모든 월드 티어에서 활성화, 피의 여인 추가 |
| **VoH DLC** | 2024.10 | 나한투 지역 추가 (월드보스/군단/지옥물결 위치 추가) |
| **시즌 11** | 2025.12 | Azmodan 월드보스 추가 (4보스 로테이션) |

---

## API 및 데이터 소스

### 공식 Blizzard API 현황

**2026년 1월 현재, 공식 디아블로4 API는 존재하지 않습니다.** Battle.net Developer Portal(develop.battle.net)은 WoW, 디아블로3, 스타크래프트2, 하스스톤만 지원하며, 커뮤니티의 지속적인 요청에도 Blizzard는 D4 API 제공 계획을 발표하지 않았습니다.

### d4armory.io API (권장)

**가장 신뢰할 수 있는 데이터 소스**로, 서버에서 직접 데이터를 수집합니다. Maxroll.gg를 포함한 대부분의 커뮤니티 도구가 이 API를 사용합니다.

**Base URL**: `https://d4armory.io/api/`

**엔드포인트**:
| 엔드포인트 | 설명 | 인증 |
|-----------|------|------|
| `/api/events/recent` | 현재/다음 이벤트 정보 | 불필요 |
| `/api/events/all` | 모든 이벤트 데이터 | 불필요 |

**응답 JSON 구조**:
```json
{
  "boss": {
    "expectedName": "Wandering Death",
    "expected": 1735776000,
    "territory": "Dry Steppes",
    "zone": "Fields of Hatred"
  },
  "helltide": {
    "timestamp": 1735772400,
    "zone": "Hawezar",
    "territory": "Umir Plateau"
  },
  "legion": {
    "expected": 1735780000,
    "territory": "Scosglen"
  }
}
```

### diablo4.life API

**커뮤니티 소싱 방식**으로, 플레이어들의 리포트를 수집합니다.

**엔드포인트**:
- `https://diablo4.life/api/trackers/helltide/reportHistory`
- `https://diablo4.life/api/trackers/worldBoss/reportHistory`

**응답 JSON 구조**:
```json
{
  "reports": [
    {
      "reportTime": 1735772400000,
      "spawnTime": 1735772400000,
      "name": "Helltide",
      "location": "Hawezar",
      "user": { "displayName": "PlayerName" }
    }
  ]
}
```

### helltides.com

공개 API는 없지만 **Discord 봇**을 제공합니다:
- `/helltide`, `/worldboss`, `/legion` - 현재 이벤트 상태
- `/schedule` - 24시간 스케줄
- `/subscribe` - 채널 자동 알림 설정

---

## 앱 개발 구현 가이드

### 권장 데이터 수집 전략

```javascript
// 앱 설정 상수
const CONFIG = {
    API_PRIMARY: 'https://d4armory.io/api/events/recent',
    API_SECONDARY: 'https://diablo4.life/api/trackers/',
    POLL_INTERVAL: 180000, // 3분
    
    // 이벤트 타이밍
    WORLD_BOSS_INTERVAL: 210 * 60 * 1000,    // 3.5시간
    LEGION_INTERVAL: 25 * 60 * 1000,          // 25분
    HELLTIDE_DURATION: 55,                     // 분
    HELLTIDE_BREAK: 5                          // 분
};

// 이벤트 데이터 fetch
async function fetchEvents() {
    try {
        const response = await fetch(CONFIG.API_PRIMARY);
        if (!response.ok) throw new Error('Primary API failed');
        return await response.json();
    } catch (error) {
        // Fallback: 계산 기반 타이머 사용
        return calculateEventsFromPattern();
    }
}

// 계산 기반 Fallback
function calculateEventsFromPattern() {
    const now = Date.now();
    return {
        helltide: {
            isActive: new Date().getMinutes() < 55,
            nextStart: getNextHourStart()
        },
        // 마지막 알려진 앵커 타임 필요
        boss: null,
        legion: null
    };
}
```

### 푸시 알림 구현

```javascript
// 알림 스케줄링
function scheduleNotifications(events) {
    const now = Date.now();
    
    // 월드보스: 15분 전, 5분 전 알림
    if (events.boss?.expected) {
        const bossTime = events.boss.expected * 1000;
        scheduleNotification(bossTime - 15 * 60000, {
            title: '월드보스 15분 전!',
            body: `${events.boss.expectedName} - ${events.boss.territory}`
        });
        scheduleNotification(bossTime - 5 * 60000, {
            title: '월드보스 5분 전!',
            body: `${events.boss.expectedName} 곧 스폰됩니다!`
        });
    }
    
    // 지옥물결: 매시 시작 알림
    if (!isHelltideActive()) {
        const nextHelltide = getNextHourStart();
        scheduleNotification(nextHelltide - 5 * 60000, {
            title: '지옥물결 5분 후 시작',
            body: '새로운 지옥물결이 곧 시작됩니다'
        });
    }
}
```

### 권장 기술 스택

| 구성 요소 | 권장 기술 | 이유 |
|----------|----------|------|
| **모바일 앱** | React Native / Flutter | 크로스플랫폼, 푸시 알림 지원 |
| **웹 프론트엔드** | Next.js / React | diablo4.life가 검증한 스택 |
| **백엔드** | Node.js / Python FastAPI | REST API 및 WebSocket 지원 |
| **실시간 DB** | Redis | 이벤트 캐싱 및 빠른 조회 |
| **푸시 알림** | Firebase Cloud Messaging | 모바일/웹 통합 지원 |
| **스케줄링** | node-cron / Celery | 정기적 API 폴링 |

### 중요 구현 고려사항

1. **글로벌 동기화**: 모든 서버가 동일한 시간에 이벤트 진행 → 타임존 변환만 필요
2. **DST 처리**: 서머타임 전환 시 타이머 계산 주의
3. **Rate Limiting**: API 호출 간격 최소 2-3분 권장
4. **Fallback 로직**: API 실패 시 계산 기반 타이머로 전환
5. **앵커 타임 관리**: 월드보스/군단은 마지막 확인된 스폰 시간 저장 필요

---

## 기존 트래커 사이트 데이터 수집 방식 비교

| 사이트 | 데이터 소스 | 정확도 | API 제공 |
|--------|------------|--------|---------|
| **d4armory.io** | 서버 직접 연결 | ★★★★★ | ✅ 공개 REST API |
| **helltides.com** | 패턴 계산 + 커뮤니티 | ★★★★☆ | ❌ Discord 봇만 |
| **diablo4.life** | 커뮤니티 리포트 | ★★★☆☆ | ✅ 리포트 API |

**d4armory.io가 가장 신뢰할 수 있는 데이터 소스**이며, 이를 Primary로 사용하고 자체 계산 로직을 Fallback으로 구현하는 것이 권장됩니다.

---

## 결론: 앱 개발 핵심 전략

디아블로4 월드 이벤트 알림 앱 개발에서 가장 중요한 포인트는 **d4armory.io API를 Primary 데이터 소스로 활용**하면서, **고정된 타이밍 패턴(지옥물결 매시 정각, 군단 25분)을 기반으로 Fallback 계산 로직을 구현**하는 것입니다.

월드보스는 3.5시간 주기와 보스 로테이션 패턴이 존재하지만, 정확한 위치와 보스 종류는 API 의존이 필요합니다. 반면 지옥물결은 완전히 예측 가능한 스케줄을 따르므로 오프라인에서도 정확한 알림이 가능합니다.

모바일 앱 개발 시 **Firebase Cloud Messaging**을 통한 푸시 알림과, **Redis 캐싱**을 통한 빠른 응답이 사용자 경험을 크게 향상시킬 것입니다. Discord 봇 연동도 게이머 커뮤니티 특성상 매우 효과적인 배포 채널이 될 수 있습니다.