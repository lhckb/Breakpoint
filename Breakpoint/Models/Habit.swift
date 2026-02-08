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
	var commonTriggerDescription: String
	var replacementStrategyTasks: [String]
	
	init(
		name: String,
		habitDescription: String,
		commonTriggerDescription: String,
		replacementStrategyTasks: [String]
	) {
		self.name = name
		self.habitDescription = habitDescription
		self.commonTriggerDescription = commonTriggerDescription
		self.replacementStrategyTasks = replacementStrategyTasks
	}
}
