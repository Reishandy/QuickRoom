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
	
	enum Timeline {
		static let tickWidth: CGFloat = 8
		static let lookbehindDays = 2
		static let lookaheadDays = 14
	}
}
