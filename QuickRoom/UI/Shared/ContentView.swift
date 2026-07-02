//
//  ContentView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 02/07/26.
//

import SwiftUI

struct ContentView: View {
	@Environment(PreferenceService.self) private var preferenceService
	
    var body: some View {
		NavigationStack {
			if preferenceService.hasSeenOnboarding {
				HomeView()
			} else {
				OnboardingView()
			}
		}
		.animation(.easeInOut, value: preferenceService.hasSeenOnboarding)
		.padding(20)
    }
}

#Preview {
    ContentView()
		.environment(PreferenceService())
}
