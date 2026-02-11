//
//  UrgeTests.swift
//  BreakpointTests
//
//  Created by Luís Cruz on 10/02/26.
//

import Testing
@testable import Breakpoint
import Foundation


@Suite("Urge Validation Tests")
struct UrgeValidationTests {
	
	// MARK: - Test Fixtures
	
	/// Creates a valid test habit for use in urge tests
	func createTestHabit() throws -> Habit {
		try Habit(
			name: "Test Habit",
			habitDescription: "A test habit for urge testing",
			replacementStrategyTasks: ["Strategy 1", "Strategy 2"]
		)
	}
	
	// MARK: - Valid Urge Creation Tests
	
	@Test("Valid urge with all fields")
	func validUrgeCreation() async throws {
		let habit = try createTestHabit()
		let time = Date()
		
		let urge = try Urge(
			time: time,
			habit: habit,
			context: "At a party with friends",
			resolutionComment: "Used deep breathing technique",
			resolution: .handled
		)
		
		#expect(urge.time == time)
		#expect(urge.habit === habit)
		#expect(urge.resolution == .handled)
		#expect(urge.context == "At a party with friends")
		#expect(urge.resolutionComment == "Used deep breathing technique")
	}
	
	@Test("Valid urge with empty resolution comment")
	func validUrgeWithEmptyComment() async throws {
		let habit = try createTestHabit()
		
		let urge = try Urge(
			time: Date(),
			habit: habit,
			context: "During work stress",
			resolution: .notHandled
		)
		
		#expect(urge.context == "During work stress")
		#expect(urge.resolutionComment == "")
	}
	
	@Test("Valid urge with explicit empty resolution comment")
	func validUrgeWithExplicitEmptyComment() async throws {
		let habit = try createTestHabit()
		
		let urge = try Urge(
			time: Date(),
			habit: habit,
			context: "Morning coffee break",
			resolutionComment: "",
			resolution: .handled
		)
		
		#expect(urge.resolutionComment == "")
	}
	
	@Test("Valid urge with 'handled' resolution")
	func validUrgeWithHandledResolution() async throws {
		let habit = try createTestHabit()
		
		let urge = try Urge(
			time: Date(),
			habit: habit,
			context: "After lunch",
			resolutionComment: "Successfully resisted",
			resolution: .handled
		)
		
		#expect(urge.resolution == .handled)
	}
	
	@Test("Valid urge with 'notHandled' resolution")
	func validUrgeWithNotHandledResolution() async throws {
		let habit = try createTestHabit()
		
		let urge = try Urge(
			time: Date(),
			habit: habit,
			context: "Late at night",
			resolutionComment: "Gave in to the urge",
			resolution: .notHandled
		)
		
		#expect(urge.resolution == .notHandled)
	}
	
	@Test("Valid urge with past date")
	func validUrgeWithPastDate() async throws {
		let habit = try createTestHabit()
		let pastDate = Date(timeIntervalSinceNow: -3600) // 1 hour ago
		
		let urge = try Urge(
			time: pastDate,
			habit: habit,
			context: "Earlier today",
			resolution: .handled
		)
		
		#expect(urge.time == pastDate)
	}
	
	@Test("Valid urge with future date")
	func validUrgeWithFutureDate() async throws {
		let habit = try createTestHabit()
		let futureDate = Date(timeIntervalSinceNow: 3600) // 1 hour from now
		
		let urge = try Urge(
			time: futureDate,
			habit: habit,
			context: "Scheduled reminder",
			resolution: .handled
		)
		
		#expect(urge.time == futureDate)
	}
	
	@Test("Valid urge with whitespace-padded context")
	func validUrgeWithWhitespacePaddedContext() async throws {
		let habit = try createTestHabit()
		
		let urge = try Urge(
			time: Date(),
			habit: habit,
			context: "  Valid context with padding  ",
			resolution: .handled
		)
		
		// Should still create successfully as trimmed value is non-empty
		#expect(urge.context == "  Valid context with padding  ")
	}
	
	// MARK: - Empty Context Validation Tests
	
	@Test("Urge with empty context throws error")
	func emptyContextValidation() async throws {
		let habit = try createTestHabit()
		
		#expect(throws: Urge.ValidationError.emptyContext) {
			try Urge(
				time: Date(),
				habit: habit,
				context: "",
				resolutionComment: "Valid comment",
				resolution: .handled
			)
		}
	}
	
	@Test("Urge with whitespace-only context throws error")
	func whitespaceOnlyContextValidation() async throws {
		let habit = try createTestHabit()
		
		#expect(throws: Urge.ValidationError.emptyContext) {
			try Urge(
				time: Date(),
				habit: habit,
				context: "     ",
				resolutionComment: "Valid comment",
				resolution: .handled
			)
		}
	}
	
	@Test("Urge with tabs-only context throws error")
	func tabsOnlyContextValidation() async throws {
		let habit = try createTestHabit()
		
		#expect(throws: Urge.ValidationError.emptyContext) {
			try Urge(
				time: Date(),
				habit: habit,
				context: "\t\t\t",
				resolution: .handled
			)
		}
	}
	
	@Test("Urge with newlines-only context throws error")
	func newlinesOnlyContextValidation() async throws {
		let habit = try createTestHabit()
		
		#expect(throws: Urge.ValidationError.emptyContext) {
			try Urge(
				time: Date(),
				habit: habit,
				context: "\n\n\n",
				resolution: .notHandled
			)
		}
	}
	
	@Test("Urge with mixed whitespace context throws error")
	func mixedWhitespaceContextValidation() async throws {
		let habit = try createTestHabit()
		
		#expect(throws: Urge.ValidationError.emptyContext) {
			try Urge(
				time: Date(),
				habit: habit,
				context: "  \t\n  ",
				resolution: .handled
			)
		}
	}
	
	// MARK: - Error Message Tests
	
	@Test("Empty context error has correct description")
	func emptyContextErrorMessage() async throws {
		let error = Urge.ValidationError.emptyContext
		#expect(error.errorDescription == "Context cannot be empty.")
	}
	
	// MARK: - Resolution Enum Tests
	
	@Test("Resolution enum has correct raw values")
	func resolutionEnumRawValues() async throws {
		#expect(Urge.Resolution.handled.rawValue == "handled")
		#expect(Urge.Resolution.notHandled.rawValue == "notHandled")
	}
	
	@Test("Resolution enum can be created from raw values")
	func resolutionEnumFromRawValues() async throws {
		let handled = Urge.Resolution(rawValue: "handled")
		let notHandled = Urge.Resolution(rawValue: "notHandled")
		
		#expect(handled == .handled)
		#expect(notHandled == .notHandled)
	}
	
	@Test("Resolution enum returns nil for invalid raw value")
	func resolutionEnumInvalidRawValue() async throws {
		let invalid = Urge.Resolution(rawValue: "invalid")
		#expect(invalid == nil)
	}
	
	@Test("Urge has default resolution of pending")
	func defaultResolutionValue() async throws {
		let habit = try createTestHabit()
		
		// Create urge without specifying resolution parameter
		let urge = try Urge(
			time: Date(),
			habit: habit,
			context: "Testing default resolution"
		)
		
		#expect(urge.resolution == .pending)
	}
	
	// MARK: - Edge Case Tests
	
	@Test("Urge with very long context is valid")
	func veryLongContextValidation() async throws {
		let habit = try createTestHabit()
		let longContext = String(repeating: "A", count: 10000)
		
		let urge = try Urge(
			time: Date(),
			habit: habit,
			context: longContext,
			resolution: .handled
		)
		
		#expect(urge.context.count == 10000)
	}
	
	@Test("Urge with very long resolution comment is valid")
	func veryLongResolutionCommentValidation() async throws {
		let habit = try createTestHabit()
		let longComment = String(repeating: "B", count: 10000)
		
		let urge = try Urge(
			time: Date(),
			habit: habit,
			context: "Valid context",
			resolutionComment: longComment,
			resolution: .handled
		)
		
		#expect(urge.resolutionComment.count == 10000)
	}
	
	@Test("Urge with special characters in context is valid")
	func specialCharactersInContextValidation() async throws {
		let habit = try createTestHabit()
		
		let urge = try Urge(
			time: Date(),
			habit: habit,
			context: "At 🍺 bar with friends! @#$%^&*()",
			resolutionComment: "Resisted 💪 successfully!",
			resolution: .handled
		)
		
		#expect(urge.context.contains("🍺"))
		#expect(urge.resolutionComment.contains("💪"))
	}
	
	@Test("Urge with unicode characters is valid")
	func unicodeCharactersValidation() async throws {
		let habit = try createTestHabit()
		
		let urge = try Urge(
			time: Date(),
			habit: habit,
			context: "Dans un café français",
			resolutionComment: "成功抵抗誘惑",
			resolution: .handled
		)
		
		#expect(urge.context == "Dans un café français")
		#expect(urge.resolutionComment == "成功抵抗誘惑")
	}
	
	@Test("Urge with newlines in context is valid")
	func newlinesInContextValidation() async throws {
		let habit = try createTestHabit()
		
		let urge = try Urge(
			time: Date(),
			habit: habit,
			context: "Line 1\nLine 2\nLine 3",
			resolution: .handled
		)
		
		#expect(urge.context.contains("\n"))
	}
	
	@Test("Multiple urges can reference the same habit")
	func multipleUrgesSameHabit() async throws {
		let habit = try createTestHabit()
		
		let urge1 = try Urge(
			time: Date(),
			habit: habit,
			context: "First urge",
			resolution: .handled
		)
		
		let urge2 = try Urge(
			time: Date(),
			habit: habit,
			context: "Second urge",
			resolution: .notHandled
		)
		
		#expect(urge1.habit === urge2.habit)
		#expect(urge1.context != urge2.context)
	}
	
	@Test("Urge with minimum valid data")
	func minimumValidUrge() async throws {
		let habit = try createTestHabit()
		
		let urge = try Urge(
			time: Date(),
			habit: habit,
			context: "X", // Minimal non-empty context
			resolution: .handled
		)
		
		#expect(urge.context == "X")
		#expect(urge.resolutionComment == "")
	}
}
