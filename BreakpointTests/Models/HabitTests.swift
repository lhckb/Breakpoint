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
struct HabitValidationTests {
	
	// MARK: - Valid Habit Creation Tests
	
	@Test("Valid habit with all required fields")
	func validHabitCreation() async throws {
		let habit = try Habit(
			name: "Stop Smoking",
			habitDescription: "Quit smoking to improve health",
			replacementStrategyTasks: ["Chew gum", "Go for a walk"]
		)
		
		#expect(habit.name == "Stop Smoking")
		#expect(habit.habitDescription == "Quit smoking to improve health")
		#expect(habit.replacementStrategyTasks.count == 2)
	}
	
	@Test("Valid habit with single replacement strategy")
	func validHabitWithSingleStrategy() async throws {
		let habit = try Habit(
			name: "Reduce Coffee",
			habitDescription: "Drink less coffee",
			replacementStrategyTasks: ["Drink tea instead"]
		)
		
		#expect(habit.replacementStrategyTasks.count == 1)
		#expect(habit.replacementStrategyTasks.first == "Drink tea instead")
	}
	
	@Test("Valid habit with multiple replacement strategies")
	func validHabitWithMultipleStrategies() async throws {
		let strategies = [
			"Deep breathing",
			"Take a walk",
			"Call a friend",
			"Drink water",
			"Exercise"
		]
		
		let habit = try Habit(
			name: "Stop Stress Eating",
			habitDescription: "Avoid eating when stressed",
			replacementStrategyTasks: strategies
		)
		
		#expect(habit.replacementStrategyTasks.count == 5)
	}
	
	@Test("Valid habit with whitespace-padded fields")
	func validHabitWithWhitespacePadding() async throws {
		let habit = try Habit(
			name: "  Stop Procrastinating  ",
			habitDescription: "  Get work done on time  ",
			replacementStrategyTasks: ["  Use Pomodoro technique  "]
		)
		
		// Should still create successfully as trimmed values are non-empty
		#expect(habit.name == "  Stop Procrastinating  ")
		#expect(habit.habitDescription == "  Get work done on time  ")
	}
	
	// MARK: - Empty Name Validation Tests
	
	@Test("Habit with empty name throws error")
	func emptyNameValidation() async throws {
		#expect(throws: Habit.ValidationError.emptyName) {
			try Habit(
				name: "",
				habitDescription: "Valid description",
				replacementStrategyTasks: ["Valid strategy"]
			)
		}
	}
	
	@Test("Habit with whitespace-only name throws error")
	func whitespaceOnlyNameValidation() async throws {
		#expect(throws: Habit.ValidationError.emptyName) {
			try Habit(
				name: "   ",
				habitDescription: "Valid description",
				replacementStrategyTasks: ["Valid strategy"]
			)
		}
	}
	
	@Test("Habit with tabs-only name throws error")
	func tabsOnlyNameValidation() async throws {
		#expect(throws: Habit.ValidationError.emptyName) {
			try Habit(
				name: "\t\t\t",
				habitDescription: "Valid description",
				replacementStrategyTasks: ["Valid strategy"]
			)
		}
	}
	
	@Test("Habit with newlines-only name throws error")
	func newlinesOnlyNameValidation() async throws {
		#expect(throws: Habit.ValidationError.emptyName) {
			try Habit(
				name: "\n\n",
				habitDescription: "Valid description",
				replacementStrategyTasks: ["Valid strategy"]
			)
		}
	}
	
	// MARK: - Empty Description Validation Tests
	
	@Test("Habit with empty description throws error")
	func emptyDescriptionValidation() async throws {
		#expect(throws: Habit.ValidationError.emptyDescription) {
			try Habit(
				name: "Valid name",
				habitDescription: "",
				replacementStrategyTasks: ["Valid strategy"]
			)
		}
	}
	
	@Test("Habit with whitespace-only description throws error")
	func whitespaceOnlyDescriptionValidation() async throws {
		#expect(throws: Habit.ValidationError.emptyDescription) {
			try Habit(
				name: "Valid name",
				habitDescription: "     ",
				replacementStrategyTasks: ["Valid strategy"]
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
				replacementStrategyTasks: []
			)
		}
	}
	
	@Test("Habit with empty replacement strategy throws error")
	func emptyReplacementStrategyValidation() async throws {
		#expect(throws: Habit.ValidationError.emptyReplacementStrategy) {
			try Habit(
				name: "Valid name",
				habitDescription: "Valid description",
				replacementStrategyTasks: ["Valid strategy", "", "Another strategy"]
			)
		}
	}
	
	@Test("Habit with whitespace-only replacement strategy throws error")
	func whitespaceOnlyReplacementStrategyValidation() async throws {
		#expect(throws: Habit.ValidationError.emptyReplacementStrategy) {
			try Habit(
				name: "Valid name",
				habitDescription: "Valid description",
				replacementStrategyTasks: ["Valid strategy", "   ", "Another strategy"]
			)
		}
	}
	
	@Test("Habit with all empty replacement strategies throws error")
	func allEmptyReplacementStrategiesValidation() async throws {
		#expect(throws: Habit.ValidationError.emptyReplacementStrategy) {
			try Habit(
				name: "Valid name",
				habitDescription: "Valid description",
				replacementStrategyTasks: ["", "  ", "\t"]
			)
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
	
	@Test("Empty replacement strategy error has correct description")
	func emptyReplacementStrategyErrorMessage() async throws {
		let error = Habit.ValidationError.emptyReplacementStrategy
		#expect(error.errorDescription == "Replacement strategies cannot be empty.")
	}
	
	// MARK: - Edge Case Tests
	
	@Test("Habit with very long name is valid")
	func veryLongNameValidation() async throws {
		let longName = String(repeating: "A", count: 1000)
		
		let habit = try Habit(
			name: longName,
			habitDescription: "Description",
			replacementStrategyTasks: ["Strategy"]
		)
		
		#expect(habit.name.count == 1000)
	}
	
	@Test("Habit with special characters in name is valid")
	func specialCharactersInNameValidation() async throws {
		let habit = try Habit(
			name: "Stop 🚬 Smoking!",
			habitDescription: "Quit smoking 💪",
			replacementStrategyTasks: ["🚶 Walk", "💧 Drink water"]
		)
		
		#expect(habit.name.contains("🚬"))
		#expect(habit.replacementStrategyTasks[0].contains("🚶"))
	}
	
	@Test("Habit with unicode characters is valid")
	func unicodeCharactersValidation() async throws {
		let habit = try Habit(
			name: "Arrêter de fumer",
			habitDescription: "Aufhören zu rauchen",
			replacementStrategyTasks: ["喝水", "Пить воду"]
		)
		
		#expect(habit.name == "Arrêter de fumer")
		#expect(habit.replacementStrategyTasks.count == 2)
	}
}

