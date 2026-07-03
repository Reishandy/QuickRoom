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
	
	var body: some View {
		VStack {
			if currentSheetDetent != .large {
				TimelineSliderView(selectedDate: $selectedDate)
			}
			
			if currentSheetDetent != .height(80) {
				ReservationList()
			}
		}
		.presentationDetents(
			[.height(80), .medium, .large], // TODO: Define the lowest height
			selection: $currentSheetDetent
		)
		.presentationBackgroundInteraction(.enabled)
		.interactiveDismissDisabled(true)
		.presentationDragIndicator(.visible)
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
			selectedDate: $selectedDate
		)
	}
}
