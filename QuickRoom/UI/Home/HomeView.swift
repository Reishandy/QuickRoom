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
		ZStack(alignment: .top) {
			FloorPlanView() { currentSheetDetent = .height(80) }
			
			Text(selectedDate.toHomeString())
				.bold()
				.padding()
				.glassEffect()
				.padding(.top, 60)
		}
		.sheet(isPresented: Binding(
			get: { shouldShowSheet },
			set: { _ in }
		)) {
			HomeSheetView(
				currentSheetDetent: $currentSheetDetent,
				selectedDate: $selectedDate
			)
		}
    }
}

#Preview {
	NavigationStack {
		HomeView(shouldShowSheet: true)
	}
}
