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
	@State private var selectedDate: Date = .now
	
    var body: some View {
		VStack {
			FloorPlanView() { currentSheetDetent = .height(85) }
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.sheet(isPresented: Binding(
			get: { shouldShowSheet },
			set: { _ in }
		)) {
			HomeSheetView(currentSheetDetent: $currentSheetDetent)
		}
		.toolbar {
			ToolbarItem(placement: .principal) {
				Text(selectedDate.toHomeString())
					.bold()
					.padding()
					.glassEffect()
			}
		}
    }
}

#Preview {
	NavigationStack {
		HomeView(shouldShowSheet: true)
	}
}
