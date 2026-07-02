//
//  ContentView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 02/07/26.
//

import SwiftUI

struct ContentView: View {
	@Environment(PreferenceService.self) private var preferenceService
	@Environment(LocationPermissionService.self) private var locationPermissionService
	@Environment(NotificationPermissionService.self) private var notificationPermissionService
	
	@State var isPermissionSheetShown = false
	
	private var shouldShowPermissionSheet: Bool {
		!locationPermissionService.isFullyAuthorized || !notificationPermissionService.isFullyAuthorized
	}
	
    var body: some View {
		NavigationStack {
			if preferenceService.hasSeenOnboarding {
				HomeView()
					.sheet(isPresented: $isPermissionSheetShown) {
						PermissionSheetView()
							.interactiveDismissDisabled()
							.presentationDetents([.large])
					}
					.task {
						await notificationPermissionService.checkStatus()
						isPermissionSheetShown = shouldShowPermissionSheet
					}
			} else {
				OnboardingView()
			}
		}
		.animation(.easeInOut, value: preferenceService.hasSeenOnboarding)
		.padding(20)
		.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
			Task {
				await notificationPermissionService.checkStatus()
				isPermissionSheetShown = shouldShowPermissionSheet
			}
		}
		.onChange(of: locationPermissionService.isFullyAuthorized) { _, _ in
			isPermissionSheetShown = shouldShowPermissionSheet
		}
		.onChange(of: notificationPermissionService.isFullyAuthorized) { _, _ in
			isPermissionSheetShown = shouldShowPermissionSheet
		}
    }
}

#Preview {
    ContentView()
		.environment(PreferenceService())
		.environment(LocationPermissionService())
		.environment(NotificationPermissionService())
}
