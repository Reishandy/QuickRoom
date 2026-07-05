//
//  AppEnvironment.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 05/07/26.
//

import Foundation

enum AppEnvironment {
	static func value(for key: String) -> String {
		guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
			fatalError("Missing Info.plist key: \(key). Check your .xcconfig.")
		}
		return value
	}
	
	static var apiBaseURLString: String { value(for: "API_BASE_URL") }
	static var beaconUUIDString: String { value(for: "BEACON_PROXIMITY_UUID") }
}
