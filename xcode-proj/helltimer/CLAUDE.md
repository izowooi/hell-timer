# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Hell Timer is a native iOS app for tracking Diablo 4 world events (Helltide, Legion, World Boss) with WidgetKit integration and push notifications. The app calculates event times 100% locally without server dependency.

## Build Commands

Build and run via Xcode:
- Open `helltimer.xcodeproj` in Xcode
- Select the `helltimer` scheme for the main app
- Select `HellTimerWidgetExtension` scheme to build/test the widget
- Use `Cmd+B` to build, `Cmd+R` to run
- Use `Cmd+U` to run all tests

Run tests from command line:
```bash
xcodebuild test -project helltimer.xcodeproj -scheme helltimer -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Architecture

**Pattern:** MVVM with Clean Architecture layers

**Targets:**
- `helltimer` - Main iOS app (iOS 16.4+)
- `HellTimerWidgetExtension` - Home screen widgets (Small/Medium/Large)
- `helltimerTests` - Unit tests (Swift Testing framework)
- `helltimerUITests` - UI tests

**Layer Structure:**
```
Core/
├── Models/         # GameEvent, EventType, UserSettings
├── Services/       # EventCalculators, NotificationManager, SharedDataManager
└── Repositories/   # SettingsRepository

Features/
├── Dashboard/      # Main screen (DashboardView, DashboardViewModel, EventCardView)
└── Settings/       # Notification settings
```

**Key Singletons:**
- `HelltideCalculator.shared`, `LegionCalculator.shared`, `WorldBossCalculator.shared`
- `SettingsRepository.shared`, `NotificationManager.shared`

## Event Calculation Logic

Three distinct calculation strategies:

1. **Helltide** - Local calendar-based (minute 0-54 = active, 55-59 = rest)
2. **Legion** - UTC anchor-based (anchor: 1200s, interval: 25 min / 1500s)
3. **WorldBoss** - UTC anchor-based (anchor: 1767702600, interval: 105 min / 6300s)

Formula for UTC-based events:
```
nextEventTime = anchor + ceil((currentTime - anchor) / interval) * interval
```

## App-Widget Data Sharing

Uses App Groups (`group.com.izowooi.helltimer`) for IPC:
- Main app writes settings/event data to shared UserDefaults
- Widget reads from shared UserDefaults and recalculates independently
- `SharedDataManager` handles sync; triggers `WidgetCenter.reloadAllTimelines()`

## Widget Timeline

Generates 60 entries (1 per minute) for 1 hour, refreshes hourly. Widget recalculates event times from scratch without caching dependency.

## Testing

29 unit tests covering all three event calculators, UserSettings, and EventType. Uses Swift Testing framework (`@Test` macro), not XCTest.

## Native Only

No external dependencies - pure Apple frameworks: SwiftUI, WidgetKit, Combine, UserNotifications.
