//
//  AppConfig.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 05/07/26.
//

import Foundation

enum AppConfig {
	
	enum WorkingHours {
		static let start = 7
		static let end = 19
	}
	
	enum Reservation {
		static let timeStepMinutes = 15
		static let minDuration: TimeInterval = 900 // 15 mins
		static let maxDuration: TimeInterval = 7200 // 2 hours
	}
	
	enum Beacon {
		static let proximityUUID: UUID = {
			guard let uuid = UUID(uuidString: AppEnvironment.beaconUUIDString) else {
				assertionFailure("Invalid beacon UUID in config")
				return UUID()
			}
			return uuid
		}()
	}
	
	enum API {
		static let baseURL = URL(string: AppEnvironment.apiBaseURLString)!
	}
	
	// TODO: Make sure this match what the api request for the lookahead
	enum Timeline {
		// Coarser than the 15-min booking grid on purpose (mentor feedback:
		// a tick per booking slot reads like a ruler).
		static let tickStepMinutes = 30
		static let tickWidth: CGFloat = 14
		static let lookbehindDays = 2
		static let lookaheadDays = 14
	}
}
