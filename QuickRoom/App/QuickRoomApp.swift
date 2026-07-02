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
	
    var body: some Scene {
        WindowGroup {
            ContentView()
				.environment(preferenceService)
				.environment(locationPermssionService)
				.environment(notificationPermissionService)
        }
    }
}
