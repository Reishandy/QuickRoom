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
		static let defaultDuration: TimeInterval = 2700 // opening proposal; shorter bookings stay allowed
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
		// One tick per bookable slot, day-separated so it doesn't read
		// like a ruler.
		static let tickStepMinutes = 15
		static let tickWidth: CGFloat = 8 // 6 pt clear gap between 2 pt lines (Abu)
		static let lookbehindDays = 2
	}
}
