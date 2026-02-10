//
//  HabitCardView.swift
//  Breakpoint
//
//  Created by Luís Cruz on 08/02/26.
//

import SwiftUI

struct HabitCardView: View {
	let habit: Habit
	let onEdit: () -> Void
	
	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			// Header: Habit Name + Edit Button
			HStack {
				Text(habit.name)
					.font(.title3)
					.fontWeight(.semibold)
				
				Spacer()
				
				Button {
					onEdit()
				} label: {
					Image(systemName: Constants.Image.pencil)
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}
				.buttonStyle(.plain)
			}
			
			// Description
			if !habit.habitDescription.isEmpty {
				Text(habit.habitDescription)
					.font(.subheadline)
					.foregroundStyle(.secondary)
					.fixedSize(horizontal: false, vertical: true)
			}
			
			// Replacement Strategy Tasks
			if !habit.replacementStrategyTasks.isEmpty {
				VStack(alignment: .leading, spacing: 8) {
					Text(Constants.Text.replacementStrategy)
						.font(.caption)
						.fontWeight(.semibold)
						.foregroundStyle(.secondary)
						.textCase(.uppercase)
					
					ForEach(Array(habit.replacementStrategyTasks.enumerated()), id: \.offset) { index, task in
						HStack(alignment: .top, spacing: 6) {
							Text("•")
								.fontWeight(.bold)
								.foregroundStyle(.secondary)
							Text(task)
								.font(.subheadline)
								.fixedSize(horizontal: false, vertical: true)
						}
					}
				}
				.padding(.top, 4)
			}
		}
		.padding()
		.frame(maxWidth: .infinity, alignment: .leading)
		.background {
			RoundedRectangle(cornerRadius: 12)
				.fill(Color(.systemBackground))
				.shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
		}
	}
	
	private enum Constants {
		enum Text {
			static let replacementStrategy = "Replacement Strategy:"
		}
		
		enum Image {
			static let pencil = "pencil"
		}
	}
}

#Preview {
	let habit = try! Habit(
		name: "Smoking",
		habitDescription: "Smoking cigarettes throughout the day",
		replacementStrategyTasks: ["Take a deep breath", "Go for a walk", "Drink water"]
	)
	
	HabitCardView(habit: habit) {
		print("Edit tapped")
	}
	.padding()
}
