//
//  BeaconDirectory.swift
//  QuickRoom
//
//  Created by Asadullokh Nurullaev on 05/07/26.
//

import Foundation

/// Maps a ranged beacon's (major, minor) to a backend workspace id via
/// GET /beacons. The cache persists in UserDefaults because region events
/// can relaunch the app in the background where a network round-trip may
/// not finish inside the wake window.
final class BeaconDirectory {
	static let shared = BeaconDirectory()

	private static let cacheDefaultsKey = "beaconDirectory.cache"

	private let client: APIClient
	private var cache: [String: String]

	init(client: APIClient = .shared) {
		self.client = client
		self.cache = UserDefaults.standard.dictionary(forKey: Self.cacheDefaultsKey) as? [String: String] ?? [:]
	}

	static func cacheKey(major: Int, minor: Int) -> String {
		"\(major)/\(minor)"
	}

	func workspaceId(major: Int, minor: Int) async -> String? {
		let key = Self.cacheKey(major: major, minor: minor)
		if let hit = cache[key] {
			return hit
		}
		await refresh()
		return cache[key]
	}

	func refresh() async {
		do {
			let response: BeaconsResponse = try await client.get("/beacons")
			cache = Dictionary(uniqueKeysWithValues: response.beacons.map { (Self.cacheKey(major: $0.major, minor: $0.minor), $0.workspaceId) })
			UserDefaults.standard.set(cache, forKey: Self.cacheDefaultsKey)
		} catch {
			print("BeaconDirectory: refresh failed: \(error)")
		}
	}
}
