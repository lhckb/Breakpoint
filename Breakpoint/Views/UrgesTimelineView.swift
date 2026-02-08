//
//  UrgesTimelineView.swift
//  Breakpoint
//
//  Created by Luís Cruz on 18/12/25.
//

import SwiftUI
import SwiftData

struct UrgesTimelineView: View {
	@Query(sort: \Urge.time, order: .reverse) private var urges: [Urge]
	
	@State private var createUrgeSheetIsPresented: Bool = false
	
	private var urgesByDay: [(String, [Urge])] {
		let calendar = Calendar.current
		let grouped = Dictionary(grouping: urges) { urge in
			calendar.startOfDay(for: urge.time)
		}
		
		return grouped
			.sorted { $0.key > $1.key }
			.map { (formatDate($0.key), $0.value.sorted { $0.time > $1.time }) }
	}
	
	private func formatDate(_ date: Date) -> String {
		let calendar = Calendar.current
		let formatter = DateFormatter()
		
		if calendar.isDateInToday(date) {
			return Constants.Text.today
		} else if calendar.isDateInYesterday(date) {
			return Constants.Text.yesterday
		} else {
			formatter.dateStyle = .long
			formatter.timeStyle = .none
			return formatter.string(from: date)
		}
	}
	
    var body: some View {
		NavigationStack {
			Group {
				if urges.isEmpty {
					ContentUnavailableView(
						Constants.Text.noUrgesToShow,
						systemImage: Constants.Image.chartXYAxis,
						description: Text(Constants.Text.addYourFirstUrge)
					)
				} else {
					List {
						ForEach(urgesByDay, id: \.0) { day, dayUrges in
							Section {
								ForEach(dayUrges) { urge in
									UrgeCardView(urge: urge)
										.listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
										.listRowSeparator(.hidden)
								}
							} header: {
								Text(day)
									.font(.headline)
									.fontWeight(.semibold)
									.foregroundStyle(.primary)
									.textCase(nil)
							}
						}
					}
					.listStyle(.plain)
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
}

private enum Constants {
	enum Text {
		static let noUrgesToShow = "No urges to show"
		static let addYourFirstUrge = "Track your first urge to see your timeline"
		static let today = "Today"
		static let yesterday = "Yesterday"
		static let timeline = "Timeline"
	}
	
	enum Image {
		static let plus = "plus"
		static let chartXYAxis = "chart.xyaxis.line"
	}
}

#Preview {
    UrgesTimelineView()
}
