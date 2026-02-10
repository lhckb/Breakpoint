//
//  CreateEditHabitView.swift
//  Breakpoint
//
//  Created by Luís Cruz on 08/12/26.
//

import SwiftUI
import SwiftData

struct CreateEditHabitView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@Binding var sheetIsPresented: Bool
	
	let habitToEdit: Habit?
	
	@State private var habitName: String = ""
	@State private var habitDescription: String = ""
	@State private var habitReplacementStrategyList: [String] = []
	@State private var newItemString: String = ""
	@State private var isAddingNewStep: Bool = false
	@State private var showErrorAlert: Bool = false
	@State private var error: Habit.ValidationError? = nil
	
	private var isEditing: Bool {
		habitToEdit != nil
	}
	
	private var navigationTitle: String {
		isEditing ? Constants.Text.editHabit : Constants.Text.addHabit
	}
	
	private var anyFieldEmpty: Bool {
		habitName.isEmpty
		|| habitDescription.isEmpty
		|| (habitReplacementStrategyList.isEmpty && newItemString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
	}
	
	init(sheetIsPresented: Binding<Bool>, habitToEdit: Habit? = nil) {
		self._sheetIsPresented = sheetIsPresented
		self.habitToEdit = habitToEdit
		
		// Pre-fill with existing habit data if editing
		if let habit = habitToEdit {
			_habitName = State(initialValue: habit.name)
			_habitDescription = State(initialValue: habit.habitDescription)
			_habitReplacementStrategyList = State(initialValue: habit.replacementStrategyTasks)
		}
	}
	
    var body: some View {
		NavigationStack {
			Form {
				Section(header: Text(Constants.Text.describeHabit)) {
					TextField(Constants.Text.name, text: $habitName)
					
					TextField(Constants.Text.description, text: $habitDescription)
				}

				Section(header: Text(Constants.Text.defineStepsToPrevent)) {
					ForEach($habitReplacementStrategyList.indices, id: \.self) { index in
						TextField(Constants.Text.stepPlaceholder, text: $habitReplacementStrategyList[index])
					}
					.onDelete { indexSet in
						habitReplacementStrategyList.remove(atOffsets: indexSet)
					}
					
					// Show text field when adding new step
					if isAddingNewStep {
						HStack {
							TextField(Constants.Text.stepPlaceholder, text: $newItemString)
								.onSubmit {
									saveNewStrategyStep()
								}
						}
					}
					
					// Add step button (like Contacts app)
					Button {
						withAnimation {
							if !isAddingNewStep {
								isAddingNewStep = true
							} else {
								saveNewStrategyStep()
								isAddingNewStep = true
							}
						}
					} label: {
						HStack {
							Image(systemName: Constants.Image.plusCircleFill)
								.foregroundStyle(.green)
							Text(Constants.Text.addStep)
								.foregroundStyle(.primary)
						}
					}
				}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
			.navigationTitle(navigationTitle)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button {
						saveHabit()
					} label: {
						Label(Constants.Text.confirm, systemImage: Constants.Image.checkmark)
					}
					.disabled(anyFieldEmpty)
				}
				
				ToolbarItem(placement: .cancellationAction) {
					Button(Constants.Text.cancel, role: .cancel) {
						dismiss()
					}
				}
			}
		}
		.onChange(of: habitReplacementStrategyList) {
			habitReplacementStrategyList.removeAll(where: { $0.isEmpty })
		}
		// if all goes as planned this alert will never show
		.alert(isPresented: $showErrorAlert, error: error) {
			Button {
				
			} label: {
				Text("OK")
			}
		}
    }
	
	private func saveNewStrategyStep() {
		guard !newItemString.trimmingCharacters(in: .whitespaces).isEmpty else {
			// If empty, just hide the text field
			isAddingNewStep = false
			newItemString = ""
			return
		}
		
		habitReplacementStrategyList.append(newItemString)
		newItemString = ""
		
		// Reset to show the "Add step" button again
		withAnimation {
			isAddingNewStep = false
		}
	}
	
	private func saveHabit() {
		// Save any text currently being typed in the step field
		if !newItemString.trimmingCharacters(in: .whitespaces).isEmpty {
			saveNewStrategyStep()
		}
		
		if let existingHabit = habitToEdit {
			// Update existing habit
			existingHabit.name = habitName
			existingHabit.habitDescription = habitDescription
			existingHabit.replacementStrategyTasks = habitReplacementStrategyList
		} else {
			do {
				let newHabit = try Habit(
					name: habitName,
					habitDescription: habitDescription,
					replacementStrategyTasks: habitReplacementStrategyList
				)
				
				modelContext.insert(newHabit)
				dismiss()
			} catch let validationError as Habit.ValidationError {
				error = validationError
				showErrorAlert = true
			} catch {
				// This shouldn't happen, but handle unexpected errors
				fatalError("Unexpected error: \(error)")
			}
		}
	}
	
	private enum Constants {
		enum Text {
			static let describeHabit = "Describe Habit"
			static let name = "Name"
			static let description = "Description"
			static let defineStepsToPrevent = "Replacement Steps"
			static let stepPlaceholder = "Step"
			static let addNewStep = "Add New Step"
			static let addStep = "add step"
			static let addHabit = "Add Habit"
			static let editHabit = "Edit Habit"
			static let confirm = "Confirm"
			static let cancel = "Cancel"
		}
		
		enum Image {
			static let checkmark = "checkmark"
			static let plusCircleFill = "plus.circle.fill"
		}
	}
}

#Preview("Create Mode") {
	CreateEditHabitView(sheetIsPresented: .constant(true))
}

#Preview("Edit Mode") {
	let habit = try! Habit(
		name: "Smoking",
		habitDescription: "Smoking cigarettes throughout the day",
		replacementStrategyTasks: ["Take a deep breath", "Go for a walk", "Drink water"]
	)
	
	CreateEditHabitView(sheetIsPresented: .constant(true), habitToEdit: habit)
}
