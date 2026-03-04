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
	@State private var isPressed = false

	var body: some View {
		Button {
			onEdit()
		} label: {
			VStack(alignment: .leading, spacing: 12) {
				// Header: Habit Name
				Text(habit.name)
					.font(.title3)
					.fontWeight(.semibold)

				// Description
				if !habit.habitDescription.isEmpty {
					Text(habit.habitDescription)
						.font(.subheadline)
						.foregroundStyle(.secondary)
						.fixedSize(horizontal: false, vertical: true)
				}

				// Replacement Strategy Steps
				if !habit.replacementSteps.isEmpty {
					VStack(alignment: .leading, spacing: 8) {
						Text(Constants.Text.replacementStrategy)
							.font(.caption)
							.fontWeight(.semibold)
							.foregroundStyle(.secondary)
							.textCase(.uppercase)

						ForEach(habit.replacementSteps.sorted(by: { $0.order < $1.order })) { step in
							HStack(alignment: .top, spacing: 6) {
								Text("•")
									.fontWeight(.bold)
									.foregroundStyle(.secondary)
								Text(step.task)
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
		.buttonStyle(.plain)
		.scaleEffect(isPressed ? 0.97 : 1.0)
		.opacity(isPressed ? 0.8 : 1.0)
		.animation(.easeInOut(duration: 0.15), value: isPressed)
		.simultaneousGesture(
			DragGesture(minimumDistance: 0)
				.onChanged { _ in
					if !isPressed {
						isPressed = true
					}
				}
				.onEnded { _ in
					isPressed = false
				}
		)
	}

	private enum Constants {
		enum Text {
			static let replacementStrategy = "Replacement Strategy:"
		}
	}
}

#Preview {
	let steps = try! ReplacementStep.createStepsFromStrings(["Take a deep breath", "Go for a walk", "Drink water"])
	let habit = try! Habit(
		name: "Smoking",
		habitDescription: "Smoking cigarettes throughout the day",
		replacementSteps: steps
	)

	HabitCardView(habit: habit) {
		print("Edit tapped")
	}
	.padding()
}
