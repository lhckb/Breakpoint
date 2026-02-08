//
//  CreateHabitView.swift
//  Breakpoint
//
//  Created by Luís Cruz on 27/11/25.
//

import SwiftUI
import SwiftData

struct CreateHabitView: View {
	@Environment(\.modelContext) private var modelContext
	
	@Binding var sheetIsPresented: Bool
	
	@State private var habitName: String = ""
	@State private var habitDescription: String = ""
	@State private var habitTriggerDescription: String = ""
	@State private var habitReplacementStrategyList: [String] = []
	@State private var newItemString: String = ""
	
    var body: some View {
		NavigationStack {
			Form {
				Section(header: Text(Constants.Text.describeHabit)) {
					TextField(Constants.Text.name, text: $habitName)
					
					TextField(Constants.Text.description, text: $habitDescription)
					
					TextField(Constants.Text.trigger, text: $habitTriggerDescription)
				}

				Section(header: Text(Constants.Text.defineStepsToPrevent)) {
					List {
						ForEach($habitReplacementStrategyList, id: \.self) { step in  // inform Swift to use the string itself as its own id, or else conform to Identifiable
							TextField("", text: step)
						}
					}
					
					VStack(alignment: .leading, spacing: 20) {
						TextField(Constants.Text.describeAStep, text: $newItemString)
						
						Button {
							saveNewStrategyStep()
						} label: {
							Text(Constants.Text.add)
						}
					}
				}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
			.navigationTitle(Constants.Text.addHabit)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button {
						saveHabit()
						sheetIsPresented = false
					} label: {
						Label(Constants.Text.confirm, systemImage: Constants.Image.checkmark)
					}
				}
			}
		}
		.onChange(of: habitReplacementStrategyList) {
			habitReplacementStrategyList.removeAll(where: { $0.isEmpty })
		}
    }
	
	private func saveNewStrategyStep() {
		habitReplacementStrategyList.append(newItemString)
		newItemString = ""
	}
	
	private func saveHabit() {
		let newHabit = Habit(
			name: habitName,
			habitDescription: habitDescription,
			commonTriggerDescription: habitTriggerDescription,
			replacementStrategyTasks: habitReplacementStrategyList
		)
		
		modelContext.insert(newHabit)
	}
	
	private enum Constants {
		enum Text {
			static let describeHabit = "Describe Habit"
			static let name = "Name"
			static let description = "Description"
			static let trigger = "Trigger"
			static let defineStepsToPrevent = "Define Steps to Prevent"
			static let describeAStep = "Describe a Step"
			static let add = "Add"
			static let addHabit = "Add Habit"
			static let confirm = "Confirm"
		}
		
		enum Image {
			static let checkmark = "checkmark"
		}
	}
}

#Preview {
	CreateHabitView(sheetIsPresented: .constant(true))
}
