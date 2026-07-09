//
//  PresenceReporter.swift
//  QuickRoom
//
//  Created by Asadullokh Nurullaev on 05/07/26.
//

import Foundation
import UIKit

/// Sends arrive/leave events to POST /presence. Fire-and-forget: a lost
/// event is corrected by the backend's presence TTL backstop.
final class PresenceReporter {
	private static let lastWorkspaceKey = "presence.lastWorkspaceId"

	private let client: APIClient
	private let directory: BeaconDirectory

	init(client: APIClient = .shared, directory: BeaconDirectory = .shared) {
		self.client = client
		self.directory = directory
	}

	func reportEnter(major: Int, minor: Int) async {
		guard let workspaceId = await directory.workspaceId(major: major, minor: minor) else {
			print("PresenceReporter: no mapping for beacon \(major)/\(minor)")
			return
		}
		// Exit callbacks don't say which beacon, so remember where we are.
		UserDefaults.standard.set(workspaceId, forKey: Self.lastWorkspaceKey)
		await send(workspaceId: workspaceId, eventType: "entered")
	}

	/// Targeted exit for a specific room region (per-room monitoring knows
	/// exactly which beacon's range was left).
	func reportExit(major: Int, minor: Int) async {
		guard let workspaceId = await directory.workspaceId(major: major, minor: minor) else { return }
		for attempt in 0..<3 {
			if attempt > 0 { try? await Task.sleep(for: .seconds(2)) }
			if await send(workspaceId: workspaceId, eventType: "exited") {
				if UserDefaults.standard.string(forKey: Self.lastWorkspaceKey) == workspaceId {
					UserDefaults.standard.removeObject(forKey: Self.lastWorkspaceKey)
				}
				return
			}
		}
	}

	func reportExit() async {
		guard let workspaceId = UserDefaults.standard.string(forKey: Self.lastWorkspaceKey) else { return }
		// Forget the room only once the backend heard the exit. Clearing first
		// meant one lost POST (network blip, backend restart) ghosted the user
		// in the room with every later report silently no-opping.
		for attempt in 0..<3 {
			if attempt > 0 { try? await Task.sleep(for: .seconds(2)) }
			if await send(workspaceId: workspaceId, eventType: "exited") {
				UserDefaults.standard.removeObject(forKey: Self.lastWorkspaceKey)
				return
			}
		}
	}

	/// The definitive "I'm nowhere": foregrounding outside the beacon region
	/// scrubs this user from every room on the backend — heals ghosts even
	/// when the app no longer remembers which room it was in.
	func reportAbsent() async {
		do {
			let _: StatusResponse = try await client.post("/presence/absent")
			UserDefaults.standard.removeObject(forKey: Self.lastWorkspaceKey)
		} catch {
			print("PresenceReporter: absent scrub failed: \(error)")
		}
	}

	static func identity(user: UserDTO?) -> (userId: String, displayName: String) {
		if let user {
			return (user.userId, user.name)
		}
		let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown-device"
		return (deviceId, UIDevice.current.name)
	}

	@discardableResult
	private func send(workspaceId: String, eventType: String) async -> Bool {
		let identity = Self.identity(user: AuthService.shared.currentUser)
		let request = PresenceRequest(
			workspaceId: workspaceId,
			userId: identity.userId,
			displayName: identity.displayName,
			eventType: eventType,
			eventTs: Int64(Date().timeIntervalSince1970 * 1000)
		)
		do {
			let _: StatusResponse = try await client.post("/presence", body: request)
			return true
		} catch {
			print("PresenceReporter: \(eventType) for \(workspaceId) failed: \(error)")
			return false
		}
	}
}
