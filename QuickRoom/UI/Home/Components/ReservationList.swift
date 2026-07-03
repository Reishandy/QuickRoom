//
//  ReservationList.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import SwiftUI

struct ReservationList: View {
	// TODO: Replace reservations object
	let reservations: [String]
	let onReservationClick: (String) -> Void
	
	@State private var showInlineTitle = false
	
	var body: some View {
		if reservations.isEmpty {
			VStack(spacing: 12) {
				Image(systemName: "hand.tap")
					.font(.system(size: 48))
					.foregroundStyle(Color(UIColor.systemBlue))
				
				Text("Select a room to reserve")
					.font(.title)
					.foregroundStyle(.secondary)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		} else {
			NavigationStack {
				List {
					Text("My Reservation")
						.font(.title2)
						.bold()
						.listRowSeparator(.hidden)
					
					// TODO: Change to reservations
					ForEach(0...reservations.count - 1, id:\.self) { num in
						Button {
							onReservationClick("Reservatino \(num) detail")
						} label: {
							listItem(num)
						}
						
						.alignmentGuide(.listRowSeparatorLeading) { dimensions in
							dimensions[.leading]
						}
					}
				}
				.listStyle(.plain)
				.contentMargins(.top, -50, for: .scrollContent)
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .principal) {
						Text("My Reservation")
							.font(.headline)
							.opacity(showInlineTitle ? 1 : 0)
					}
				}
				.onScrollGeometryChange(for: Bool.self) { geometry in
					geometry.contentOffset.y > 0
				} action: { oldValue, newValue in
					withAnimation(.easeInOut(duration: 0.2)) {
						showInlineTitle = newValue
					}
				}
			}
		}
	}
	
	private func listItem(_ num: Int) -> some View {
		// TODO: Remove placeholder
		let calendar = Calendar.current
		let startDate = calendar.date(byAdding: .day, value: num, to: .now) ?? .now
		let endDate = calendar.date(byAdding: .hour, value: 3, to: startDate) ?? startDate
		let dynamicInterval = DateInterval(start: startDate, end: endDate)
		
		return HStack(spacing: 12) {
			Image(systemName: "car.circle.fill")
				.foregroundStyle(.blue.gradient)
				.font(.largeTitle)
			
			VStack(alignment: .leading, spacing: 4) {
				Text("Reservation \(num)")
					.bold()
				
				Text(dynamicInterval.toReservationString())
					.foregroundStyle(.secondary)
			}
		}
	}
}

#Preview {
	ReservationList(reservations: ["1", "2", "3"]) { _ in }
}

#Preview {
	ReservationList(reservations: []) { _ in }
}
