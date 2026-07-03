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
	// TODO: Consolidate working hours
	// TODO: Loading state for UI
	var body: some View {
		Group {
			if preferenceService.hasSeenOnboarding {
				baseScreen
			} else {
				OnboardingView()
			}
		}
		.sheet(isPresented: $isPermissionSheetShown) {
			PermissionSheetView()
				.interactiveDismissDisabled()
				.presentationDetents([.large])
		}
		.sheet(isPresented: Binding(
			get: { isPreview ? true : !shouldShowPermissionSheet },
			set: { _ in }
		)) {
			sheetScreen
				.presentationDetents(
					[.height(90), .medium, .large],
					selection: $currentMainSheetDetent
				)
				.presentationBackgroundInteraction(.enabled)
				.interactiveDismissDisabled(true)
				.presentationDragIndicator(.visible)
		}
		.animation(.easeInOut, value: preferenceService.hasSeenOnboarding)
		.animation(.easeInOut, value: selectedRoomId)
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
		.task {
			try? await reservationService.fetchReservationsOnLoad()
		}
	}
	
	@ViewBuilder
	private var baseScreen: some View {
		ZStack {
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
			.task {
				if !isPreview {
					await notificationPermissionService.checkStatus()
					isPermissionSheetShown = shouldShowPermissionSheet
				}
			}
			.opacity(selectedRoomId == nil ? 1 : 0)
			.allowsHitTesting(selectedRoomId == nil)
			
			if let selectedRoomId = selectedRoomId {
				NavigationStack {
					ReserveView(roomId: selectedRoomId)
						.toolbar {
							ToolbarItem(placement: .topBarLeading) {
								Button {
									self.selectedRoomId = nil
								} label: {
									Image(systemName: "chevron.left")
								}
							}
						}
				}
				.transition(.move(edge: .trailing))
			}
		}
		.animation(.default, value: selectedRoomId)
	}
	
	@ViewBuilder
	private var sheetScreen: some View {
		if let selectedRoom = selectedRoomId {
			ReserveSheetView(roomId: selectedRoom)
		} else {
			HomeSheetView(
				currentSheetDetent: $currentMainSheetDetent,
				selectedDate: $selectedDate,
				selectedIndex: $selectedIndex,
				reservations: reservationService.reservations
			) { roomId in
				selectedRoomId = roomId
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
}
