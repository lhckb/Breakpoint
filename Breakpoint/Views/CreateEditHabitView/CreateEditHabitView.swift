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

	let habitToEdit: Habit?
	
	@State private var viewModel: CreateEditHabitViewModel
	@State private var showDeleteConfirmAlert: Bool = false
	
	init(habitToEdit: Habit? = nil) {
		self.habitToEdit = habitToEdit
		
		viewModel = CreateEditHabitViewModel(
			modelContext: modelContext,
			habitToEdit: habitToEdit
		)
	}

	private var navigationTitle: String {
		viewModel.isEditing ? Constants.Text.editHabit : Constants.Text.addHabit
	}

    var body: some View {
		NavigationStack {
			Form {
				Section(header: Text(Constants.Text.describeHabit)) {
					TextField(Constants.Text.name, text: $viewModel.habitName)

					TextField(Constants.Text.description, text: $viewModel.habitDescription, axis: .vertical)
						.lineLimit(3...6)
				}

				Section(header: Text(Constants.Text.defineStepsToPrevent)) {
					ForEach($viewModel.habitReplacementStrategyList.indices, id: \.self) { index in
						Text(viewModel.habitReplacementStrategyList[index])
					}
					.onDelete { indexSet in
						viewModel.habitReplacementStrategyList.remove(atOffsets: indexSet)
					}

					// Show text field when adding new step
					if viewModel.isAddingNewStep {
						HStack {
							TextField(Constants.Text.stepPlaceholder, text: $viewModel.newItemString)
								.onSubmit {
									withAnimation {
										viewModel.saveNewStrategyStep()
									}
								}
						}
					}

					// Add step button (like Contacts app)
					Button {
						withAnimation {
							if !viewModel.isAddingNewStep {
								viewModel.isAddingNewStep = true
							} else {
								withAnimation {
									viewModel.saveNewStrategyStep()
								}
								viewModel.isAddingNewStep = true
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
				
				if habitToEdit != nil {
					Button(role: .destructive) {
						showDeleteConfirmAlert = true
					} label: {
						HStack {
							Image(systemName: Constants.Image.trash)
							Text(Constants.Text.deleteHabit)
						}
					}
				}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
			.navigationTitle(navigationTitle)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button {
						viewModel.saveHabit()
						dismiss()
					} label: {
						Label(Constants.Text.confirm, systemImage: Constants.Image.checkmark)
					}
					.disabled(viewModel.anyFieldEmpty)
				}

				ToolbarItem(placement: .cancellationAction) {
					Button(Constants.Text.cancel, role: .cancel) {
						dismiss()
					}
				}
			}
		}
		.onChange(of: viewModel.habitReplacementStrategyList) {
			viewModel.habitReplacementStrategyList.removeAll(where: { $0.isEmpty })
		}
		// if all goes as planned this alert will never show
		.alert(isPresented: $viewModel.showErrorAlert, error: viewModel.error) {
			Button {

			} label: {
				Text(Constants.Text.okUppercase)
			}
		}
		.alert(isPresented: $showDeleteConfirmAlert) {
			Alert(
				title: Text(Constants.Text.deleteHabit),
				message: Text(Constants.Text.deleteConfirmPrompt),
				primaryButton: .destructive(Text(Constants.Text.delete)
			) {
				viewModel.deleteHabit(habit: habitToEdit)
				dismiss()
			}, secondaryButton: .cancel())
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
			static let deleteHabit = "Delete Habit"
			static let okUppercase = "OK"
			static let delete = "Delete"
			static let deleteConfirmPrompt = "Are you sure you want to delete this habit? Doing so will also delete all urges associated with it."
		}

		enum Image {
			static let checkmark = "checkmark"
			static let plusCircleFill = "plus.circle.fill"
			static let trash = "trash"
		}
	}
}

#Preview("Create Mode") {
	CreateEditHabitView(habitToEdit: nil)
}

#Preview("Edit Mode") {
	let steps = try! ReplacementStep.createStepsFromStrings(["Take a deep breath", "Go for a walk", "Drink water"])
	let habit = try! Habit(
		name: "Smoking",
		habitDescription: "Smoking cigarettes throughout the day",
		replacementSteps: steps
	)

	CreateEditHabitView(habitToEdit: habit)
}
