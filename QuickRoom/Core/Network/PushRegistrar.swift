//
//  PushRegistrar.swift
//  QuickRoom
//
//  Created by Asadullokh Nurullaev on 05/07/26.
//

import Foundation
import UIKit

/// Registers this device for APNs and uploads the token to the backend so
/// outbox notifications (grace reminders, no-show releases, room-freed) get
/// pushed. Upload needs a signed-in session; a token that arrives before
/// sign-in is stashed and flushed after auth.
final class PushRegistrar {
	static let shared = PushRegistrar()

	private static let pendingTokenKey = "apns.pendingToken"

	private let client: APIClient

	init(client: APIClient = .shared) {
		self.client = client
	}

	/// Ask iOS for a device token. Safe to call repeatedly.
	func requestRegistration() {
		UIApplication.shared.registerForRemoteNotifications()
	}

	func handleToken(_ tokenData: Data) async {
		let token = tokenData.map { String(format: "%02x", $0) }.joined()
		await upload(token)
	}

	/// Retry a token that arrived before the user signed in.
	func flushPendingToken() async {
		guard let token = UserDefaults.standard.string(forKey: Self.pendingTokenKey) else { return }
		await upload(token)
	}

	private func upload(_ token: String) async {
		do {
			let _: StatusResponse = try await client.post("/devices/apns", body: ["token": token])
			UserDefaults.standard.removeObject(forKey: Self.pendingTokenKey)
		} catch {
			// Not signed in yet (401) or offline: keep it for a later flush.
			UserDefaults.standard.set(token, forKey: Self.pendingTokenKey)
			print("PushRegistrar: upload deferred: \(error)")
		}
	}
}
