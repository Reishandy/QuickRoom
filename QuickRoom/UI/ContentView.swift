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
	@State private var currentMainSheetDetent: PresentationDetent = .medium
	@State private var selectedDate: Date = .now
	@State private var selectedIndex: Int? = nil
	@State private var selectedRoomId: String? = nil
	
	private var shouldShowPermissionSheet: Bool {
		!locationPermissionService.isFullyAuthorized || !notificationPermissionService.isFullyAuthorized
	}
	
	// TODO: Info.plist wording
	// TODO: Design tweak (color, spacing, etc)
	// TODO: Loading state for UI
	var body: some View {
		Group {
			if preferenceService.hasSeenOnboarding {
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
		.onChange(of: selectedRoomId) { _, _ in
			currentMainSheetDetent = .medium
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
			try? await reservationService.fetchReservationsOnLoad()
		}
	}
	
	@ViewBuilder
	private var baseView: some View {
		ZStack(alignment: .top) {
			HomeView(
				selectedDate: selectedDate,
				onInteract: { currentMainSheetDetent = .height(90) },
				onRoomClick: { roomId in selectedRoomId = roomId }
			)
			
			Text(selectedDate.toHomeString())
				.bold()
				.padding()
				.background(.thinMaterial, in: Capsule())
				.shadow(color: .black.opacity(0.15), radius: 8, y: 4)
				.padding(.top, 60)
		}
		.sheet(isPresented: Binding(
			get: { isPreview ? true : !shouldShowPermissionSheet },
			set: { _ in }
		)) {
			HomeSheetView(
				currentSheetDetent: $currentMainSheetDetent,
				selectedDate: $selectedDate,
				selectedIndex: $selectedIndex,
				reservations: reservationService.reservations
			) { roomId in
				selectedRoomId = roomId
			}
			.presentationDetents(
				[.height(90), .medium, .large],
				selection: $currentMainSheetDetent
			)
			.presentationBackgroundInteraction(.enabled)
			.interactiveDismissDisabled(true)
			.presentationDragIndicator(.visible)
			.sheet(isPresented: Binding(
				get: { selectedRoomId != nil },
				set: { isPresented in
					if !isPresented { selectedRoomId = nil }
				}
			)) {
				if let selectedRoom = selectedRoomId {
					// TODO: Move navigation stack inside
					NavigationStack {
						ReserveSheetView(roomId: selectedRoom)
							.presentationDetents([.large])
							.interactiveDismissDisabled(true)
							.presentationDragIndicator(.hidden)
							.toolbar {
								ToolbarItem(placement: .topBarLeading) {
									Button("Close") {
										selectedRoomId = nil
									}
								}
							}
					}
				}
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
