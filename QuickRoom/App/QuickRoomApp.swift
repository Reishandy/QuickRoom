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
	
    var body: some Scene {
        WindowGroup {
            ContentView()
				.environment(preferenceService)
        }
    }
}
