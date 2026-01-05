# **디아블로 IV 군단 이벤트 기술 분석 및 실시간 추적 시스템 설계를 위한 포괄적 연구 보고서**

## **1\. 서론: 엔드게임 콘텐츠의 정형화와 데이터 추적의 필요성**

디아블로 IV(Diablo IV)의 라이브 서비스 환경에서 '군단 이벤트(Legion Event)'는 단순한 인게임 활동을 넘어, 플레이어의 성장 곡선과 자원 수급을 담당하는 핵심적인 서버 사이드 스케줄링 시스템으로 기능한다. 본 보고서는 서드파티 알림 애플리케이션 개발을 목표로, 군단 이벤트의 발생 메커니즘, 시공간적 패턴, 보상 체계, 그리고 최신 확장팩 '증오의 그릇(Vessel of Hatred)'에서의 변경 사항을 기술적 관점에서 심층 분석한다.

특히 본 연구는 2025년-2026년 시점의 최신 시즌 데이터를 기반으로 하며, 개발자가 즉시 코드화할 수 있는 수준의 알고리즘 명세와 데이터 스키마를 제공하는 데 중점을 둔다. 군단 이벤트는 월드 보스(World Boss)나 지옥물결(Helltide)과 달리 매우 짧은 간격의 고정 주기를 가지며, 이는 알림 서비스의 트래픽 설계와 사용자 경험(UX) 최적화에 결정적인 변수로 작용한다. 우리는 이 보고서를 통해 게임 클라이언트 내의 비정형 데이터를 정형화된 API 구조로 변환하는 논리적 프레임워크를 제시하고자 한다.

## **2\. 군단 이벤트의 시간적 결정론: 25분 주기 알고리즘**

애플리케이션의 핵심 기능인 '타이머'를 구현하기 위해서는 서버의 이벤트 스케줄링 로직을 역설계(Reverse Engineering)하여 수학적 모델로 정립해야 한다. 초기 시즌의 불규칙성과 달리, 현재의 군단 이벤트는 결정론적(Deterministic) 알고리즘에 의해 통제되고 있다.

### **2.1. 스폰 간격의 진화와 고정 주기 확립**

디아블로 IV 출시 초기, 군단 이벤트는 약 30분 내외의 가변적인 주기를 보여 예측 정확도가 떨어지는 경향이 있었다. 그러나 **시즌 2(피의 시즌)를 기점으로 블리자드는 군단 이벤트의 발생 주기를 '25분 고정 간격(Fixed 25-minute Interval)'으로 재설계하였다**.1 이러한 변경은 서버 부하 분산과 플레이어의 접속 유지율(Retention)을 고려한 조치로 해석되며, 알림 앱 개발자에게는 예측 가능한 상수를 제공한다는 점에서 매우 중요한 기술적 전환점이다.

이 25분 주기는 서버의 가동 시간(Uptime) 동안 끊임없이 반복되는 무한 루프 형태로 작동한다. 하루 24시간(1,440분)을 기준으로 계산할 때, 군단 이벤트는 이론적으로 하루에 **57.6회** 발생한다. 이는 월드 보스가 3.5시간(210분) 주기로 하루 약 6-7회 발생하는 것과 비교할 때 압도적으로 높은 빈도이며, 앱 설계 시 사용자가 피로감을 느끼지 않도록 알림 필터링 기능을 필수적으로 고려해야 함을 시사한다.3

### **2.2. 이벤트 상태 전이(State Transition) 타임라인**

정확한 알림을 위해서는 단순히 '시작 시간'을 아는 것만으로는 부족하다. 이벤트는 대기(Idle) \-\> 예고(Warning) \-\> 진행(Active) \-\> 종료(Cooldown)의 상태 변화를 겪으며, 앱은 각 단계에 맞는 UX를 제공해야 한다.

#### **2.2.1. 사전 경보 단계 (Pre-Notification Phase)**

이벤트가 실제로 시작되기 **5분 전**, 서버는 해당 지역의 위상을 활성화하고 월드맵에 주황색 원형 아이콘과 카운트다운 타이머를 방송(Broadcast)한다.4

* **기술적 함의:** 앱 사용자는 이동 시간을 필요로 하므로, 실제 이벤트 시작 시간(T)이 아닌 T \- 5분 시점이 가장 중요한 알림 트리거 포인트가 된다. 일부 사용자는 게임 접속 시간이 필요하므로 T \- 10분 옵션을 제공하는 것이 이상적이다.  
* **데이터 검증:** 다수의 사용자 리포트와 트래커 데이터에 따르면, 이 5분 카운트다운은 매우 정확하게 서버 시간과 동기화되어 있다.5

#### **2.2.2. 활성 및 종료 단계 (Active & Completion Phase)**

카운트다운이 0이 되면 이벤트가 시작되며, 약 10분에서 15분간 진행된다. 이벤트가 종료되거나 제한 시간이 만료되면 아이콘이 맵에서 사라진다.4 앱은 이 시점을 기점으로 다음 타이머를 갱신해야 한다.

### **2.3. 기준 시간(Anchor Time) 설정 및 예측 수식**

서버에 쿼리를 보내지 않고도 클라이언트 사이드에서 다음 이벤트를 계산하기 위해서는 신뢰할 수 있는 '기준 시간(Anchor Time)'이 필요하다. 수집된 데이터 2에 따르면 특정 시점의 스폰 예시는 다음과 같다:

* 09:55 AM \-\> 10:20 AM \-\> 10:45 AM \-\> 11:10 AM...

이러한 패턴은 오차 없이 25분 간격으로 진행됨을 증명한다. 이를 기반으로 한 예측 공식은 다음과 같다.

**\[수식 1\] 차기 군단 이벤트 예측 알고리즘**

$$T\_{next} \= T\_{anchor} \+ (25 \\times \\lceil \\frac{T\_{current} \- T\_{anchor}}{25} \\rceil)$$

* $T\_{next}$: 다음 군단 이벤트 시작 예상 시간 (분 단위)  
* $T\_{anchor}$: 과거에 확인된 유효한 군단 이벤트 시작 시간 (Epoch Timestamp 권장)  
* $T\_{current}$: 현재 서버 시간 (UTC)  
* $\\lceil x \\rceil$: 천장 함수(Ceiling Function), 소수점 올림 처리

**개발 시 주의사항:** 서버 점검(Maintenance)이나 긴급 패치(Hotfix)가 있을 경우 서버의 타이머 틱이 초기화되거나 오프셋(Offset)이 변경될 수 있다. 따라서 앱은 하루에 최소 1회, 외부 신뢰 소스(예: 블리자드 API 또는 커뮤니티 검증 데이터)를 통해 $T\_{anchor}$ 값을 재동기화(Re-synchronization)하는 로직을 포함해야 한다.5

## **3\. 지리적 데이터베이스: 성역의 군단 이벤트 노드 분석**

군단 이벤트는 무작위 위치에서 발생하는 것이 아니라, 기획자에 의해 미리 지정된 특정 좌표(Pre-defined Nodes)에서만 발생한다. 알림 앱의 고도화를 위해서는 이 위치 데이터를 DB화하고, 각 위치의 특성(접근 조건)을 메타데이터로 관리해야 한다. 특히 '보루(Stronghold)' 점령 여부에 따른 가시성 문제는 사용자 혼란을 야기하는 주된 원인이므로 7, 이를 명확히 안내해야 한다.

### **3.1. 기본 게임(Base Game) 지역별 스폰 노드 상세**

확장팩 이전의 5개 지역(조각난 봉우리, 스코스글렌, 메마른 평원, 케지스탄, 하웬자르)에는 고정된 스폰 위치가 존재한다. 아래 표는 수집된 데이터를 종합하여 정리한 위치 정보 데이터베이스이다.

| 지역 (Region) | 세부 구역 (Sub-region) | 위치 명칭 (Location Node) | 보루 점령 필요 (Prerequisite) | 지형 및 테마 분석 | 데이터 소스 |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **조각난 봉우리** | 코르 드라간 | **코르 드라간 (Kor Dragan)** | **필수 (Yes)** | 지역 북서쪽 끝에 위치한 흡혈귀 테마의 보루. 맵이 복잡하고 고저차가 있어 이동에 주의 필요. 보루를 클리어하지 않으면 맵에 표시되지 않음. | 4 |
| **스코스글렌** | 헌신적인 자의 무덤 | **캐로크레스트 폐허 (Carrowcrest Ruins)** | 아니오 (No) | 스코스글렌 서부 해안가 근처. 개방된 지형으로 접근성이 좋음. | 8 |
| **메마른 평원** | 썩어가는 사원 | **부패의 사원 (Temple of Rot)** | **필수 (Yes)** | 메마른 평원 남서쪽. 식인종 테마. 맵이 좁고 구불구불하여 몬스터 밀집도가 높음. | 1 |
| **메마른 평원** | 유령의 잔해 | **유령의 잔해 (Haunted Wreckage)** | 아니오 (No) | 메마른 평원 동쪽 해안. 난파선 주변의 개방된 지역. | 8 |
| **하웬자르** | 노르고이 경계 | **노르고이 경계 (Norgoi Vigil)** | 아니오 (No) | 하웬자르 북쪽 끝, 메마른 평원과의 경계 근처. 뱀과 늪지대 몬스터 출몰. | 1 |
| **하웬자르** | 성전사의 기념비 | **성전사의 기념비 (Crusaders' Monument)** | **필수 (Yes)** | 하웬자르 서부. 언데드 성기사 테마. 중앙 광장을 중심으로 전투 진행. | 1 |
| **케지스탄** | 알카르누스 | **알카르누스 (Alcarnus)** | **필수 (Yes)** | 케지스탄 중앙 사막. 마녀와 데몬 테마. 도시형 폐허 지형. | 1 |
| **케지스탄** | 낡은 수로 | **낡은 수로 (Dilapidated Aqueducts)** | 아니오 (No) | 케지스탄 북부. 마른 수로 위에서 전투가 벌어짐. 일직선형 구조가 특징. | 8 |

**데이터 무결성 노트:** 일부 자료에서 '노르고이 경계'를 메마른 평원으로 분류하기도 하나, 게임 내 실제 지역 구분은 하웬자르에 속한다.11 앱 개발 시 zone\_id 매핑에 주의해야 한다.

### **3.2. 확장팩 '증오의 그릇' 및 나한투(Nahantu) 지역 데이터**

확장팩 출시와 함께 추가된 나한투 지역은 새로운 군단 이벤트 메커니즘과 위치를 포함한다. 이 데이터는 레거시 트래커들이 놓치기 쉬운 부분이므로, 신규 앱의 경쟁력이 될 수 있다.

| 지역 (Region) | 세부 구역 | 위치 명칭 | 메커니즘 변경 사항 | 데이터 소스 |
| :---- | :---- | :---- | :---- | :---- |
| **나한투** | 비즈-준 | **비즈-준 (Viz-jun)** | 전통적인 처치 방식 외에 기계 장치와 상호작용하는 요소가 포함될 수 있음. | 10 |
| **나한투** | 차키르 | **차키르의 포위 (Siege of Chakhir)** | 보루와 연계된 이벤트일 가능성이 높으며, 성채 남쪽에 위치. | 10 |

**신규 메커니즘 '호위(Escort)':** 나한투 지역의 군단 이벤트는 단순히 적을 죽이는 것을 넘어, 거대한 구체(Orb)를 목적지인 '영혼의 대야(Basin of Souls)'까지 호위하는 미션이 포함된다.4 플레이어는 구체 주변의 붉은 원 안에 위치해야 구체가 이동하며, 이는 기존의 '분산 사냥' 방식과는 다른 '밀집 이동' 협동을 요구한다. 앱 내 공략 탭에 이를 명시해야 한다.

### **3.3. 위치 로테이션의 무작위성(Randomness)과 대응 전략**

군단 이벤트의 **발생 시간**은 고정되어 있지만, **발생 위치**는 서버 측 난수 생성기(RNG)에 의해 결정되거나, 아직 완전히 해독되지 않은 복잡한 로테이션 패턴을 따른다.8

* **문제점:** "다음 이벤트가 10시 30분에 열린다"는 예측할 수 있지만, "코르 드라간에서 열린다"는 사전 예측이 불가능하다.  
* **대응 전략:** 현재 대부분의 트래커는 **사용자 제보(Crowdsourcing)** 또는 **OCR(광학 문자 인식)** 기술에 의존한다. 앱 개발 시, 초기에는 '위치 미정' 상태로 알림을 보내고, 사용자가 앱 내에서 위치를 투표하면 해당 정보를 실시간으로 다른 사용자에게 전파하는 기능을 구현해야 한다.13

## **4\. 군단 이벤트의 내부 메커니즘과 보상 체계**

사용자에게 단순 알림 이상의 가치를 제공하기 위해서는 이벤트의 진행 방식과 보상 구조를 이해하고, 이를 '공략 가이드' 형태로 앱에 통합해야 한다.

### **4.1. 진행 단계(Phase)와 숙련도(Mastery) 로직**

군단 이벤트는 제한 시간 내에 얼마나 효율적으로 적을 처치하느냐에 따라 보상이 달라지는 '타임 어택' 구조를 가진다.4

1. **웨이브 단계 (The Waves):** 이벤트가 시작되면 맵에 표시된 붉은 점(적)을 찾아 처치해야 한다. 일정 수 이상의 적을 처치하면 '지옥의 종복(Servant of Hell)'이 소환된다.  
2. **종복 처치 단계 (Servant Phase):** 총 3마리의 종복이 순차적으로 등장한다. 각 종복은 제한 시간을 가지고 있으며, 이들을 처치할 때마다 보상 상자의 등급이나 개수가 증가한다.  
   * **핵심 로직:** 종복 1마리 처치 \= 상자 1개, 2마리 \= 상자 2개, 3마리 \= 상자 3개(숙련도 달성).  
3. **우두머리 단계 (Overlord Phase):** 3번째 종복 처치 후 또는 시간 종료 시 최종 보스(Overlord)가 등장한다. 시즌 4 이후 보스의 체력이 대폭 상향되어 파티 협동이 더욱 중요해졌다.4

### **4.2. 보상 경제학 (Reward Economy)**

플레이어가 군단 이벤트 알림을 켜두는 이유는 명확한 보상 때문이다. 앱은 다음 보상 정보를 강조하여 사용자의 참여 동기를 부여해야 한다.

* **경험치(XP):** 몬스터 밀집도가 높아 단위 시간당 경험치 획득량이 최상위권이다. 특히 '모닥불' 버프와 파티 보너스를 통해 레벨링에 최적화되어 있다.15  
* **희귀 재료:** 장비 소켓을 뚫는 데 필요한 '흩어진 프리즘(Scattered Prism)'과 '비술사 재료(Obols)'를 대량으로 획득할 수 있다.4  
* **수집품:** 특정 지역(예: 코르 드라간 등)에서는 '유령 군마(Spectral Charger)' 탈것 고삐가 낮은 확률로 드랍된다.1

## **5\. 알림 앱 개발을 위한 기술 명세서 (Technical Specification)**

AI 코딩 어시스턴트에게 제공하여 실제 앱을 구현하기 위한 구체적인 데이터 구조, API 아키텍처, 그리고 클라이언트 로직을 제안한다.

### **5.1. 데이터 스키마 설계 (JSON Model)**

앱 내부 또는 백엔드에서 군단 이벤트 데이터를 처리하기 위한 표준 JSON 스키마는 다음과 같다.

JSON

{  
  "event\_config": {  
    "type": "legion\_gathering",  
    "spawn\_interval\_minutes": 25,  
    "warning\_duration\_minutes": 5,  
    "active\_duration\_minutes": 15,  
    "anchor\_timestamp\_utc": 1704067200  
  },  
  "locations": \[  
    {  
      "id": "kor\_dragan",  
      "name\_kr": "코르 드라간",  
      "region\_id": "fractured\_peaks",  
      "requires\_stronghold": true,  
      "stronghold\_name\_kr": "코르 드라간",  
      "coordinates": { "x": 1234, "y": 5678 },  
      "rewards": \["xp", "obols", "spectral\_charger"\],  
      "description": "북서쪽 보루 내부. 흡혈귀 몬스터. 보루 완료 필요."  
    },  
    {  
      "id": "viz\_jun",  
      "name\_kr": "비즈-준",  
      "region\_id": "nahantu",  
      "is\_expansion": true,  
      "mechanic": "escort",  
      "coordinates": { "x": 9876, "y": 5432 },  
      "description": "나한투 지역. 구체 호위 미션 포함."  
    }  
    //... (나머지 8개 지역 데이터 포함)  
  \],  
  "regions": {  
    "fractured\_peaks": { "name\_kr": "조각난 봉우리" },  
    "scosglen": { "name\_kr": "스코스글렌" },  
    "dry\_steppes": { "name\_kr": "메마른 평원" },  
    "kehjistan": { "name\_kr": "케지스탄" },  
    "hawezar": { "name\_kr": "하웬자르" },  
    "nahantu": { "name\_kr": "나한투" }  
  }  
}

### **5.2. 클라이언트 사이드 예측 로직 (Pseudo-code)**

서버 통신을 최소화하고 오프라인 상태에서도 알림을 예약할 수 있는 로직이다.

Python

import datetime

def calculate\_next\_legion\_spawns(anchor\_epoch, count=5):  
    """  
    기준 시간(anchor\_epoch)을 바탕으로 향후 5개의 군단 이벤트 시간을 계산합니다.  
    """  
    INTERVAL\_SECONDS \= 25 \* 60  
    current\_epoch \= datetime.datetime.now(datetime.timezone.utc).timestamp()  
      
    \# 기준 시간으로부터 현재까지 몇 번의 주기가 지났는지 계산 (천장 함수 사용)  
    elapsed\_seconds \= current\_epoch \- anchor\_epoch  
    cycles\_passed \= math.ceil(elapsed\_seconds / INTERVAL\_SECONDS)  
      
    next\_spawns \=  
    for i in range(count):  
        future\_cycle \= cycles\_passed \+ i  
        spawn\_time \= anchor\_epoch \+ (future\_cycle \* INTERVAL\_SECONDS)  
          
        \# 5분 전 경보 시간 계산  
        warning\_time \= spawn\_time \- (5 \* 60)  
          
        next\_spawns.append({  
            "spawn\_time\_utc": spawn\_time,  
            "warning\_time\_utc": warning\_time,  
            "is\_imminent": (spawn\_time \- current\_epoch) \< 600 \# 10분 이내 여부  
        })  
          
    return next\_spawns

### **5.3. 데이터 수집 및 보정 전략**

앞서 언급했듯, 이벤트의 **정확한 위치**는 알고리즘으로 예측하기 어렵다. 따라서 앱은 다음과 같은 하이브리드 데이터 수집 전략을 취해야 한다.

1. **사용자 투표 시스템 (Crowdsourcing):**  
   * 이벤트 예고 시간(T-5분)이 되면 앱 상단에 "어디서 이벤트가 열리나요?"라는 팝업을 띄운다.  
   * 사용자가 지역(예: 코르 드라간)을 선택하면, 서버는 투표 수를 집계하여 가장 높은 득표수를 가진 지역을 '유력 발생지'로 표시한다.13  
   * **신뢰도 알고리즘:** 신규 사용자보다 기존 성실 사용자(투표 적중률이 높은 사용자)의 투표에 가중치를 부여하여 트롤링을 방지한다.  
2. **OCR 기반 자동 수집 (고급 기능):**  
   * PC 또는 콘솔 화면을 캡처하여 텍스트를 인식하는 OCR 모듈(Tesseract 등)을 활용할 수 있다.16  
   * "군단 이벤트", "참가 가능" 등의 키워드와 미니맵상의 지역명을 인식하여 서버로 자동 전송하는 별도의 데스크톱 클라이언트를 배포하여 데이터를 확보한다.

## **6\. 결론 및 향후 전망**

디아블로 IV 군단 이벤트 알림 앱 개발은 **25분 고정 주기**라는 강력한 상수 위에서 출발한다. 그러나 **위치의 무작위성**과 **보루 점령 조건**이라는 변수가 존재하므로, 단순한 타이머를 넘어선 커뮤니티 기반의 데이터 공유 플랫폼으로 진화해야 한다.

확장팩 '증오의 그릇'의 출시는 나한투 지역이라는 새로운 변수를 추가했으며, 이는 기존 트래커들이 놓치고 있는 시장 기회이기도 하다. 본 보고서에서 제공한 위치 데이터베이스와 예측 알고리즘, 그리고 데이터 스키마를 활용한다면, AI는 사용자 친화적이고 정확도 높은 알림 앱 코드를 생성할 수 있을 것이다. 특히, 단순한 시간 알림을 넘어 "어떤 보루를 클리어해야 하는지", "이번 이벤트는 어떤 보상을 주는지"에 대한 맥락 정보(Contextual Information)를 제공하는 것이 이 앱의 성공 열쇠가 될 것이다.

#### **참고 자료**

1. Diablo 4 Guide to the Legion Events \- LootBar, 1월 5, 2026에 액세스, [https://lootbar.gg/blog/en/diablo4-guide-legion-events.html](https://lootbar.gg/blog/en/diablo4-guide-legion-events.html)  
2. New Legion timing\! Every 25 minutes exactly as promised : r/diablo4 \- Reddit, 1월 5, 2026에 액세스, [https://www.reddit.com/r/diablo4/comments/17a41b4/new\_legion\_timing\_every\_25\_minutes\_exactly\_as/](https://www.reddit.com/r/diablo4/comments/17a41b4/new_legion_timing_every_25_minutes_exactly_as/)  
3. Open world events frequency \- PC General Discussion \- Diablo IV Forums, 1월 5, 2026에 액세스, [https://us.forums.blizzard.com/en/d4/t/open-world-events-frequency/114144](https://us.forums.blizzard.com/en/d4/t/open-world-events-frequency/114144)  
4. The Gathering Legions Zone Event Guide \- Maxroll, 1월 5, 2026에 액세스, [https://maxroll.gg/d4/resources/gathering-legions-zone-event-guide](https://maxroll.gg/d4/resources/gathering-legions-zone-event-guide)  
5. When do Legion events show up on the map? \- Diablo IV \- GameFAQs, 1월 5, 2026에 액세스, [https://gamefaqs.gamespot.com/boards/276473-diablo-iv/80492777](https://gamefaqs.gamespot.com/boards/276473-diablo-iv/80492777)  
6. Diablo 4 Legion Events Guide \- ArzyeLBuilds, 1월 5, 2026에 액세스, [https://arzyelbuilds.com/diablo-4-legion-events/](https://arzyelbuilds.com/diablo-4-legion-events/)  
7. Legion event location not on map. : r/diablo4 \- Reddit, 1월 5, 2026에 액세스, [https://www.reddit.com/r/diablo4/comments/1kbi5s3/legion\_event\_location\_not\_on\_map/](https://www.reddit.com/r/diablo4/comments/1kbi5s3/legion_event_location_not_on_map/)  
8. Diablo 4: A Complete Guide To Legion Gathering Events \- DualShockers, 1월 5, 2026에 액세스, [https://www.dualshockers.com/diablo-4-complete-legion-gathering-events-guide/](https://www.dualshockers.com/diablo-4-complete-legion-gathering-events-guide/)  
9. Diablo 4 The Gathering Legions Event Locations: Massive XP Farm | Attack of the Fanboy, 1월 5, 2026에 액세스, [https://attackofthefanboy.com/guides/diablo-4-the-gathering-legions-event-locations-massive-xp-farm/](https://attackofthefanboy.com/guides/diablo-4-the-gathering-legions-event-locations-massive-xp-farm/)  
10. All Zone Event / Boss Locations in Diablo IV \- Map Genie, 1월 5, 2026에 액세스, [https://mapgenie.io/diablo-4/guides/zone-events-bosses](https://mapgenie.io/diablo-4/guides/zone-events-bosses)  
11. Dry Steppes Altar of Lilith Locations \- Diablo 4 Guide \- IGN, 1월 5, 2026에 액세스, [https://www.ign.com/wikis/diablo-4/Dry\_Steppes\_Altar\_of\_Lilith\_Locations](https://www.ign.com/wikis/diablo-4/Dry_Steppes_Altar_of_Lilith_Locations)  
12. The legion event at Viz-Jun, Nahantu is simply incredible : r/diablo4 \- Reddit, 1월 5, 2026에 액세스, [https://www.reddit.com/r/diablo4/comments/1g23chv/the\_legion\_event\_at\_vizjun\_nahantu\_is\_simply/](https://www.reddit.com/r/diablo4/comments/1g23chv/the_legion_event_at_vizjun_nahantu_is_simply/)  
13. \*\*World Bosses, Helltides, and Legion Events are all predictable\!\*\* : r/diablo4 \- Reddit, 1월 5, 2026에 액세스, [https://www.reddit.com/r/diablo4/comments/14cv0t0/world\_bosses\_helltides\_and\_legion\_events\_are\_all/](https://www.reddit.com/r/diablo4/comments/14cv0t0/world_bosses_helltides_and_legion_events_are_all/)  
14. "D4 Events Time Tracker" app, Helltide Voting : r/Diablo \- Reddit, 1월 5, 2026에 액세스, [https://www.reddit.com/r/Diablo/comments/186odum/d4\_events\_time\_tracker\_app\_helltide\_voting/](https://www.reddit.com/r/Diablo/comments/186odum/d4_events_time_tracker_app_helltide_voting/)  
15. Fast Rewards and Easy XP: Legion Events Explained. Diablo 4 Complete 3-Minute Beginner's Guide. \- YouTube, 1월 5, 2026에 액세스, [https://www.youtube.com/watch?v=khWCqz1EOks](https://www.youtube.com/watch?v=khWCqz1EOks)  
16. akjroller/Diablo-4-XP-and-gold-per-hour \- GitHub, 1월 5, 2026에 액세스, [https://github.com/akjroller/Diablo-4-XP-and-gold-per-hour](https://github.com/akjroller/Diablo-4-XP-and-gold-per-hour)