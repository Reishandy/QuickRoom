//
//  PresenceTests.swift
//  QuickRoomTests
//
//  Created by Asadullokh Nurullaev on 05/07/26.
//

import XCTest
@testable import QuickRoom

final class PresenceTests: XCTestCase {
	func testCacheKeyFormat() {
		XCTAssertEqual(BeaconDirectory.cacheKey(major: 1, minor: 106), "1/106")
	}

	func testPresenceResponseDecodesBothShapes() throws {
		// Status shape (no reservation in the room)
		let status = try APIClient.decoder.decode(StatusResponse.self, from: Data(#"{"status":"recorded","workspace_id":"ws-agung"}"#.utf8))
		XCTAssertEqual(status.status, "recorded")
		// Reservation shape (presence drove a check-in) — must not throw
		let reservation = try APIClient.decoder.decode(StatusResponse.self, from: Data(#"{"reservation_id":"r1","zoom_workspace_id":"ws-agung","status":"booked","check_in_status":"checked_in"}"#.utf8))
		XCTAssertEqual(reservation.status, "booked")
	}

	func testIdentityFallsBackToDeviceWhenSignedOut() {
		KeychainStore.sessionToken = nil
		KeychainStore.currentUserJSON = nil
		let identity = PresenceReporter.identity(user: nil)
		XCTAssertFalse(identity.userId.isEmpty)
		XCTAssertFalse(identity.displayName.isEmpty)
	}

	func testIdentityUsesSignedInUser() {
		let user = UserDTO(userId: "u-9", email: "a@b.c", name: "Asadullokh")
		let identity = PresenceReporter.identity(user: user)
		XCTAssertEqual(identity.userId, "u-9")
		XCTAssertEqual(identity.displayName, "Asadullokh")
	}
}
