//
//  ContentView.swift
//  Breakpoint
//
//  Created by Luís Cruz on 26/11/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
		TabView {
			UrgesTimelineView()
				.modelContext(modelContext)
				.tabItem {
					Label(Constants.Text.timeline, systemImage: Constants.Image.calendar)
				}
			
			HabitsListView()
				.modelContext(modelContext)
				.tabItem {
					Label(Constants.Text.habits, systemImage: Constants.Image.listBulletClipboard)
				}
		}
    }
	
	private enum Constants {
		enum Text {
			static let timeline = "Timeline"
			static let habits = "Habits"
		}
		
		enum Image {
			static let calendar = "calendar"
			static let listBulletClipboard = "list.bullet.clipboard"
		}
	}
}

#Preview {
    ContentView()
		.modelContainer(for: [Habit.self, Urge.self], inMemory: true)
}
