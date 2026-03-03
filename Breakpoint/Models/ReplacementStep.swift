//
//  ReplacementStep.swift
//  Breakpoint
//
//  Created by Luís Cruz on 03/03/26.
//

import Foundation
import SwiftData

@Model
class ReplacementStep {
	@Attribute(.unique) var id: UUID
	var task: String
	var order: Int // For maintaining display order
	
	// Relationship to parent Habit
	var habit: Habit?
	
	init(task: String, order: Int, habit: Habit? = nil) throws {
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

// MARK: - Convenience methods
extension ReplacementStep {
	// Convenience method for creating steps from strings (for migration/testing)
	static func createStepsFromStrings(_ tasks: [String]) throws -> [ReplacementStep] {
		return try tasks.enumerated().map { index, task in
			try ReplacementStep(task: task, order: index)
		}
	}
}
