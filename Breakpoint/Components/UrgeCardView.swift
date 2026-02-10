//
//  UrgeCardView.swift
//  Breakpoint
//
//  Created by Luís Cruz on 08/02/26.
//

import SwiftUI

struct UrgeCardView: View {
	let urge: Urge
	let onEdit: () -> Void
	
	private var formattedTime: String {
		let formatter = DateFormatter()
		formatter.dateStyle = .none
		formatter.timeStyle = .short
		return formatter.string(from: urge.time)
	}
	
	private var resolutionColor: Color {
		switch urge.resolution {
			case .handled: return .green
			case .notHandled: return .red
			case .pending: return .gray
		}
	}
	
	private var resolutionText: String {
		switch urge.resolution {
			case .handled: return Constants.Text.handled
			case .notHandled: return Constants.Text.notHandled
			case .pending: return Constants.Text.pending
		}
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			// Header: Habit Name + Time + Edit Button
			HStack {
				Text(urge.habit.name)
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
			static let pending = "Pending"
		}
		
		enum Image {
			static let pencil = "pencil"
		}
	}
}

#Preview {
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
	
	UrgeCardView(urge: urge) {
		print("Edit tapped")
	}
	.padding()
}
