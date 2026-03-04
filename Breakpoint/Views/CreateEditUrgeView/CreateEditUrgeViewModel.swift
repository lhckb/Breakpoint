//
//  CreateEditUrgeViewModel.swift
//  Breakpoint
//
//  Created by Luís Cruz on 04/03/26.
//

import Foundation
import SwiftData

@Observable
final class CreateEditUrgeViewModel {
	
	let urgeToEdit: Urge?
	
	var selection: Habit?
	var time: Date = Date()
	var context: String = ""
	var resolution: Urge.Resolution = .pending
	var resolutionComment: String = ""
	var completedStepIDs: Set<UUID> = []
	var showDeleteConfirmAlert: Bool = false
	
	init(urgeToEdit: Urge?) {
		self.urgeToEdit = urgeToEdit
		
		// Pre-fill with existing urge data if editing
		if let urge = urgeToEdit {
			self.selection = urge.habit
			self.time = urge.time
			self.context = urge.context
			self.resolution = urge.resolution
			self.resolutionComment = urge.resolutionComment
			self.completedStepIDs = Set(urge.completedReplacementStepIDs)
		}
	}
	
	var isEditing: Bool {
		urgeToEdit != nil
	}
	
	var shouldDisableConfirmButton: Bool {
		selection == nil || context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
	}
	
	func toggleStepCompletion(_ stepID: UUID) {
		if completedStepIDs.contains(stepID) {
			completedStepIDs.remove(stepID)
		} else {
			completedStepIDs.insert(stepID)
		}
	}

	func saveUrge(to modelContext: ModelContext) {
		guard let selectedHabit = selection else { return }

		let completedArray = Array(completedStepIDs)

		if let existingUrge = urgeToEdit {
			// Update existing urge
			existingUrge.time = time
			existingUrge.habit = selectedHabit
			existingUrge.context = context
			existingUrge.resolution = resolution
			existingUrge.resolutionComment = resolutionComment
			existingUrge.completedReplacementStepIDs = completedArray
		} else {
			do {
				let newUrge = try Urge(
					time: time,
					habit: selectedHabit,
					context: context,
					resolutionComment: resolutionComment,
					resolution: resolution,
					completedReplacementStepIDs: completedArray
				)

				modelContext.insert(newUrge)
			} catch let validationError as Urge.ValidationError {
				_ = validationError
			} catch {
				// This shouldn't happen
			}
		}
	}

	func deleteUrge(_ urge: Urge?, from modelContext: ModelContext) {
		modelContext.delete(urge!)
		try! modelContext.save()
	}
}
