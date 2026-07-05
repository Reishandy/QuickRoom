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

	func reportExit() async {
		guard let workspaceId = UserDefaults.standard.string(forKey: Self.lastWorkspaceKey) else { return }
		UserDefaults.standard.removeObject(forKey: Self.lastWorkspaceKey)
		await send(workspaceId: workspaceId, eventType: "exited")
	}

	static func identity(user: UserDTO?) -> (userId: String, displayName: String) {
		if let user {
			return (user.userId, user.name)
		}
		let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown-device"
		return (deviceId, UIDevice.current.name)
	}

	private func send(workspaceId: String, eventType: String) async {
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
		} catch {
			print("PresenceReporter: \(eventType) for \(workspaceId) failed: \(error)")
		}
	}
}
