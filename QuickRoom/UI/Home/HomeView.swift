//
//  HomeView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 02/07/26.
//

import SwiftUI

struct HomeView: View {
	@State private var isSheetShown: Bool = true
	@State private var currentSheetDetent: PresentationDetent = .medium // TODO: Decide default
	
    var body: some View {
		VStack {
			Text("TODO: MAP")
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity) // TODO: Remove
		.background(.red) // TODO: Remove
		.sheet(isPresented: $isSheetShown) {
			Text("TODO: Sheet")
				.presentationDetents(
					[.height(80), .medium, .large], // TODO: Define the lowest height
					selection: $currentSheetDetent
				)
				.presentationBackgroundInteraction(.enabled)
				.interactiveDismissDisabled(true)
				.presentationDragIndicator(.visible)		}
    }
}

#Preview {
    HomeView()
}
