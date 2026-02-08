//
//  HabitsListView.swift
//  Breakpoint
//
//  Created by Luís Cruz on 26/11/25.
//

import SwiftUI
import SwiftData

struct HabitsListView: View {
	@Environment(\.modelContext) private var modelContext
	@Query private var habits: [Habit]
	
	@State private var createHabitSheetPresented: Bool = false
	
    var body: some View {
		NavigationStack {
			VStack {
				if habits.isEmpty {
					Text(Constants.Text.noHabitsToView)
				}
				else {
					List {
						ForEach(habits) { habit in
							Section {
								Text("\(Constants.Text.habit): \(habit.name)")
								Text("\(Constants.Text.description): \(habit.habitDescription)")
								Text("\(Constants.Text.description): \(habit.commonTriggerDescription)")
								ForEach(habit.replacementStrategyTasks, id: \.self) { step in
									Text("\(Constants.Text.strategy): \(step)")
								}
							}
						}
					}
				}
			}
//			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
			.navigationTitle(Constants.Text.habits)
			.toolbar {
				ToolbarItem {
					Button {
						createHabitSheetPresented = true
					} label: {
						Image(systemName: Constants.Image.plus)
					}
				}
			}
			.sheet(isPresented: $createHabitSheetPresented) {
				CreateHabitView(sheetIsPresented: $createHabitSheetPresented)
					.modelContext(modelContext)
			}
		}
    }
	
	private enum Constants {
		enum Text {
			static let noHabitsToView = "No habits to view"
			static let habit = "Habit"
			static let description = "Description"
			static let strategy = "Strategy"
			static let habits = "Habits"
		}
		
		enum Image {
			static let plus = "plus"
		}
	}
}

#Preview {
    HabitsListView()
}
