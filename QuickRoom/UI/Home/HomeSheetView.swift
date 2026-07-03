//
//  HomeSheetView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 02/07/26.
//

import SwiftUI

struct HomeSheetView: View {
	@Binding var currentSheetDetent: PresentationDetent
	@Binding var selectedDate: Date
	
	// TODO: Replace reservations object
	let reservations: [String]
	let onReservationClick: (String) -> Void
	
	@State private var selectedIndex: Int?
	
	var body: some View {
		VStack {
			if currentSheetDetent != .large {
				TimelineSliderView(selectedDate: $selectedDate, selectedIndex: $selectedIndex)
					.padding(.top, 25)
			}
			
			if currentSheetDetent != .height(90) {
				ReservationList(reservations: reservations) { reservation in
					onReservationClick(reservation)
				}
			}
		}
	}
}

#Preview {
	@Previewable @State var currentSheetDetent: PresentationDetent = .medium
	@Previewable @State var selectedDate: Date = .now
	
	Group {
		Text("This is home")
	}
	.frame(maxWidth: .infinity, maxHeight: .infinity)
	.background(.secondary)
	.sheet(isPresented: .constant(true)) {
		HomeSheetView(
			currentSheetDetent: $currentSheetDetent,
			selectedDate: $selectedDate,
			reservations: ["1", "2", "3"]
		) { _ in }
			.presentationDetents(
				[.height(90), .medium, .large],
				selection: $currentSheetDetent
			)
			.presentationBackgroundInteraction(.enabled)
			.interactiveDismissDisabled(true)
			.presentationDragIndicator(.visible)
	}
}
