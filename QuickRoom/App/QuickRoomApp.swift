//
//  QuickRoomApp.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 02/07/26.
//

import SwiftUI

@main
struct QuickRoomApp: App {
	@State var preferenceService = PreferenceService()
	@State var locationPermssionService = LocationPermissionService()
	@State var notificationPermissionService = NotificationPermissionService()
	@State var reservationService = ReservationService()
	@State var authService = AuthService.shared

	init() {
		_ = BeaconMonitoringService.shared
	}
	
    var body: some Scene {
        WindowGroup {
            ContentView(isPreview: false)
				.environment(preferenceService)
				.environment(locationPermssionService)
				.environment(notificationPermissionService)
				.environment(reservationService)
				.environment(authService)
        }
    }
}
