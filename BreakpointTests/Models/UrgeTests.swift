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
			resolution: .handled,
			context: "At a party with friends",
			resolutionComment: "Used deep breathing technique"
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
			resolution: .notHandled,
			context: "During work stress"
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
			resolution: .handled,
			context: "Morning coffee break",
			resolutionComment: ""
		)
		
		#expect(urge.resolutionComment == "")
	}
	
	@Test("Valid urge with 'handled' resolution")
	func validUrgeWithHandledResolution() async throws {
		let habit = try createTestHabit()
		
		let urge = try Urge(
			time: Date(),
			habit: habit,
			resolution: .handled,
			context: "After lunch",
			resolutionComment: "Successfully resisted"
		)
		
		#expect(urge.resolution == .handled)
	}
	
	@Test("Valid urge with 'notHandled' resolution")
	func validUrgeWithNotHandledResolution() async throws {
		let habit = try createTestHabit()
		
		let urge = try Urge(
			time: Date(),
			habit: habit,
			resolution: .notHandled,
			context: "Late at night",
			resolutionComment: "Gave in to the urge"
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
			resolution: .handled,
			context: "Earlier today"
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
			resolution: .handled,
			context: "Scheduled reminder"
		)
		
		#expect(urge.time == futureDate)
	}
	
	@Test("Valid urge with whitespace-padded context")
	func validUrgeWithWhitespacePaddedContext() async throws {
		let habit = try createTestHabit()
		
		let urge = try Urge(
			time: Date(),
			habit: habit,
			resolution: .handled,
			context: "  Valid context with padding  "
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
				resolution: .handled,
				context: "",
				resolutionComment: "Valid comment"
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
				resolution: .handled,
				context: "     ",
				resolutionComment: "Valid comment"
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
				resolution: .handled,
				context: "\t\t\t"
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
				resolution: .notHandled,
				context: "\n\n\n"
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
				resolution: .handled,
				context: "  \t\n  "
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
	
	// MARK: - Edge Case Tests
	
	@Test("Urge with very long context is valid")
	func veryLongContextValidation() async throws {
		let habit = try createTestHabit()
		let longContext = String(repeating: "A", count: 10000)
		
		let urge = try Urge(
			time: Date(),
			habit: habit,
			resolution: .handled,
			context: longContext
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
			resolution: .handled,
			context: "Valid context",
			resolutionComment: longComment
		)
		
		#expect(urge.resolutionComment.count == 10000)
	}
	
	@Test("Urge with special characters in context is valid")
	func specialCharactersInContextValidation() async throws {
		let habit = try createTestHabit()
		
		let urge = try Urge(
			time: Date(),
			habit: habit,
			resolution: .handled,
			context: "At 🍺 bar with friends! @#$%^&*()",
			resolutionComment: "Resisted 💪 successfully!"
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
			resolution: .handled,
			context: "Dans un café français",
			resolutionComment: "成功抵抗誘惑"
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
			resolution: .handled,
			context: "Line 1\nLine 2\nLine 3"
		)
		
		#expect(urge.context.contains("\n"))
	}
	
	@Test("Multiple urges can reference the same habit")
	func multipleUrgesSameHabit() async throws {
		let habit = try createTestHabit()
		
		let urge1 = try Urge(
			time: Date(),
			habit: habit,
			resolution: .handled,
			context: "First urge"
		)
		
		let urge2 = try Urge(
			time: Date(),
			habit: habit,
			resolution: .notHandled,
			context: "Second urge"
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
			resolution: .handled,
			context: "X" // Minimal non-empty context
		)
		
		#expect(urge.context == "X")
		#expect(urge.resolutionComment == "")
	}
}
