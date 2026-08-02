# RaceReady

Native iOS training tracker for an 18-week Hyrox prep program targeting **September 18, 2026**. Sub-1:30 race plan, dark-mode-first, fully offline.

## Stack

- Swift 5.10, SwiftUI, SwiftData (iOS 17+)
- Swift Charts for analytics
- UserNotifications for the daily reminder
- No third-party dependencies

## Architecture

```
RaceReady/
├── App/          # @main, Theme, RootTabView (4 tabs)
├── Plan/         # Pure value types: SessionType, Phase, SessionTemplate,
│                 # PlanData (18-week × 6-type schedule), PlanEngine, UnitFormatter
├── Models/       # @Model SwiftData types: SessionLog, RunLog, BenchmarkEntry,
│                 # QueueState, UserSettings
├── Services/     # QueueService, AnalyticsService, NotificationService, CSVExporter
├── Features/     # Dashboard / ActiveSession / Analytics / Plan / History / Settings
└── Resources/    # Assets.xcassets (electric-blue AccentColor, AppIcon)
```

### Key design decisions

- **Canonical SI storage**: all distances stored as meters, weights as kg, durations as seconds. A `UnitFormatter` injected via `@Environment(\.unitFormatter)` renders the user's chosen unit system (metric ↔ imperial).
- **Pace is always derived** at render time from stored distance + duration — never persisted, to avoid drift.
- **Phase detection by completed-session count**, not calendar. `PlanEngine.phase(forCompletedSessions:)` is the single source of truth. Boundaries: 36 / 72 / 102 / 105.
- **Queue, not calendar**. `QueueService` keeps an ordered list of `SessionTemplate` ids. Skip-reschedule rotates head→tail; skip-drop removes; swap promotes the earliest queued template of the chosen type.
- **Drift-resilient timer**. `SessionTimer` stores `startedAt: Date` and computes elapsed via `Date().timeIntervalSince(startedAt)`, so backgrounding doesn't lose time.

## Generating the Xcode project

This repo uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) — the `project.yml` is the source of truth.

```bash
brew install xcodegen
cd /Users/maxyatkeman/RaceReadyIOS
xcodegen generate
open RaceReady.xcodeproj
```

## Running tests

```bash
xcodebuild test \
  -project RaceReady.xcodeproj \
  -scheme RaceReady \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

Or in Xcode: `⌘U`.

Test files:

- `RaceReadyTests/PlanEngineTests.swift` — phase boundary detection, week mapping, template completeness (105 total, unique ids)
- `RaceReadyTests/QueueServiceTests.swift` — skip-reschedule, skip-drop, swap, persistence round-trip via in-memory `ModelContainer`
- `RaceReadyTests/UnitFormatterTests.swift` — kg↔lb, km↔mi, pace formatting, parser edge cases

## Smoke test checklist

1. Fresh install → race countdown shows correct days to **2026-09-18**, Up Next shows Week 1 Session 1.
2. Start session → timer runs → Complete → `SessionLog` persists, queue advances, Dashboard reflects new Up Next.
3. Log a run with distance + time → pace auto-renders, weekly mileage bar fills.
4. Skip via "Reschedule" → session moves to tail; via "Drop" → session disappears and remaining count decrements.
5. Swap → choose a different session type → that type becomes Up Next.
6. Settings → set notification time ~1 min ahead → notification fires with one of the rotating body variants.
7. Settings → Export CSV → share sheet opens with a valid file (both metric and imperial columns present).
8. Settings → flip Units toggle → all displayed distances/weights/paces re-render instantly. No data migration.

## Project status

Greenfield — first generation of the codebase. Phase 0–6 implementation complete:

- [x] Plan layer + 105-session `PlanData`
- [x] SwiftData models + `PlanEngine` + `QueueService`
- [x] Dashboard (countdown, Up Next, queue preview, mileage bar, skip/swap sheets)
- [x] Active Session (timer, exercise reference, run log fields, complete flow)
- [x] Analytics (mileage chart, phase progress, PRs, benchmark trends, leg-burn chart)
- [x] Plan reference + History tabs
- [x] Settings + NotificationService + CSV export

Pending v1.1 candidates:

- Logged-today notification suppression (requires Background Task)
- "Decision threshold" prompts after benchmarks (e.g. if Wk 6 5K > 25:00 → add 4th run day)
- App icon artwork (currently empty `AppIcon.appiconset`)
