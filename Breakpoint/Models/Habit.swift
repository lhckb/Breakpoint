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
	var name: String
	var habitDescription: String
	var replacementStrategyTasks: [String]
	
	init(
		name: String,
		habitDescription: String,
		replacementStrategyTasks: [String]
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
		guard !replacementStrategyTasks.isEmpty else {
			throw ValidationError.noReplacementStrategies
		}
		
		// Ensure all replacement strategies are non-empty
		let validStrategies = replacementStrategyTasks.filter {
			!$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
		}
		guard validStrategies.count == replacementStrategyTasks.count else {
			throw ValidationError.emptyReplacementStrategy
		}
		
		self.name = name
		self.habitDescription = habitDescription
		self.replacementStrategyTasks = replacementStrategyTasks
	}
}

// MARK: - Validation Errors
extension Habit {
	enum ValidationError: LocalizedError {
		case emptyName
		case emptyDescription
		case noReplacementStrategies
		case emptyReplacementStrategy
		
		var errorDescription: String? {
			switch self {
			case .emptyName:
				return "Habit name cannot be empty."
			case .emptyDescription:
				return "Habit description cannot be empty."
			case .noReplacementStrategies:
				return "At least one replacement strategy is required."
			case .emptyReplacementStrategy:
				return "Replacement strategies cannot be empty."
			}
		}
	}
}
