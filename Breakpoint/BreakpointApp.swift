//
//  BreakpointApp.swift
//  Breakpoint
//
//  Created by Luís Cruz on 26/11/25.
//

import SwiftUI
import SwiftData

@main
struct BreakpointApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Habit.self,
			Urge.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
