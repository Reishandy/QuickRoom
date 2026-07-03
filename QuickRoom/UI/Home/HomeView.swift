//
//  HomeView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 02/07/26.
//

import SwiftUI

struct HomeView: View {
	let shouldShowSheet: Bool
	
	@State private var currentSheetDetent: PresentationDetent = .medium
	@State private var selectedDate: Date = .now
	
    var body: some View {
		ZStack(alignment: .top) {
			FloorPlanView() { currentSheetDetent = .height(100) }
			
			Text(selectedDate.toHomeString())
				.bold()
				.padding()
				.background(.thinMaterial, in: Capsule())
				.shadow(color: .black.opacity(0.15), radius: 8, y: 4)
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
