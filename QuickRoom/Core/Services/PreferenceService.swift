//
//  PreferenceService.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 02/07/26.
//

import SwiftUI

@Observable
final class PreferenceService {
	private enum Keys {
		static let hasSeenOnboarding = "hasSeenOnboarding"
	}
	
	var hasSeenOnboarding: Bool {
		didSet {
			UserDefaults.standard.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding)
		}
	}
	
	init() {
		self.hasSeenOnboarding = UserDefaults.standard.bool(forKey: Keys.hasSeenOnboarding)
	}
}
