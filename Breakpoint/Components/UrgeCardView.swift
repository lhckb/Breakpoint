//
//  UrgeCardView.swift
//  Breakpoint
//
//  Created by Luís Cruz on 08/02/26.
//

import SwiftUI

struct UrgeCardView: View {
	let urge: Urge
	
	private var formattedTime: String {
		let formatter = DateFormatter()
		formatter.dateStyle = .none
		formatter.timeStyle = .short
		return formatter.string(from: urge.time)
	}
	
	private var resolutionColor: Color {
		urge.resolution == .handled ? .green : .red
	}
	
	private var resolutionText: String {
		urge.resolution == .handled ? Constants.Text.handled : Constants.Text.notHandled
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			// Header: Habit Name + Time
			HStack {
				Text(urge.habit.name)
					.font(.title3)
					.fontWeight(.semibold)
				
				Spacer()
				
				Text(formattedTime)
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}
			
			// Context
			if !urge.context.isEmpty {
				VStack(alignment: .leading, spacing: 4) {
					Text(Constants.Text.context)
						.font(.caption)
						.fontWeight(.semibold)
						.foregroundStyle(.secondary)
						.textCase(.uppercase)
					
					Text(urge.context)
						.font(.subheadline)
						.fixedSize(horizontal: false, vertical: true)
				}
			}
			
			// Resolution Comment
			if !urge.resolutionComment.isEmpty {
				VStack(alignment: .leading, spacing: 4) {
					Text(Constants.Text.resolution)
						.font(.caption)
						.fontWeight(.semibold)
						.foregroundStyle(.secondary)
						.textCase(.uppercase)
					
					Text(urge.resolutionComment)
						.font(.subheadline)
						.fixedSize(horizontal: false, vertical: true)
				}
			}
			
			// Resolution Status with Dot
			HStack(spacing: 8) {
				Circle()
					.fill(resolutionColor)
					.frame(width: 8, height: 8)
				
				Text(resolutionText)
					.font(.subheadline)
					.fontWeight(.medium)
					.foregroundStyle(resolutionColor)
			}
			.padding(.top, 4)
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
			static let context = "Context"
			static let resolution = "Resolution"
			static let handled = "Handled"
			static let notHandled = "Not Handled"
		}
	}
}

#Preview {
	let habit = Habit(
		name: "Smoking",
		habitDescription: "Smoking cigarettes",
		replacementStrategyTasks: []
	)
	
	let urge = Urge(
		time: Date(),
		habit: habit,
		resolution: .handled,
		context: "Feeling stressed after work meeting",
		resolutionComment: "Took a walk around the block instead"
	)
	
	UrgeCardView(urge: urge)
		.padding()
}
