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
	@Environment(ReservationService.self) private var reservationService
	@Environment(AuthService.self) private var authService

	let isPreview: Bool

	@State private var isPermissionSheetShown = false
	@State private var selectedDate: Date = .now
	@State private var selectedIndex: Int? = nil
	@State private var homeTab: HomeTab = .rooms

	private var shouldShowPermissionSheet: Bool {
		!locationPermissionService.isFullyAuthorized || !notificationPermissionService.isFullyAuthorized
	}

	var body: some View {
		Group {
			if preferenceService.hasSeenOnboarding && authService.isSignedIn {
				baseView
			} else {
				OnboardingView()
			}
		}
		.sheet(isPresented: $isPermissionSheetShown) {
			PermissionSheetView()
				.interactiveDismissDisabled()
				.presentationDetents([.large])
		}
		.animation(.easeInOut, value: preferenceService.hasSeenOnboarding)
		.animation(.easeInOut, value: authService.isSignedIn)
		.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
			Task {
				await authService.validateAppleCredential()
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
		.onChange(of: authService.isSignedIn) { _, signedIn in
			// The pre-sign-in load 401s now that the API requires a JWT;
			// refetch as soon as a session exists so the schedule fills
			// without waiting for the 30s auto-refresh tick.
			if signedIn {
				Task { try? await reservationService.fetchReservationsOnLoad() }
			}
		}
		.task {
			await authService.validateAppleCredential()
			try? await reservationService.fetchReservationsOnLoad()
		}
	}

	@ViewBuilder
	private var baseView: some View {
		HomeView(
			selectedDate: $selectedDate,
			selectedIndex: $selectedIndex,
			tab: $homeTab
		)
		.task {
			if !isPreview {
				await notificationPermissionService.checkStatus()
				isPermissionSheetShown = shouldShowPermissionSheet
			}
		}
	}
}

#Preview {
	ContentView(isPreview: true)
		.environment(PreferenceService())
		.environment(LocationPermissionService())
		.environment(NotificationPermissionService())
		.environment(ReservationService())
		.environment(AuthService.shared)
}
