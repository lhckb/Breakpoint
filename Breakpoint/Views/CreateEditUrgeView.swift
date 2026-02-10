//
//  CreateUrgeView.swift
//  Breakpoint
//
//  Created by Luís Cruz on 18/12/25.
//

import SwiftUI
import SwiftData

struct CreateEditUrgeView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@Query private var habits: [Habit]
	
	@Binding var createUrgeSheetIsPresented: Bool
	
	let urgeToEdit: Urge?
	
	@State private var selection: Habit?
	@State private var time: Date = Date()
	@State private var context: String = ""
	@State private var resolution: Urge.Resolution = .pending
	@State private var resolutionComment: String = ""
	
	private var isEditing: Bool {
		urgeToEdit != nil
	}
	
	private var navigationTitle: String {
		isEditing ? Constants.Text.editUrge : Constants.Text.addUrge
	}
	
	private var pickerText: String {
		if habits.isEmpty {
			return Constants.Text.noHabitsToChooseFrom
		}

		return Constants.Text.selectAHabit
	}
	
	private var shouldDisableButton: Bool {
		selection == nil || context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
	}
	
	init(createUrgeSheetIsPresented: Binding<Bool>, urgeToEdit: Urge? = nil) {
		self._createUrgeSheetIsPresented = createUrgeSheetIsPresented
		self.urgeToEdit = urgeToEdit
		
		// Pre-fill with existing urge data if editing
		if let urge = urgeToEdit {
			_selection = State(initialValue: urge.habit)
			_time = State(initialValue: urge.time)
			_context = State(initialValue: urge.context)
			_resolution = State(initialValue: urge.resolution)
			_resolutionComment = State(initialValue: urge.resolutionComment)
		}
	}
	
    var body: some View {
		NavigationStack {
			Form {
				Section(header: Text(Constants.Text.urgeDetails)) {
					Picker(pickerText, selection: $selection) {
						ForEach(habits) { habit in
							Text(habit.name)
								.tag(habit as Habit?) // The .tag() modifier tells SwiftUI: "When the user selects this visual option, set the binding to this specific value." Tag value is what goes in selection
						}
					}
					
					DatePicker(Constants.Text.time, selection: $time, displayedComponents: [.date, .hourAndMinute])
					
					TextField(Constants.Text.contextPlaceholder, text: $context, axis: .vertical)
						.lineLimit(3...6)
					
					if let selectedHabit = selection, !selectedHabit.replacementStrategyTasks.isEmpty {
						VStack(alignment: .leading, spacing: 8) {
							Text(Constants.Text.replacementStrategy)
								.font(.subheadline)
								.fontWeight(.semibold)
							
							ForEach(Array(selectedHabit.replacementStrategyTasks.enumerated()), id: \.offset) { index, task in
								HStack(alignment: .top, spacing: 8) {
									Text("•")
										.fontWeight(.bold)
									Text(task)
										.fixedSize(horizontal: false, vertical: true)
								}
								.font(.subheadline)
								.foregroundStyle(.secondary)
							}
						}
						.padding(.vertical, 4)
					}
				}
				
				Section(header: Text(Constants.Text.resolution)) {
					Picker(Constants.Text.status, selection: $resolution) {
						Text(Constants.Text.pending).tag(Urge.Resolution.pending)
						Text(Constants.Text.notHandled).tag(Urge.Resolution.notHandled)
						Text(Constants.Text.handled).tag(Urge.Resolution.handled)
					}
					.pickerStyle(.segmented)
					
					TextField(Constants.Text.resolutionComment, text: $resolutionComment, axis: .vertical)
						.lineLimit(3...6)
				}
			}
			.navigationTitle(navigationTitle)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button {
						saveUrge()
						createUrgeSheetIsPresented = false
					} label: {
						Label(Constants.Text.save, systemImage: Constants.Image.checkmark)
					}
					.disabled(shouldDisableButton)
				}
				
				ToolbarItem(placement: .cancellationAction) {
					Button(Constants.Text.cancel, role: .cancel) {
						dismiss()
					}
				}
			}
			.onAppear {
				if !habits.isEmpty {
					selection = habits.first
				}
			}
		}
    }
	
	private func saveUrge() {
		guard let selectedHabit = selection else { return }
		
		if let existingUrge = urgeToEdit {
			// Update existing urge
			existingUrge.time = time
			existingUrge.habit = selectedHabit
			existingUrge.context = context
			existingUrge.resolution = resolution
			existingUrge.resolutionComment = resolutionComment
			dismiss()
		} else {
			do {
				let newUrge = try Urge(
					time: time,
					habit: selectedHabit,
					context: context,
					resolutionComment: resolutionComment,
					resolution: resolution
				)
				
				modelContext.insert(newUrge)
				dismiss()
			} catch let validationError as Urge.ValidationError {
				
			} catch {
				
			}
		}
	}
	
	private enum Constants {
		enum Text {
			static let noHabitsToChooseFrom = "No Habits to Choose From"
			static let selectAHabit = "Select a Habit"
			static let urgeDetails = "Urge Details"
			static let time = "Time"
			static let contextPlaceholder = "Provide more context. What were you doing? How were you feeling? Who were you with?"
			static let replacementStrategy = "Replacement Strategy Steps:"
			static let resolution = "Resolution"
			static let status = "Status"
			static let notHandled = "Not Handled"
			static let handled = "Handled"
			static let pending = "Pending"
			static let resolutionComment = "Resolution Comment"
			static let addUrge = "Add Urge"
			static let editUrge = "Edit Urge"
			static let save = "Save"
			static let cancel = "Cancel"
		}
		
		enum Image {
			static let checkmark = "checkmark"
		}
	}
}


#Preview("Create Mode") {
	CreateEditUrgeView(createUrgeSheetIsPresented: .constant(true))
}

#Preview("Edit Mode") {
	let habit = try! Habit(
		name: "Smoking",
		habitDescription: "Smoking cigarettes",
		replacementStrategyTasks: []
	)
	
	let urge = try! Urge(
		time: Date(),
		habit: habit,
		context: "Feeling stressed after work meeting",
		resolutionComment: "Took a walk around the block instead",
		resolution: .handled
	)
	
	return CreateEditUrgeView(createUrgeSheetIsPresented: .constant(true), urgeToEdit: urge)
}
