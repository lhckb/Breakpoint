//
//  ReplacementStepTests.swift
//  BreakpointTests
//
//  Created by Luís Cruz on 05/03/26.
//

import Testing
@testable import Breakpoint
import Foundation


@Suite("ReplacementStep Validation Tests")
struct ReplacementStepTests {

	// MARK: - Valid ReplacementStep Creation Tests

	@Test("Valid replacement step with all required fields")
	func validReplacementStepCreation() async throws {
		let step = try ReplacementStep(task: "Chew gum", order: 0)

		#expect(step.task == "Chew gum")
		#expect(step.order == 0)
		#expect(step.habit == nil)
		#expect(step.id != UUID(uuidString: "00000000-0000-0000-0000-000000000000"))
	}

	@Test("Valid replacement step with habit relationship")
	func validReplacementStepWithHabit() async throws {
		let steps = try ReplacementStep.createStepsFromStrings(["Strategy 1"])
		let habit = try Habit(
			name: "Test Habit",
			habitDescription: "Test Description",
			replacementSteps: steps
		)

		let step = try ReplacementStep(task: "Walk for 10 minutes", order: 1, habit: habit)

		#expect(step.task == "Walk for 10 minutes")
		#expect(step.order == 1)
		#expect(step.habit === habit)
	}

	@Test("Valid replacement step with whitespace-padded task")
	func validReplacementStepWithWhitespacePadding() async throws {
		let step = try ReplacementStep(task: "  Drink water  ", order: 0)

		// Should still create successfully as trimmed value is non-empty
		#expect(step.task == "  Drink water  ")
	}

	@Test("Valid replacement step with different order values")
	func validReplacementStepWithDifferentOrders() async throws {
		let step1 = try ReplacementStep(task: "First", order: 0)
		let step2 = try ReplacementStep(task: "Second", order: 5)
		let step3 = try ReplacementStep(task: "Third", order: 100)

		#expect(step1.order == 0)
		#expect(step2.order == 5)
		#expect(step3.order == 100)
	}

	@Test("Valid replacement step with negative order value")
	func validReplacementStepWithNegativeOrder() async throws {
		let step = try ReplacementStep(task: "Task", order: -1)

		#expect(step.order == -1)
	}

	// MARK: - Empty Task Validation Tests

	@Test("ReplacementStep with empty task throws error")
	func emptyTaskValidation() async throws {
		#expect(throws: ReplacementStep.ValidationError.emptyTask) {
			try ReplacementStep(task: "", order: 0)
		}
	}

	@Test("ReplacementStep with whitespace-only task throws error")
	func whitespaceOnlyTaskValidation() async throws {
		#expect(throws: ReplacementStep.ValidationError.emptyTask) {
			try ReplacementStep(task: "   ", order: 0)
		}
	}

	@Test("ReplacementStep with tabs-only task throws error")
	func tabsOnlyTaskValidation() async throws {
		#expect(throws: ReplacementStep.ValidationError.emptyTask) {
			try ReplacementStep(task: "\t\t\t", order: 0)
		}
	}

	@Test("ReplacementStep with newlines-only task throws error")
	func newlinesOnlyTaskValidation() async throws {
		#expect(throws: ReplacementStep.ValidationError.emptyTask) {
			try ReplacementStep(task: "\n\n", order: 0)
		}
	}

	@Test("ReplacementStep with mixed whitespace task throws error")
	func mixedWhitespaceTaskValidation() async throws {
		#expect(throws: ReplacementStep.ValidationError.emptyTask) {
			try ReplacementStep(task: " \t \n ", order: 0)
		}
	}

	// MARK: - Error Message Tests

	@Test("Empty task error has correct description")
	func emptyTaskErrorMessage() async throws {
		let error = ReplacementStep.ValidationError.emptyTask
		#expect(error.errorDescription == "Replacement step task cannot be empty.")
	}

	// MARK: - UUID Tests

	@Test("Each replacement step has unique UUID")
	func uniqueUUIDGeneration() async throws {
		let step1 = try ReplacementStep(task: "Task 1", order: 0)
		let step2 = try ReplacementStep(task: "Task 2", order: 1)
		let step3 = try ReplacementStep(task: "Task 3", order: 2)

		#expect(step1.id != step2.id)
		#expect(step2.id != step3.id)
		#expect(step1.id != step3.id)
	}

	// MARK: - createStepsFromStrings Tests

	@Test("createStepsFromStrings creates single step")
	func createSingleStepFromStrings() async throws {
		let steps = try ReplacementStep.createStepsFromStrings(["First step"])

		#expect(steps.count == 1)
		#expect(steps[0].task == "First step")
		#expect(steps[0].order == 0)
	}

	@Test("createStepsFromStrings creates multiple steps")
	func createMultipleStepsFromStrings() async throws {
		let steps = try ReplacementStep.createStepsFromStrings([
			"First step",
			"Second step",
			"Third step"
		])

		#expect(steps.count == 3)
		#expect(steps[0].task == "First step")
		#expect(steps[1].task == "Second step")
		#expect(steps[2].task == "Third step")
	}

	@Test("createStepsFromStrings assigns correct order values")
	func createStepsAssignsCorrectOrder() async throws {
		let steps = try ReplacementStep.createStepsFromStrings([
			"First",
			"Second",
			"Third",
			"Fourth",
			"Fifth"
		])

		#expect(steps.count == 5)
		for (index, step) in steps.enumerated() {
			#expect(step.order == index)
		}
	}

	@Test("createStepsFromStrings with empty array returns empty array")
	func createStepsFromEmptyArray() async throws {
		let steps = try ReplacementStep.createStepsFromStrings([])

		#expect(steps.isEmpty)
	}

	@Test("createStepsFromStrings throws error with empty string")
	func createStepsThrowsWithEmptyString() async throws {
		#expect(throws: ReplacementStep.ValidationError.emptyTask) {
			try ReplacementStep.createStepsFromStrings(["Valid", "", "Another valid"])
		}
	}

	@Test("createStepsFromStrings throws error with whitespace-only string")
	func createStepsThrowsWithWhitespaceString() async throws {
		#expect(throws: ReplacementStep.ValidationError.emptyTask) {
			try ReplacementStep.createStepsFromStrings(["Valid", "   ", "Another valid"])
		}
	}

	@Test("createStepsFromStrings creates steps with unique UUIDs")
	func createStepsHaveUniqueUUIDs() async throws {
		let steps = try ReplacementStep.createStepsFromStrings([
			"First",
			"Second",
			"Third"
		])

		let uniqueIDs = Set(steps.map { $0.id })
		#expect(uniqueIDs.count == steps.count)
	}

	@Test("createStepsFromStrings creates steps with nil habit")
	func createStepsHaveNilHabit() async throws {
		let steps = try ReplacementStep.createStepsFromStrings([
			"First",
			"Second"
		])

		for step in steps {
			#expect(step.habit == nil)
		}
	}

	// MARK: - Edge Case Tests

	@Test("ReplacementStep with very long task is valid")
	func veryLongTaskValidation() async throws {
		let longTask = String(repeating: "A", count: 10000)
		let step = try ReplacementStep(task: longTask, order: 0)

		#expect(step.task.count == 10000)
	}

	@Test("ReplacementStep with special characters is valid")
	func specialCharactersInTaskValidation() async throws {
		let step = try ReplacementStep(
			task: "🚶‍♂️ Walk for 10 minutes! 💪",
			order: 0
		)

		#expect(step.task.contains("🚶‍♂️"))
		#expect(step.task.contains("💪"))
	}

	@Test("ReplacementStep with unicode characters is valid")
	func unicodeCharactersValidation() async throws {
		let step1 = try ReplacementStep(task: "喝水", order: 0)
		let step2 = try ReplacementStep(task: "Пить воду", order: 1)
		let step3 = try ReplacementStep(task: "Boire de l'eau", order: 2)

		#expect(step1.task == "喝水")
		#expect(step2.task == "Пить воду")
		#expect(step3.task == "Boire de l'eau")
	}

	@Test("ReplacementStep with newlines in task is valid")
	func newlinesInTaskValidation() async throws {
		let step = try ReplacementStep(
			task: "Step 1:\nWalk outside\nBreathe deeply",
			order: 0
		)

		#expect(step.task.contains("\n"))
		#expect(step.task == "Step 1:\nWalk outside\nBreathe deeply")
	}

	@Test("ReplacementStep with tabs in task is valid")
	func tabsInTaskValidation() async throws {
		let step = try ReplacementStep(
			task: "Step:\tDrink water\tRelax",
			order: 0
		)

		#expect(step.task.contains("\t"))
	}

	@Test("ReplacementStep with very large order value")
	func veryLargeOrderValue() async throws {
		let step = try ReplacementStep(task: "Task", order: Int.max)

		#expect(step.order == Int.max)
	}

	@Test("ReplacementStep with very small order value")
	func verySmallOrderValue() async throws {
		let step = try ReplacementStep(task: "Task", order: Int.min)

		#expect(step.order == Int.min)
	}

	@Test("createStepsFromStrings with single character tasks")
	func createStepsWithSingleCharacterTasks() async throws {
		let steps = try ReplacementStep.createStepsFromStrings(["A", "B", "C"])

		#expect(steps.count == 3)
		#expect(steps[0].task == "A")
		#expect(steps[1].task == "B")
		#expect(steps[2].task == "C")
	}

	@Test("ReplacementStep with minimum valid data")
	func minimumValidReplacementStep() async throws {
		let step = try ReplacementStep(task: "X", order: 0)

		#expect(step.task == "X")
		#expect(step.order == 0)
		#expect(step.habit == nil)
	}
}
