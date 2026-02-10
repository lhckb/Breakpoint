//
//  CreateUrgeView.swift
//  Breakpoint
//
//  Created by Luís Cruz on 18/12/25.
//

import SwiftUI
import SwiftData

struct CreateUrgeView: View {
	@Environment(\.modelContext) private var modelContext
	
	@Query private var habits: [Habit]
	
	@State private var selection: Habit?
	@State private var time: Date = Date()
	@State private var context: String = ""
	@State private var resolution: Urge.Resolution = .notHandled
	@State private var resolutionComment: String = ""
	
	@Binding var createUrgeSheetIsPresented: Bool
	
	private var pickerText: String {
		if habits.isEmpty {
			return Constants.Text.noHabitsToChooseFrom
		}

		return Constants.Text.selectAHabit
	}
	
	private var shouldDisableButton: Bool {
		selection == nil || context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
						Text(Constants.Text.notHandled).tag(Urge.Resolution.notHandled)
						Text(Constants.Text.handled).tag(Urge.Resolution.handled)
					}
					.pickerStyle(.segmented)
					
					TextField(Constants.Text.resolutionComment, text: $resolutionComment, axis: .vertical)
						.lineLimit(3...6)
				}
			}
			.navigationTitle(Constants.Text.addUrge)
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
						createUrgeSheetIsPresented = false
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
		
		do {
			let newUrge = try Urge(
				time: time,
				habit: selectedHabit,
				resolution: resolution,
				context: context,
				resolutionComment: resolutionComment
			)
			
			modelContext.insert(newUrge)
		} catch let validationError as Urge.ValidationError {
			
		} catch {
			
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
			static let resolutionComment = "Resolution Comment"
			static let addUrge = "Add Urge"
			static let save = "Save"
			static let cancel = "Cancel"
		}
		
		enum Image {
			static let checkmark = "checkmark"
		}
	}
}


#Preview {
	CreateUrgeView(createUrgeSheetIsPresented: .constant(true))
}
