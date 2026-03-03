# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About the App

Breakpoint is an iOS app that helps users track urges to engage in habits they want to replace. Users register habits, log urges with context, define replacement strategy steps, and track resolutions (pending / not handled / handled) in a timeline view.

## Build & Test Commands

```bash
# Build
xcodebuild build -scheme Breakpoint -project Breakpoint/Breakpoint.xcodeproj

# Run all tests (unit tests only; UI tests are disabled)
xcodebuild test -scheme Breakpoint -project Breakpoint/Breakpoint.xcodeproj \
  -destination "platform=iOS Simulator,name=iPhone 16"

# Run a single test class
xcodebuild test -scheme Breakpoint -project Breakpoint/Breakpoint.xcodeproj \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing:BreakpointTests/HabitTests
```

## Architecture

**Framework stack:** SwiftUI + SwiftData (no Core Data, no ViewModels layer).

**Data flow:**
1. `BreakpointApp.swift` creates the `ModelContainer` with the schema and injects it.
2. Views access the context via `@Environment(\.modelContext)`.
3. `@Query` macros handle data fetching with optional sort descriptors.
4. Forms perform validation before calling `modelContext.insert()` / `modelContext.delete()`.

**Models** (`Breakpoint/Models/`):
- `Habit` — name, description, ordered `[ReplacementStep]` relationship (cascade-delete).
- `ReplacementStep` — task string, display order, back-reference to `Habit`.
- `Urge` — timestamp, linked `Habit`, three-state `Resolution` enum, context string, `completedReplacementStepIDs: [UUID]` for tracking which steps were completed.
- All models carry `@Attribute(.unique) var id: UUID` and define a nested `ValidationError` enum; validation is done in a `static func validate(...)` method.

**Views** (`Breakpoint/Views/`):
- `ContentView` — top-level `TabView` (Timeline tab / Habits tab).
- `UrgesTimelineView` — urges grouped by day (Today / Yesterday / formatted date), uses `UrgeCardView`.
- `HabitsListView` — flat list of habits, uses `HabitCardView`.
- `CreateEditHabitView` / `CreateEditUrgeView` — shared create/edit forms; the `isEditing` flag (presence of an existing object) controls behavior.

**Components** (`Breakpoint/Components/`):
- `HabitCardView` and `UrgeCardView` — display-only cards with an edit button that presents the matching form sheet.

## SwiftData Schema

All persistent models must be listed explicitly in the `Schema` initializer in `BreakpointApp.swift`:

```swift
Schema([Habit.self, Urge.self, ReplacementStep.self])
```

When adding a new `@Model`, add it here or the app will crash at launch.

## Testing Conventions

- Tests use **Swift Testing** (`import Testing`, `@Test` macros), not XCTest assertions.
- Test files live in `BreakpointTests/Models/` mirroring the `Models/` source folder.
- Each model test file covers: valid construction, every `ValidationError` case, edge cases (empty/whitespace-only strings, unicode, very long inputs).
- UI tests exist but are **disabled** in `Breakpoint.xctestplan` — do not re-enable without a deliberate decision.

## Active Refactor (streaking steps feature)

The codebase is mid-refactor:
- `Habit.replacementStrategyTasks: [String]` was replaced by `Habit.replacementSteps: [ReplacementStep]`.
- `Urge` gained `completedReplacementStepIDs: [UUID]`.
- Several views and tests still reference the old `replacementStrategyTasks` property and will not compile until updated.
- `ReplacementStep` needs to be added to the `Schema` in `BreakpointApp.swift`.
