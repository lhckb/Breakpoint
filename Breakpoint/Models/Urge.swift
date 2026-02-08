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
	
	init(time: Date, habit: Habit, resolution: Resolution, context: String, resolutionComment: String) {
		self.time = time
		self.habit = habit
		self.resolution = resolution
		self.context = context
		self.resolutionComment = resolutionComment
	}
}
