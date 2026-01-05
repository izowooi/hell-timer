# Diablo 4 Legion Event spawn timer: complete technical guide

**Legion Events in Diablo 4 spawn on a fixed 25-minute interval** with random location rotation—a predictable timer that makes building notification apps straightforward. The timing has remained unchanged since Season 2 (October 2023), when Blizzard reduced the interval from 30 minutes. While no official API exists, the d4armory.io community API provides reliable event data, and the fixed schedule enables simple timer-based calculations.

## Exact spawn timing rules confirmed

Legion Events (군단 이벤트, also called "Gathering Legions") follow a **global 25-minute fixed cycle**. Every 25 minutes, one Legion Event activates at a randomly selected location from the pool of 10+ possible spawn points across Sanctuary.

| Timing Aspect | Value |
|---------------|-------|
| **Spawn interval** | 25 minutes (fixed) |
| **In-game warning timer** | 10 minutes before start |
| **Map icon appearance** | ~5 minutes before start |
| **Event duration** | 3-4 minutes |
| **Events per hour** | 2-3 |

The schedule operates on a rolling global timer—**no specific timezone applies**. All players worldwide experience the same spawn times, and third-party trackers display times converted to the user's local timezone. Unlike World Bosses which follow a predictable location rotation pattern (3 Ashavas, 2 Wandering Deaths, etc.), Legion Event locations are randomly selected among available spawn points.

## Location rotation and stronghold requirements

Ten primary Legion Event locations exist across Sanctuary, with five freely accessible and five requiring stronghold completion first:

**Freely accessible locations:**
- Carrowcrest Ruins (Scosglen)
- Norgoi Vigil (Dry Steppes)
- Dilapidated Aqueducts (Kehjistan)
- Haunted Wreckage (Hawezar)
- The Harrowfields (Fractured Peaks)

**Stronghold-locked locations:**
- Kor Dragan (Fractured Peaks) → requires Kor Dragan Stronghold
- Temple of Rot (Dry Steppes) → requires Temple of Rot Stronghold
- Crusader's Monument (Hawezar) → requires Crusader's Monument Stronghold
- Alcarnus (Kehjistan) → requires Alcarnus Stronghold
- Chakir Stronghold (Nahantu) → requires Chakir Stronghold (Vessel of Hatred only)

The Vessel of Hatred expansion added **new Legion Event types in Nahantu** featuring Soul Basin escort mechanics rather than the traditional kill-wave format. Players must escort orbs along paths rather than simply killing waves of enemies.

## Technical implementation for notification apps

### No official Blizzard API exists

Blizzard has not released a public API for Diablo 4 events despite community requests since launch. The company currently only provides community APIs for StarCraft II and Diablo III. However, community-maintained alternatives provide reliable data.

### Primary data source: d4armory.io API

The most widely-used endpoint is `https://d4armory.io/api/events/recent`, which returns JSON data for world bosses, helltides, and legion events. Basic Python implementation:

```python
import requests
response = requests.get('https://d4armory.io/api/events/recent')
if response.status_code == 200:
    data = response.json()
    # Access boss, helltide, legion event data
```

### Timer calculation approach (recommended)

Since Legion Events follow a fixed 25-minute interval, timer-based calculation works reliably even without API access:

```javascript
// Legion events every 25 minutes
const LEGION_INTERVAL = 25 * 60 * 1000; // milliseconds
const BASE_TIMESTAMP = 1699704000000;   // known reference point

function getNextLegion() {
    const now = Date.now();
    const elapsed = now - BASE_TIMESTAMP;
    const nextIndex = Math.ceil(elapsed / LEGION_INTERVAL);
    return BASE_TIMESTAMP + (nextIndex * LEGION_INTERVAL);
}
```

### Existing tracker resources

| Tracker | URL | Features |
|---------|-----|----------|
| D4Planner | d4planner.io/trackers/legion | Push notifications, precise timers |
| Helltides.com | helltides.com | World boss focus, includes Legion, Discord bot |
| Diablo4.life | diablo4.life/trackers/zone-events | Community-sourced reporting |
| Wowhead | wowhead.com/diablo-4/event-timers | Official gaming database |

**Mobile apps** include "D4 Events Time Tracker" (iOS/Android) at d4events.sefir.dev, offering push notifications and interactive maps. Note: iOS limits scheduled notifications to 64 per week.

### Open-source repositories for reference

Several GitHub projects provide working code:
- **Valery1991/D4-Event-Tracker** (Python) - Discord webhook tracker using d4armory API
- **TheCardist/D4Boss-Timer** (Python) - SMS notification tool
- **nminchow/black-book** (JavaScript) - Full Discord bot with Supabase backend
- **jon4hz/d4eventbot** (Go) - Event bot using d4armory API

## Historical timing changes and current season status

**The 25-minute interval has remained stable since October 2023.** Here's the complete timeline:

| Period | Spawn Interval | Change |
|--------|---------------|--------|
| Launch – Season 1 (June-Oct 2023) | 30 minutes | Original timing |
| Season 2+ (October 2023 – present) | **25 minutes** | Patch 1.2.0 reduced timer |

**Patch 1.2.0 (Season 2, October 17, 2023)** made these changes per official Blizzard notes:
- Spawn timer reduced from 30 to 25 minutes
- Warning timer increased from 5 to 10 minutes
- Experience reward increased by 75%
- Every Legion Event now includes a Whisper objective

**Seasons 4, 5, and 6 made no timing changes.** Recent patches focused on rewards:
- **Patch 2.0.4** (Oct 2024): Legion chests grant bonus loot with Seething Opal active
- **Patch 2.0.5** (Nov 2024): "Loot quality for Legion Event chests has been increased"

## Known bugs and edge cases

Community reports document several issues developers should account for:

1. **Events not spawning at expected times** - Server-side synchronization issues occasionally cause events to skip
2. **Mid-event enemy spawn failure** - Background cause is server synchronization; only fixable via patches
3. **Stronghold prerequisite confusion** - Users miss events because required strongholds aren't completed
4. **Timer visibility gap** - In-game timer only appears 10 minutes before; players in dungeons miss notifications

## Conclusion

Building a Legion Event notification app is technically straightforward due to the **fixed 25-minute spawn interval** established since Season 2. The recommended approach combines timer calculation (for reliability) with d4armory.io API polling (for validation). Key implementation decisions:

- Use timer calculation as the primary mechanism since it works offline
- Poll the d4armory API every 5-10 minutes as a synchronization check
- Account for the 10-minute in-game warning when setting notification timing
- Consider iOS notification limits (64/week) for mobile apps
- Note that location cannot be predicted—only timing is fixed

The Korean community (인벤, 나무위키) uses the same trackers and confirms identical timing (25분마다 로테이션). For development reference, the D4 Events Time Tracker app and d4planner.io demonstrate working push notification implementations.