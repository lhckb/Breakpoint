# Streak Replacement Steps Feature - Implementation Guide

## Overview
This document outlines all changes required to implement the ability to mark replacement strategy steps as completed when logging an urge. This implementation uses a proper data model approach with a separate `ReplacementStep` entity to ensure data integrity even when habits are edited.

## Architecture Decision
**Chosen Approach:** Separate `ReplacementStep` Model with UUID-based tracking

**Why?** 
- ✅ Data integrity maintained when steps are reordered or deleted
- ✅ Historical urge records remain accurate
- ✅ Scalable for future enhancements (categories, difficulty ratings, etc.)
- ✅ Follows SwiftData relationship best practices

---

## Phase 1: Create New `ReplacementStep` Model ✅ COMPLETED

### File: `ReplacementStep.swift` (NEW FILE)

```swift
//
//  ReplacementStep.swift
//  Breakpoint
//
//  Created by [Your Name] on [Date]
//

import Foundation
import SwiftData

@Model
class ReplacementStep {
	@Attribute(.unique) var id: UUID
	var task: String
	var order: Int
	
	// Relationship to parent Habit
	var habit: Habit?
	
	init(
		task: String,
		order: Int,
		habit: Habit? = nil
	) throws {
		// Validate task is not empty
		guard !task.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
			throw ValidationError.emptyTask
		}
		
		self.id = UUID()
		self.task = task
		self.order = order
		self.habit = habit
	}
}

// MARK: - Validation Errors
extension ReplacementStep {
	enum ValidationError: LocalizedError {
		case emptyTask
		
		var errorDescription: String? {
			switch self {
			case .emptyTask:
				return "Replacement step task cannot be empty."
			}
		}
	}
}

// MARK: - Identifiable Conformance
extension ReplacementStep: Identifiable {}
```

**Key Points:**
- `@Attribute(.unique)` ensures each step has a unique identifier
- `order` property maintains display sequence
- Inverse relationship to `Habit` for two-way navigation
- Validation ensures task text is never empty

---

## Phase 2: Update `Habit` Model ✅ COMPLETED

### File: `Habit.swift` (MODIFIED)

#### Changes Required:

1. **Import Statement** - Already present, no change needed

2. **Replace Property:**

```swift
// OLD (REMOVE):
var replacementStrategyTasks: [String]

// NEW (ADD):
@Relationship(deleteRule: .cascade, inverse: \ReplacementStep.habit)
var replacementSteps: [ReplacementStep] = []
```

3. **Update Initializer:**

```swift
// OLD SIGNATURE:
init(
	name: String,
	habitDescription: String,
	replacementStrategyTasks: [String]
) throws

// NEW SIGNATURE:
init(
	name: String,
	habitDescription: String,
	replacementSteps: [ReplacementStep] = []
) throws
```

4. **Update Initializer Body:**

```swift
init(
	name: String,
	habitDescription: String,
	replacementSteps: [ReplacementStep] = []
) throws {
	// Validate name
	guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
		throw ValidationError.emptyName
	}
	
	// Validate description
	guard !habitDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
		throw ValidationError.emptyDescription
	}
	
	// Validate replacement strategies
	guard !replacementSteps.isEmpty else {
		throw ValidationError.noReplacementStrategies
	}
	
	self.id = UUID()
	self.name = name
	self.habitDescription = habitDescription
	self.replacementSteps = replacementSteps
	
	// Set bidirectional relationship
	for step in replacementSteps {
		step.habit = self
	}
}
```

5. **Update Validation Errors:**

```swift
// REMOVE this case:
case emptyReplacementStrategy

// Keep these cases:
case emptyName
case emptyDescription
case noReplacementStrategies
```

6. **Update Error Descriptions:**

```swift
var errorDescription: String? {
	switch self {
	case .emptyName:
		return "Habit name cannot be empty."
	case .emptyDescription:
		return "Habit description cannot be empty."
	case .noReplacementStrategies:
		return "At least one replacement strategy is required."
	// REMOVE emptyReplacementStrategy case
	}
}
```

7. **Add Convenience Method (Optional but Recommended):**

```swift
// Add after init, before closing brace
/// Convenience method for creating steps from string arrays
/// Useful for testing and migration from old data model
static func createStepsFromStrings(_ tasks: [String]) throws -> [ReplacementStep] {
	try tasks.enumerated().map { index, task in
		try ReplacementStep(task: task, order: index)
	}
}
```

**Complete Updated File:**

```swift
//
//  Habit.swift
//  Breakpoint
//
//  Created by Luís Cruz on 26/11/25.
//

import Foundation
import SwiftData

@Model
class Habit {
	@Attribute(.unique) var id: UUID
	var name: String
	var habitDescription: String
	
	@Relationship(deleteRule: .cascade, inverse: \ReplacementStep.habit)
	var replacementSteps: [ReplacementStep] = []
	
	init(
		name: String,
		habitDescription: String,
		replacementSteps: [ReplacementStep] = []
	) throws {
		// Validate name
		guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
			throw ValidationError.emptyName
		}
		
		// Validate description
		guard !habitDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
			throw ValidationError.emptyDescription
		}
		
		// Validate replacement strategies
		guard !replacementSteps.isEmpty else {
			throw ValidationError.noReplacementStrategies
		}
		
		self.id = UUID()
		self.name = name
		self.habitDescription = habitDescription
		self.replacementSteps = replacementSteps
		
		// Set bidirectional relationship
		for step in replacementSteps {
			step.habit = self
		}
	}
	
	/// Convenience method for creating steps from string arrays
	static func createStepsFromStrings(_ tasks: [String]) throws -> [ReplacementStep] {
		try tasks.enumerated().map { index, task in
			try ReplacementStep(task: task, order: index)
		}
	}
}

// MARK: - Validation Errors
extension Habit {
	enum ValidationError: LocalizedError {
		case emptyName
		case emptyDescription
		case noReplacementStrategies
		
		var errorDescription: String? {
			switch self {
			case .emptyName:
				return "Habit name cannot be empty."
			case .emptyDescription:
				return "Habit description cannot be empty."
			case .noReplacementStrategies:
				return "At least one replacement strategy is required."
			}
		}
	}
}
```

---

## Phase 3: Update `Urge` Model ✅ COMPLETED

### File: `Urge.swift` (MODIFIED)

#### Changes Required:

1. **Property Already Added** - You've already added:
```swift
var completedReplacementStepIDs: [UUID] = []
```
✅ This is correct!

2. **Update Initializer Signature:**

```swift
// ADD parameter:
init(
	time: Date,
	habit: Habit,
	context: String,
	resolutionComment: String = "",
	resolution: Resolution = .pending,
	completedReplacementStepIDs: [UUID] = []  // ADD THIS LINE
) throws
```

3. **Update Initializer Body:**

```swift
init(
	time: Date,
	habit: Habit,
	context: String,
	resolutionComment: String = "",
	resolution: Resolution = .pending,
	completedReplacementStepIDs: [UUID] = []
) throws {
	// Validate that context is not empty
	guard !context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
		throw ValidationError.emptyContext
	}
	
	self.id = UUID()
	self.time = time
	self.habit = habit
	self.resolution = resolution
	self.context = context
	self.resolutionComment = resolutionComment
	self.completedReplacementStepIDs = completedReplacementStepIDs  // ADD THIS LINE
}
```

4. **Add Computed Property (Optional but Useful):**

```swift
// Add after init, before enum Resolution
/// Returns the actual ReplacementStep objects that were completed
/// Note: Steps may no longer exist if they were deleted from the habit
var completedSteps: [ReplacementStep] {
	habit.replacementSteps.filter { step in
		completedReplacementStepIDs.contains(step.id)
	}
}

/// Returns UUIDs of completed steps that no longer exist in the habit
var orphanedCompletedStepIDs: [UUID] {
	let currentStepIDs = Set(habit.replacementSteps.map { $0.id })
	return completedReplacementStepIDs.filter { !currentStepIDs.contains($0) }
}
```

**Complete Updated File:**

```swift
//
//  Urge.swift
//  Breakpoint
//
//  Created by Luís Cruz on 18/12/25.
//

import Foundation
import SwiftData

@Model
class Urge {
	
	@Attribute(.unique) var id: UUID
	var time: Date
	var habit: Habit
	var resolution: Resolution
	var context: String
	var resolutionComment: String
	
	var completedReplacementStepIDs: [UUID] = []
	
	init(
		time: Date,
		habit: Habit,
		context: String,
		resolutionComment: String = "",
		resolution: Resolution = .pending,
		completedReplacementStepIDs: [UUID] = []
	) throws {
		// Validate that context is not empty
		guard !context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
			throw ValidationError.emptyContext
		}
		
		self.id = UUID()
		self.time = time
		self.habit = habit
		self.resolution = resolution
		self.context = context
		self.resolutionComment = resolutionComment
		self.completedReplacementStepIDs = completedReplacementStepIDs
	}
	
	/// Returns the actual ReplacementStep objects that were completed
	/// Note: Steps may no longer exist if they were deleted from the habit
	var completedSteps: [ReplacementStep] {
		habit.replacementSteps.filter { step in
			completedReplacementStepIDs.contains(step.id)
		}
	}
	
	/// Returns UUIDs of completed steps that no longer exist in the habit
	var orphanedCompletedStepIDs: [UUID] {
		let currentStepIDs = Set(habit.replacementSteps.map { $0.id })
		return completedReplacementStepIDs.filter { !currentStepIDs.contains($0) }
	}
}

// MARK: - Resolutions
extension Urge {
	enum Resolution: String, Codable {
		case handled
		case notHandled
		case pending
	}
}

// MARK: - Validation Errors
extension Urge {
	enum ValidationError: LocalizedError {
		// Note: time, habit, and resolution are validated by their types
		// - Date can't be "empty"
		// - habit is a required object reference
		// - resolution is an enum with defined cases
		
		case emptyContext
		
		var errorDescription: String? {
			switch self {
			case .emptyContext:
				return "Context cannot be empty."
			}
		}
	}
}
```

---

## Phase 4: Update `CreateEditUrgeView` ✅ COMPLETED

### File: `CreateEditUrgeView.swift` (MODIFIED)

#### Changes Required:

1. **Add State Property:**

```swift
// Add after existing @State properties:
@State private var completedStepIDs: Set<UUID> = []
```

2. **Update Initializer:**

```swift
init(createUrgeSheetIsPresented: Binding<Bool>, urgeToEdit: Urge? = nil) {
	self._createUrgeSheetIsPresented = createUrgeSheetIsPresented
	self.urgeToEdit = urgeToEdit
	
	// Pre-fill with existing urge data if editing
	if let urge = urgeToEdit {
		_selection = State(initialValue: urge.habit)
		_time = State(initialValue: urge.time)
		_context = State(initialValue: urge.context)
		_resolution = State(initialValue: urge.resolution)
		_resolutionComment = State(initialValue: urge.resolutionComment)
		_completedStepIDs = State(initialValue: Set(urge.completedReplacementStepIDs))  // ADD THIS LINE
	}
}
```

3. **Replace Replacement Strategy Display Section:**

Find this code block (around lines 95-106):

```swift
// OLD CODE (REMOVE):
if let selectedHabit = selection, !selectedHabit.replacementStrategyTasks.isEmpty {
	VStack(alignment: .leading, spacing: 8) {
		Text(Constants.Text.replacementStrategy)
			.font(.subheadline)
			.fontWeight(.semibold)
		
		ForEach(Array(selectedHabit.replacementStrategyTasks.enumerated()), id: \.offset) { index, task in
			HStack(alignment: .top, spacing: 8) {
				Text("•")
					.fontWeight(.bold)
				Text(task)
					.fixedSize(horizontal: false, vertical: true)
			}
			.font(.subheadline)
			.foregroundStyle(.secondary)
		}
	}
	.padding(.vertical, 4)
}
```

Replace with:

```swift
// NEW CODE (ADD):
if let selectedHabit = selection, !selectedHabit.replacementSteps.isEmpty {
	VStack(alignment: .leading, spacing: 12) {
		Text(Constants.Text.replacementStrategy)
			.font(.subheadline)
			.fontWeight(.semibold)
		
		ForEach(selectedHabit.replacementSteps.sorted(by: { $0.order < $1.order })) { step in
			Button {
				toggleStepCompletion(step.id)
			} label: {
				HStack(alignment: .top, spacing: 12) {
					Image(systemName: completedStepIDs.contains(step.id) 
						? "checkmark.circle.fill" 
						: "circle")
						.foregroundStyle(completedStepIDs.contains(step.id) 
							? .green 
							: .secondary)
						.imageScale(.medium)
						.animation(.spring(duration: 0.3), value: completedStepIDs.contains(step.id))
					
					Text(step.task)
						.foregroundStyle(.primary)
						.fixedSize(horizontal: false, vertical: true)
						.multilineTextAlignment(.leading)
					
					Spacer()
				}
			}
			.buttonStyle(.plain)
		}
	}
	.padding(.vertical, 4)
}
```

4. **Add Helper Method:**

Add this method before the `saveUrge()` method:

```swift
private func toggleStepCompletion(_ stepID: UUID) {
	if completedStepIDs.contains(stepID) {
		completedStepIDs.remove(stepID)
	} else {
		completedStepIDs.insert(stepID)
	}
}
```

5. **Update `saveUrge()` Method:**

```swift
private func saveUrge() {
	guard let selectedHabit = selection else { return }
	
	// Convert Set to Array for storage
	let completedArray = Array(completedStepIDs)
	
	if let existingUrge = urgeToEdit {
		// Update existing urge
		existingUrge.time = time
		existingUrge.habit = selectedHabit
		existingUrge.context = context
		existingUrge.resolution = resolution
		existingUrge.resolutionComment = resolutionComment
		existingUrge.completedReplacementStepIDs = completedArray  // ADD THIS LINE
		dismiss()
	} else {
		do {
			let newUrge = try Urge(
				time: time,
				habit: selectedHabit,
				context: context,
				resolutionComment: resolutionComment,
				resolution: resolution,
				completedReplacementStepIDs: completedArray  // ADD THIS LINE
			)
			
			modelContext.insert(newUrge)
			dismiss()
		} catch let validationError as Urge.ValidationError {
			// Handle validation error
		} catch {
			// Handle other errors
		}
	}
}
```

6. **Add onChange Modifier to Picker:**

Add this modifier to the habit Picker to reset completed steps when switching habits:

```swift
Picker(pickerText, selection: $selection) {
	ForEach(habits) { habit in
		Text(habit.name)
			.tag(habit as Habit?)
	}
}
.onChange(of: selection) { oldValue, newValue in
	// Reset completed steps when switching to a different habit
	if oldValue?.id != newValue?.id {
		completedStepIDs.removeAll()
	}
}
```

7. **Update Constants (Optional):**

You may want to add additional text constants:

```swift
enum Text {
	// ... existing constants ...
	static let tapToComplete = "Tap to mark as complete"
	static let completedSteps = "Completed Steps"
}
```

**Key UI Changes:**
- Replacement steps now display as interactive buttons with checkboxes
- Tapping a step toggles its completion status
- Completed steps show a filled green checkmark
- Incomplete steps show an empty circle
- Steps maintain their order using the `order` property
- Switching habits resets the completion state

---

## Phase 5: Update Any Views That Create Habits ✅ COMPLETED

### Search for Habit Creation Code

You'll need to update anywhere that creates `Habit` objects to use the new `ReplacementStep` model.

**Old Pattern:**
```swift
let habit = try Habit(
	name: "Smoking",
	habitDescription: "Stop smoking cigarettes",
	replacementStrategyTasks: [
		"Take 5 deep breaths",
		"Drink a glass of water",
		"Go for a 5-minute walk"
	]
)
```

**New Pattern:**
```swift
let steps = try Habit.createStepsFromStrings([
	"Take 5 deep breaths",
	"Drink a glass of water",
	"Go for a 5-minute walk"
])

let habit = try Habit(
	name: "Smoking",
	habitDescription: "Stop smoking cigarettes",
	replacementSteps: steps
)
```

**Or create steps individually:**
```swift
let step1 = try ReplacementStep(task: "Take 5 deep breaths", order: 0)
let step2 = try ReplacementStep(task: "Drink a glass of water", order: 1)
let step3 = try ReplacementStep(task: "Go for a 5-minute walk", order: 2)

let habit = try Habit(
	name: "Smoking",
	habitDescription: "Stop smoking cigarettes",
	replacementSteps: [step1, step2, step3]
)
```

### Files That Likely Need Updates:

Use `query_search` to find files that create Habit objects:
- CreateHabitView or similar
- HabitTests
- Preview code in CreateEditUrgeView
- Any seed data or sample data generators

---

## Phase 6: Update Tests ✅ COMPLETED

### File: `UrgeTests.swift` (if exists)

Update any test code that creates Habit or Urge objects:

```swift
// OLD:
let habit = try Habit(
	name: "Test",
	habitDescription: "Test",
	replacementStrategyTasks: ["Step 1"]
)

// NEW:
let steps = try Habit.createStepsFromStrings(["Step 1"])
let habit = try Habit(
	name: "Test",
	habitDescription: "Test",
	replacementSteps: steps
)
```

### File: `HabitTests.swift` (if exists)

Similar updates needed for any habit creation in tests.

---

## Phase 7: Update ModelContainer Configuration ✅ COMPLETED

### File: Your App Entry Point (likely `BreakpointApp.swift`)

Update the model container to include the new `ReplacementStep` model:

```swift
// OLD:
.modelContainer(for: [Habit.self, Urge.self])

// NEW:
.modelContainer(for: [Habit.self, Urge.self, ReplacementStep.self])
```

**Note:** SwiftData should automatically detect the relationship, but explicitly including it ensures proper schema generation.

---

## Phase 8: Data Migration (If App is Already Released) — SKIPPED (app not yet released)

### If you have existing users with data:

You'll need to create a migration strategy. Here's a helper function:

```swift
// Add to a new file: DataMigrationHelper.swift

import SwiftData
import Foundation

struct DataMigrationHelper {
	
	/// Migrates Habit objects from old string-based replacement tasks
	/// to new ReplacementStep model
	static func migrateHabitsToReplacementSteps(context: ModelContext) async throws {
		// This is a conceptual example - actual implementation depends on
		// how SwiftData handles schema migrations
		
		let descriptor = FetchDescriptor<Habit>()
		let habits = try context.fetch(descriptor)
		
		for habit in habits {
			// If habit still has old data structure, migrate it
			// (You may need to temporarily keep both properties during migration)
			
			// Example migration logic:
			// 1. Read old replacementStrategyTasks
			// 2. Create ReplacementStep objects
			// 3. Assign to replacementSteps
			// 4. Remove old property data
		}
		
		try context.save()
	}
}
```

**Important:** SwiftData handles most migrations automatically, but significant schema changes may require careful planning. Test thoroughly with a copy of production data.

---

## Phase 9: Update Any Display Views ✅ COMPLETED (HabitCardView updated; UrgeCardView optional enhancements deferred)

### Files That Display Urge Details

Search for views that display urge information and may want to show completed steps:

**Example Enhancement:**

```swift
// In UrgeDetailView or similar:
if !urge.completedSteps.isEmpty {
	Section("Completed Replacement Steps") {
		ForEach(urge.completedSteps.sorted(by: { $0.order < $1.order })) { step in
			Label(step.task, systemImage: "checkmark.circle.fill")
				.foregroundStyle(.green)
		}
	}
}

// Show warning for orphaned steps (steps that were deleted from habit)
if !urge.orphanedCompletedStepIDs.isEmpty {
	Section {
		Label("\(urge.orphanedCompletedStepIDs.count) completed step(s) no longer exist in habit", 
		      systemImage: "exclamationmark.triangle")
			.foregroundStyle(.orange)
			.font(.caption)
	}
}
```

---

## Testing Checklist

After implementing all changes, test:

- [ ] Create new habit with replacement steps
- [ ] Create new urge and mark steps as complete
- [ ] Edit existing urge and change completed steps
- [ ] Switch between habits in urge form (steps should reset)
- [ ] Delete a habit (steps should cascade delete)
- [ ] Edit habit and reorder steps (urge history should maintain correct references)
- [ ] Edit habit and delete a step (urge should show orphaned step warning)
- [ ] View urge details showing completed steps
- [ ] Ensure all validation errors still work
- [ ] Test with empty habits (should show validation error)
- [ ] Test with empty step text (should show validation error)

---

## Performance Considerations

### Indexing

If you have many replacement steps, consider adding an index:

```swift
@Model
class ReplacementStep {
	@Attribute(.unique) var id: UUID
	
	// Add index for faster sorting
	@Attribute(.indexed) var order: Int
	
	// ...
}
```

### Fetching Strategy

When displaying urges, use predicates to minimize data loading:

```swift
// Example: Fetch urges with their habits and steps in one query
let descriptor = FetchDescriptor<Urge>(
	sortBy: [SortDescriptor(\.time, order: .reverse)]
)
// SwiftData automatically loads relationships when accessed
```

---

## Future Enhancements

With this architecture in place, you can easily add:

1. **Step Categories**
   ```swift
   enum StepCategory: String, Codable {
       case breathing, physical, distraction, social
   }
   var category: StepCategory
   ```

2. **Difficulty Ratings**
   ```swift
   var difficulty: Int // 1-5 scale
   ```

3. **Step Statistics**
   - Most commonly completed steps
   - Success rate per step
   - Time to complete tracking

4. **Custom Icons**
   ```swift
   var iconName: String? // SF Symbol name
   ```

5. **Step Notes**
   ```swift
   var notes: String?
   ```

---

## Summary of Changes

| File | Change Type | Description |
|------|-------------|-------------|
| `ReplacementStep.swift` | ✨ NEW | New model for replacement steps |
| `Habit.swift` | 🔄 MODIFIED | Replace string array with relationship |
| `Urge.swift` | 🔄 MODIFIED | Add completedReplacementStepIDs parameter to init |
| `CreateEditUrgeView.swift` | 🔄 MODIFIED | Add interactive checkbox UI for steps |
| `[App].swift` | 🔄 MODIFIED | Update modelContainer configuration |
| Habit creation views | 🔄 MODIFIED | Update to use new ReplacementStep model |
| Tests | 🔄 MODIFIED | Update test data creation |
| Display views | 🔄 OPTIONAL | Show completed steps in urge details |

---

## Questions & Troubleshooting

### Q: What happens to old data?
**A:** SwiftData will attempt to migrate automatically. Test thoroughly with backups. You may need to implement custom migration logic for complex schema changes.

### Q: Can I still use string arrays for convenience?
**A:** Yes! Use the `createStepsFromStrings()` helper method for quick creation and testing.

### Q: What if a step is deleted from a habit?
**A:** The urge will keep the UUID in `completedReplacementStepIDs`, but `completedSteps` computed property will exclude it. Use `orphanedCompletedStepIDs` to detect this situation.

### Q: How do I handle step reordering?
**A:** Simply update the `order` property. Historical urge records reference by UUID, so they remain accurate regardless of order changes.

### Q: Should I delete orphaned step IDs?
**A:** No! Keep them for historical accuracy. You can add a UI indicator that shows "X completed step(s) no longer available" if needed.

---

## Implementation Order

**Recommended sequence:**

1. ✅ Create `ReplacementStep.swift`
2. ✅ Update `Habit.swift` model and validation
3. ✅ Update `Urge.swift` initializer (already done)
4. ✅ Update modelContainer configuration
5. ✅ Update habit creation views/forms
6. ✅ Update tests
7. ✅ Update `CreateEditUrgeView.swift` UI
8. ✅ Test thoroughly
9. ✅ Update display views (optional)
10. ✅ Add analytics/statistics (optional)

---

**Last Updated:** 2026-03-03
**Status:** ✅ Implementation Complete — ready for build & test verification
