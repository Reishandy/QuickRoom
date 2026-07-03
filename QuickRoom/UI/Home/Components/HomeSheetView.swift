//
//  HomeSheetView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 02/07/26.
//

import SwiftUI

struct HomeSheetView: View {
	@Binding var currentSheetDetent: PresentationDetent
	
	// TODO: Scroll up to 7 days, still discussing
	// TODO: Make if we snap to day it updates with current time
	var body: some View {
		VStack {
			if currentSheetDetent != .large {
				Text("1")
					.padding(.bottom, 50)
			}
			
			if currentSheetDetent != .height(85) {
				ReservationList()
			}
		}
		.presentationDetents(
			[.height(85), .medium, .large], // TODO: Define the lowest height
			selection: $currentSheetDetent
		)
		.presentationBackgroundInteraction(.enabled)
		.interactiveDismissDisabled(true)
		.presentationDragIndicator(.visible)
	}
}

#Preview {
	@Previewable @State var currentSheetDetent: PresentationDetent = .medium
	
	Group {
		Text("This is home")
	}
	.frame(maxWidth: .infinity, maxHeight: .infinity)
	.background(.secondary)
	.sheet(isPresented: .constant(true)) {
		HomeSheetView(currentSheetDetent: $currentSheetDetent)
	}
}
