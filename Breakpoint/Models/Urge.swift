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

	/// Returns the ReplacementStep objects that were completed for this urge.
	/// Steps deleted from the habit after the urge was logged will not appear here.
	var completedSteps: [ReplacementStep] {
		habit.replacementSteps.filter { completedReplacementStepIDs.contains($0.id) }
	}

	/// Returns UUIDs of completed steps that no longer exist in the habit.
	var orphanedCompletedStepIDs: [UUID] {
		let currentIDs = Set(habit.replacementSteps.map(\.id))
		return completedReplacementStepIDs.filter { !currentIDs.contains($0) }
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
