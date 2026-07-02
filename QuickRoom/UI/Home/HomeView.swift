//
//  HomeView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 02/07/26.
//

import SwiftUI

struct HomeView: View {
	let shouldShowSheet: Bool
	
	@State private var currentSheetDetent: PresentationDetent = .medium // TODO: Decide default
	
    var body: some View {
		VStack {
			FloorPlanView() { currentSheetDetent = .height(85) }
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.sheet(isPresented: Binding(
			get: { shouldShowSheet },
			set: { _ in }
		)) {
			// TODO: Scroll up to 7 days, still discussing
			// TODO: Make list scrollable only on high
			// TODO: Use navtitle here
			Text("TODO: Sheet")
				.presentationDetents(
					[.height(85), .medium, .large], // TODO: Define the lowest height
					selection: $currentSheetDetent
				)
				.presentationBackgroundInteraction(.enabled)
				.interactiveDismissDisabled(true)
				.presentationDragIndicator(.visible)
		}
    }
}

#Preview {
    HomeView(shouldShowSheet: true)
}
