//
//  UrgesTimelineView.swift
//  Breakpoint
//
//  Created by Luís Cruz on 18/12/25.
//

import SwiftUI
import SwiftData

struct UrgesTimelineView: View {
	@Query private var urges: [Urge]
	
	@State private var createUrgeSheetIsPresented: Bool = false
	
    var body: some View {
		NavigationStack {
			VStack {
				if urges.isEmpty {
					Text(Constants.Text.noUrgesToShow)
				}
				
				List {
					ForEach(urges) { urge in
						Section {
							Text("Urge: \(urge.habit.name)")
							Text("Time: \(urge.time)")
						}
					}
				}
			}
			.navigationTitle(Constants.Text.timeline)
			.toolbar {
				ToolbarItem {
					Button {
						createUrgeSheetIsPresented = true
					} label: {
						Image(systemName: Constants.Image.plus)
					}
				}
			}
			.sheet(isPresented: $createUrgeSheetIsPresented) {
				CreateUrgeView(createUrgeSheetIsPresented: $createUrgeSheetIsPresented)
			}
		}
    }
	
	private enum Constants {
		enum Text {
			static let noUrgesToShow = "No urges to show"
			static let timeline = "Timeline"
		}
		
		enum Image {
			static let plus = "plus"
		}
	}
}

#Preview {
    UrgesTimelineView()
}
