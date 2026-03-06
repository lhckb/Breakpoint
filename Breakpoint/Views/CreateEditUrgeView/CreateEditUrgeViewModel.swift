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
	var showErrorAlert: Bool = false
	var errorDescription: String = ""
	
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
				errorDescription = validationError.localizedDescription
				showErrorAlert = true
			} catch {
				// This shouldn't happen
				errorDescription = "Unknown Error: \(error.localizedDescription)"
				showErrorAlert = true
			}
		}
	}

	func deleteUrge(from modelContext: ModelContext) {
		guard let urge = self.urgeToEdit else { return }
		modelContext.delete(urge)
		try! modelContext.save()
	}
}
