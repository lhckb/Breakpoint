//
//  ReplacementStrategyTask.swift
//  Breakpoint
//
//  Created by Luís Cruz on 11/02/26.
//

import Foundation
import SwiftData


@Model
class ReplacementStrategyTask: Identifiable {
	var id: UUID
	var text: String
	var createdAt: Date
	
	init(text: String) throws {
		
		guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
			throw ValidationError.emptyText
		}
		
		self.id = UUID()
		self.text = text
		self.createdAt = Date()
	}
}

extension ReplacementStrategyTask {
	enum ValidationError: LocalizedError {
		case emptyText
		
		var errorDescription: String? {
			switch self {
			case .emptyText:
				return "The replacement strategy task text cannot be empty."
			}
		}
	}
}
