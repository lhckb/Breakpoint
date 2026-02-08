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
	@State private var editingHabit: Habit?
	
    var body: some View {
		NavigationStack {
			Group {
				if habits.isEmpty {
					ContentUnavailableView(
						Constants.Text.noHabitsToView,
						systemImage: Constants.Image.trayFill,
						description: Text(Constants.Text.addYourFirstHabit)
					)
				} else {
					List {
						ForEach(habits) { habit in
							HabitCardView(habit: habit) {
								editingHabit = habit
							}
							.listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
							.listRowSeparator(.hidden)
						}
					}
					.listStyle(.plain)
				}
			}
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
				CreateEditHabitView(sheetIsPresented: $createHabitSheetPresented)
					.modelContext(modelContext)
			}
			.sheet(item: $editingHabit) { habit in
				CreateEditHabitView(sheetIsPresented: .constant(true), habitToEdit: habit)
					.modelContext(modelContext)
					.onDisappear {
						editingHabit = nil
					}
			}
		}
    }
}

private enum Constants {
	enum Text {
		static let noHabitsToView = "No habits to view"
		static let addYourFirstHabit = "Add your first habit to get started"
		static let habits = "Habits"
	}
	
	enum Image {
		static let plus = "plus"
		static let trayFill = "tray.fill"
	}
}

#Preview {
    HabitsListView()
}
