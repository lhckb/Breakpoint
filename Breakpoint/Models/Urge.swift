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
	
	enum Resolution: String, Codable {
		case handled
		case notHandled
	}
	
	var time: Date
	var habit: Habit
	var resolution: Resolution
	var context: String
	var resolutionComment: String
	
	init(
		time: Date,
		habit: Habit,
		resolution: Resolution,
		context: String,
		resolutionComment: String = ""
	) throws {
		// Validate that context is not empty
		guard !context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
			throw ValidationError.emptyContext
		}
		
		self.time = time
		self.habit = habit
		self.resolution = resolution
		self.context = context
		self.resolutionComment = resolutionComment
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
