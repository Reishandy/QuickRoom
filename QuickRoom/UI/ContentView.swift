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
	@State private var selectedRoomId: String? = nil
	@State private var homeTab: HomeTab = .rooms
	@State private var bookedPulse = 0
	
	private var shouldShowPermissionSheet: Bool {
		!locationPermissionService.isFullyAuthorized || !notificationPermissionService.isFullyAuthorized
	}
	
	// TODO: Info.plist wording
	// TODO: Design tweak (color, spacing, etc)
	// TODO: Loading state for UI
	// TODO: Fetch new reservation with gesture?
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
			tab: $homeTab,
			onRoomClick: { roomId in selectedRoomId = roomId }
		)
		.sensoryFeedback(.success, trigger: bookedPulse)
		.sheet(isPresented: Binding(
			get: { selectedRoomId != nil },
			set: { isPresented in
				if !isPresented { selectedRoomId = nil }
			}
		)) {
			if let selectedRoom = selectedRoomId {
				ReserveSheetView(
					selectedDate: $selectedDate,
					roomId: selectedRoom,
					onDismissClick: {
						selectedRoomId = nil
					},
					onBooked: {
						// Success haptic, close the sheet, land on My bookings.
						bookedPulse += 1
						selectedRoomId = nil
						homeTab = .bookings
					}
				)
				.presentationDetents([.large])
				.interactiveDismissDisabled(true)
				.presentationDragIndicator(.hidden)
			}
		}
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
