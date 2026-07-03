//
//  ReservationList.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import SwiftUI

struct ReservationList: View {
	@State private var showInlineTitle = false
	
	var body: some View {
		NavigationStack {
			List {
				Text("My Reservation")
					.font(.title2)
					.bold()
					.listRowSeparator(.hidden)
				
				// TODO: Empty view
				// TODO: Populate
				ForEach(0...19, id:\.self) { num in
					listItem(num)
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
	
	private func listItem(_ num: Int) -> some View {
		// TODO: Remove placeholder
		let calendar = Calendar.current
		let startDate = calendar.date(byAdding: .day, value: num, to: .now) ?? .now
		let endDate = calendar.date(byAdding: .hour, value: 3, to: startDate) ?? startDate
		let dynamicInterval = DateInterval(start: startDate, end: endDate)
		
		// TODO: Proper navigation
		return NavigationLink( // TODO: Remove return
			destination: Text("Reservation \(num) detail")
		) {
			HStack(spacing: 12) {
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
}

#Preview {
	ReservationList()
}
