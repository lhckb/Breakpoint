//
//  HabitTests.swift
//  BreakpointTests
//
//  Created by Luís Cruz on 10/02/26.
//

import Testing
@testable import Breakpoint
import Foundation


@Suite("Habit Validation Tests")
struct HabitTests {

	// MARK: - Valid Habit Creation Tests

	@Test("Valid habit with all required fields")
	func validHabitCreation() async throws {
		let steps = try ReplacementStep.createStepsFromStrings(["Chew gum", "Go for a walk"])
		let habit = try Habit(
			name: "Stop Smoking",
			habitDescription: "Quit smoking to improve health",
			replacementSteps: steps
		)

		#expect(habit.name == "Stop Smoking")
		#expect(habit.habitDescription == "Quit smoking to improve health")
		#expect(habit.replacementSteps.count == 2)
	}

	@Test("Valid habit with single replacement strategy")
	func validHabitWithSingleStrategy() async throws {
		let steps = try ReplacementStep.createStepsFromStrings(["Drink tea instead"])
		let habit = try Habit(
			name: "Reduce Coffee",
			habitDescription: "Drink less coffee",
			replacementSteps: steps
		)

		#expect(habit.replacementSteps.count == 1)
		#expect(habit.replacementSteps.first?.task == "Drink tea instead")
	}

	@Test("Valid habit with multiple replacement strategies")
	func validHabitWithMultipleStrategies() async throws {
		let steps = try ReplacementStep.createStepsFromStrings([
			"Deep breathing",
			"Take a walk",
			"Call a friend",
			"Drink water",
			"Exercise"
		])

		let habit = try Habit(
			name: "Stop Stress Eating",
			habitDescription: "Avoid eating when stressed",
			replacementSteps: steps
		)

		#expect(habit.replacementSteps.count == 5)
	}

	@Test("Valid habit with whitespace-padded fields")
	func validHabitWithWhitespacePadding() async throws {
		let steps = try ReplacementStep.createStepsFromStrings(["  Use Pomodoro technique  "])
		let habit = try Habit(
			name: "  Stop Procrastinating  ",
			habitDescription: "  Get work done on time  ",
			replacementSteps: steps
		)

		// Should still create successfully as trimmed values are non-empty
		#expect(habit.name == "  Stop Procrastinating  ")
		#expect(habit.habitDescription == "  Get work done on time  ")
	}

	// MARK: - Empty Name Validation Tests

	@Test("Habit with empty name throws error")
	func emptyNameValidation() async throws {
		let steps = try ReplacementStep.createStepsFromStrings(["Valid strategy"])
		#expect(throws: Habit.ValidationError.emptyName) {
			try Habit(
				name: "",
				habitDescription: "Valid description",
				replacementSteps: steps
			)
		}
	}

	@Test("Habit with whitespace-only name throws error")
	func whitespaceOnlyNameValidation() async throws {
		let steps = try ReplacementStep.createStepsFromStrings(["Valid strategy"])
		#expect(throws: Habit.ValidationError.emptyName) {
			try Habit(
				name: "   ",
				habitDescription: "Valid description",
				replacementSteps: steps
			)
		}
	}

	@Test("Habit with tabs-only name throws error")
	func tabsOnlyNameValidation() async throws {
		let steps = try ReplacementStep.createStepsFromStrings(["Valid strategy"])
		#expect(throws: Habit.ValidationError.emptyName) {
			try Habit(
				name: "\t\t\t",
				habitDescription: "Valid description",
				replacementSteps: steps
			)
		}
	}

	@Test("Habit with newlines-only name throws error")
	func newlinesOnlyNameValidation() async throws {
		let steps = try ReplacementStep.createStepsFromStrings(["Valid strategy"])
		#expect(throws: Habit.ValidationError.emptyName) {
			try Habit(
				name: "\n\n",
				habitDescription: "Valid description",
				replacementSteps: steps
			)
		}
	}

	// MARK: - Empty Description Validation Tests

	@Test("Habit with empty description throws error")
	func emptyDescriptionValidation() async throws {
		let steps = try ReplacementStep.createStepsFromStrings(["Valid strategy"])
		#expect(throws: Habit.ValidationError.emptyDescription) {
			try Habit(
				name: "Valid name",
				habitDescription: "",
				replacementSteps: steps
			)
		}
	}

	@Test("Habit with whitespace-only description throws error")
	func whitespaceOnlyDescriptionValidation() async throws {
		let steps = try ReplacementStep.createStepsFromStrings(["Valid strategy"])
		#expect(throws: Habit.ValidationError.emptyDescription) {
			try Habit(
				name: "Valid name",
				habitDescription: "     ",
				replacementSteps: steps
			)
		}
	}

	// MARK: - Replacement Strategy Validation Tests

	@Test("Habit with no replacement strategies throws error")
	func noReplacementStrategiesValidation() async throws {
		#expect(throws: Habit.ValidationError.noReplacementStrategies) {
			try Habit(
				name: "Valid name",
				habitDescription: "Valid description",
				replacementSteps: []
			)
		}
	}

	// MARK: - ReplacementStep Validation Tests

	@Test("ReplacementStep with empty task throws error")
	func emptyReplacementStepValidation() async throws {
		#expect(throws: ReplacementStep.ValidationError.emptyTask) {
			try ReplacementStep(task: "", order: 0)
		}
	}

	@Test("ReplacementStep with whitespace-only task throws error")
	func whitespaceOnlyReplacementStepValidation() async throws {
		#expect(throws: ReplacementStep.ValidationError.emptyTask) {
			try ReplacementStep(task: "   ", order: 0)
		}
	}

	@Test("createStepsFromStrings skips empty strings via validation error")
	func createStepsFromStringsWithEmptyThrows() async throws {
		#expect(throws: ReplacementStep.ValidationError.emptyTask) {
			try ReplacementStep.createStepsFromStrings(["Valid strategy", "", "Another strategy"])
		}
	}

	// MARK: - Error Message Tests

	@Test("Empty name error has correct description")
	func emptyNameErrorMessage() async throws {
		let error = Habit.ValidationError.emptyName
		#expect(error.errorDescription == "Habit name cannot be empty.")
	}

	@Test("Empty description error has correct description")
	func emptyDescriptionErrorMessage() async throws {
		let error = Habit.ValidationError.emptyDescription
		#expect(error.errorDescription == "Habit description cannot be empty.")
	}

	@Test("No replacement strategies error has correct description")
	func noReplacementStrategiesErrorMessage() async throws {
		let error = Habit.ValidationError.noReplacementStrategies
		#expect(error.errorDescription == "At least one replacement strategy is required.")
	}

	@Test("Empty step task error has correct description")
	func emptyStepTaskErrorMessage() async throws {
		let error = ReplacementStep.ValidationError.emptyTask
		#expect(error.errorDescription == "Replacement step task cannot be empty.")
	}

	// MARK: - ReplacementStep Order Tests

	@Test("createStepsFromStrings assigns correct order values")
	func stepsHaveCorrectOrder() async throws {
		let steps = try ReplacementStep.createStepsFromStrings(["First", "Second", "Third"])
		let sorted = steps.sorted(by: { $0.order < $1.order })
		#expect(sorted[0].task == "First")
		#expect(sorted[0].order == 0)
		#expect(sorted[1].task == "Second")
		#expect(sorted[1].order == 1)
		#expect(sorted[2].task == "Third")
		#expect(sorted[2].order == 2)
	}

	// MARK: - Edge Case Tests

	@Test("Habit with very long name is valid")
	func veryLongNameValidation() async throws {
		let longName = String(repeating: "A", count: 1000)
		let steps = try ReplacementStep.createStepsFromStrings(["Strategy"])

		let habit = try Habit(
			name: longName,
			habitDescription: "Description",
			replacementSteps: steps
		)

		#expect(habit.name.count == 1000)
	}

	@Test("Habit with special characters in name is valid")
	func specialCharactersInNameValidation() async throws {
		let steps = try ReplacementStep.createStepsFromStrings(["🚶 Walk", "💧 Drink water"])
		let habit = try Habit(
			name: "Stop 🚬 Smoking!",
			habitDescription: "Quit smoking 💪",
			replacementSteps: steps
		)

		#expect(habit.name.contains("🚬"))
		#expect(habit.replacementSteps.sorted(by: { $0.order < $1.order })[0].task.contains("🚶"))
	}

	@Test("Habit with unicode characters is valid")
	func unicodeCharactersValidation() async throws {
		let steps = try ReplacementStep.createStepsFromStrings(["喝水", "Пить воду"])
		let habit = try Habit(
			name: "Arrêter de fumer",
			habitDescription: "Aufhören zu rauchen",
			replacementSteps: steps
		)

		#expect(habit.name == "Arrêter de fumer")
		#expect(habit.replacementSteps.count == 2)
	}
}
