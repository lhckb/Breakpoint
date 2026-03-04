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
	@State private var completedStepIDs: Set<UUID> = []
	@State private var showDeleteConfirmAlert: Bool = false

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
			_completedStepIDs = State(initialValue: Set(urge.completedReplacementStepIDs))
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
					.disabled(isEditing)
					.onChange(of: selection) { oldValue, newValue in
						// Reset completed steps when switching to a different habit
						if oldValue?.id != newValue?.id {
							completedStepIDs.removeAll()
						}
					}

					DatePicker(Constants.Text.time, selection: $time, displayedComponents: [.date, .hourAndMinute])

					TextField(Constants.Text.contextPlaceholder, text: $context, axis: .vertical)
						.lineLimit(3...6)

					if let selectedHabit = selection, !selectedHabit.replacementSteps.isEmpty {
						VStack(alignment: .leading, spacing: 12) {
							Text(Constants.Text.replacementStrategy)
								.font(.subheadline)
								.fontWeight(.semibold)

							ForEach(selectedHabit.replacementSteps.sorted(by: { $0.order < $1.order })) { step in
								Button {
									toggleStepCompletion(step.id)
								} label: {
									HStack(alignment: .top, spacing: 12) {
										Image(systemName: completedStepIDs.contains(step.id)
											  ? Constants.Image.checkmarkFilled
											  : Constants.Image.circle)
											.foregroundStyle(completedStepIDs.contains(step.id) ? .green : .secondary)
											.imageScale(.medium)
											.animation(.spring(duration: 0.3), value: completedStepIDs.contains(step.id))

										Text(step.task)
											.foregroundStyle(.primary)
											.fixedSize(horizontal: false, vertical: true)
											.multilineTextAlignment(.leading)

										Spacer()
									}
								}
								.buttonStyle(.plain)
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

				if urgeToEdit != nil {
					Section {
						Button(role: .destructive) {
							showDeleteConfirmAlert = true
						} label: {
							HStack {
								Image(systemName: Constants.Image.trash)
								Text(Constants.Text.deleteUrge)
							}
						}
					}
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
				if urgeToEdit == nil && !habits.isEmpty {
					selection = habits.first
				}
			}
			.alert(isPresented: $showDeleteConfirmAlert) {
				Alert(
					title: Text(Constants.Text.deleteUrge),
					message: Text(Constants.Text.deleteConfirmPrompt),
					primaryButton: .destructive(Text(Constants.Text.delete)) {
						deleteUrge(urge: urgeToEdit)
					}, secondaryButton: .cancel())
			}
		}
    }

	private func toggleStepCompletion(_ stepID: UUID) {
		if completedStepIDs.contains(stepID) {
			completedStepIDs.remove(stepID)
		} else {
			completedStepIDs.insert(stepID)
		}
	}

	private func saveUrge() {
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
			dismiss()
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
				dismiss()
			} catch let validationError as Urge.ValidationError {
				_ = validationError
			} catch {
				// This shouldn't happen
			}
		}
	}

	private func deleteUrge(urge: Urge?) {
		modelContext.delete(urge!)
		dismiss()
		try! modelContext.save()
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
			static let deleteUrge = "Delete Urge"
			static let delete = "Delete"
			static let deleteConfirmPrompt = "Are you sure you want to delete this urge?"
		}

		enum Image {
			static let checkmark = "checkmark"
			static let trash = "trash"
			static let checkmarkFilled = "checkmark.circle.fill"
			static let circle = "circle"
		}
	}
}


#Preview("Create Mode") {
	CreateEditUrgeView(createUrgeSheetIsPresented: .constant(true))
}

#Preview("Edit Mode") {
	let steps = try! ReplacementStep.createStepsFromStrings(["Take a deep breath", "Drink water", "Go for a walk"])
	let habit = try! Habit(
		name: "Smoking",
		habitDescription: "Smoking cigarettes",
		replacementSteps: steps
	)

	let urge = try! Urge(
		time: Date(),
		habit: habit,
		context: "Feeling stressed after work meeting",
		resolutionComment: "Took a walk around the block instead",
		resolution: .handled,
		completedReplacementStepIDs: [steps[0].id, steps[2].id]
	)

	CreateEditUrgeView(createUrgeSheetIsPresented: .constant(true), urgeToEdit: urge)
}
