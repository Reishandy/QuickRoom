//
//  OnboardingView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 02/07/26.
//

import SwiftUI

struct OnboardingView: View {
	@Environment(PreferenceService.self) private var preferenceService
	
	// TODO: Onboarding view UI
    var body: some View {
        Text("This is onboarding")
		
		Button("Continue") {
			preferenceService.hasSeenOnboarding = true
		}
		.buttonStyle(.borderedProminent)
    }
}

#Preview {
    OnboardingView()
		.environment(PreferenceService())
}
