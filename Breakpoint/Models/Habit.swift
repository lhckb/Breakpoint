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
	var createdAt: Date
	
	@Relationship(deleteRule: .cascade, inverse: \ReplacementStep.habit)
	var replacementSteps: [ReplacementStep] = []
	
	// SwiftData auto manages this array every time I reference a Habit in an Urge
	// I'm mindblown rn
	@Relationship(deleteRule: .cascade, inverse: \Urge.habit)
	var urges: [Urge] = []
	
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
		self.createdAt = Date()
		self.name = name
		self.habitDescription = habitDescription
		self.replacementSteps = replacementSteps

		for step in replacementSteps {
			step.habit = self
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
