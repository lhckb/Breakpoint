//
//  CreateEditHabitViewModel.swift
//  Breakpoint
//
//  Created by Luís Cruz on 04/03/26.
//

import Foundation
import SwiftData

@Observable
final class CreateEditHabitViewModel {
	
	var habitName: String = ""
	var habitDescription: String = ""
	var habitReplacementStrategyList: [String] = []
	var newItemString: String = ""
	var isAddingNewStep: Bool = false
	var showErrorAlert: Bool = false
	var habitToEdit: Habit? = nil
	var showDeleteConfirmAlert: Bool = false
	var errorDescription: String = ""
	
	init(habitToEdit: Habit? = nil) {
		self.habitToEdit = habitToEdit

		// Pre-fill with existing habit data if editing
		if let habit = habitToEdit {
			habitName = habit.name
			habitDescription = habit.habitDescription
			habitReplacementStrategyList = habit.replacementSteps.sorted(by: { $0.createdAt < $1.createdAt }).map(\.task)
		}
	}
	
	func saveNewStrategyStep() {
		guard !newItemString.trimmingCharacters(in: .whitespaces).isEmpty else {
			// If empty, just hide the text field
			isAddingNewStep = false
			newItemString = ""
			return
		}

		habitReplacementStrategyList.append(newItemString)
		newItemString = ""

		// Reset to show the "Add step" button again
		isAddingNewStep = false
	}

	func saveHabit(to modelContext: ModelContext) {
		// Save any text currently being typed in the step field
		if !newItemString.trimmingCharacters(in: .whitespaces).isEmpty {
			saveNewStrategyStep()
		}

		if let existingHabit = habitToEdit {
			// Update existing habit: replace all steps with freshly ordered ones
			let oldSteps = existingHabit.replacementSteps
			for step in oldSteps {
				modelContext.delete(step)
			}
			let newSteps = (try? ReplacementStep.createStepsFromStrings(habitReplacementStrategyList)) ?? []
			existingHabit.name = habitName
			existingHabit.habitDescription = habitDescription
			existingHabit.replacementSteps = newSteps
		} else {
			do {
				let steps = try ReplacementStep.createStepsFromStrings(habitReplacementStrategyList)
				let newHabit = try Habit(
					name: habitName,
					habitDescription: habitDescription,
					replacementSteps: steps
				)

				modelContext.insert(newHabit)
			} catch let validationError as Habit.ValidationError {
				errorDescription = validationError.localizedDescription
				showErrorAlert = true
			} catch let error {
				// This shouldn't happen, but handle unexpected errors
				errorDescription = "Unknown Error: \(error.localizedDescription)"
				showErrorAlert = true
			}
		}
	}
	
	func deleteHabit(from modelContext: ModelContext) {
		guard let habit = self.habitToEdit else { return }
		
		// Delete the habit from the context
		modelContext.delete(habit)
		
		// Save after dismissing to avoid accessing invalidated object
		try! modelContext.save()
	}
}
