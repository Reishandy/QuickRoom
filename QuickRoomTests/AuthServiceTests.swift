//
//  AuthServiceTests.swift
//  QuickRoomTests
//
//  Created by Asadullokh Nurullaev on 05/07/26.
//

import XCTest
@testable import QuickRoom

final class AuthServiceTests: XCTestCase {
	override func tearDown() {
		KeychainStore.sessionToken = nil
		KeychainStore.currentUserJSON = nil
		super.tearDown()
	}

	func testKeychainRoundtrip() {
		KeychainStore.sessionToken = "tok-abc"
		XCTAssertEqual(KeychainStore.sessionToken, "tok-abc")
		KeychainStore.sessionToken = "tok-replaced"
		XCTAssertEqual(KeychainStore.sessionToken, "tok-replaced")
		KeychainStore.sessionToken = nil
		XCTAssertNil(KeychainStore.sessionToken)
	}

	func testAuthServiceRestoresPersistedSession() {
		KeychainStore.sessionToken = "tok-abc"
		KeychainStore.currentUserJSON = #"{"userId":"u-1","email":"a@b.c","name":"Asadullokh"}"#
		let service = AuthService(client: .shared)
		XCTAssertTrue(service.isSignedIn)
		XCTAssertEqual(service.currentUser?.userId, "u-1")
	}

	func testAuthServiceWithoutTokenIsSignedOut() {
		let service = AuthService(client: .shared)
		XCTAssertFalse(service.isSignedIn)
		XCTAssertNil(service.currentUser)
	}

	@MainActor
	func testHandleUnauthorizedClearsSessionLocally() {
		KeychainStore.sessionToken = "tok-dead"
		KeychainStore.currentUserJSON = #"{"userId":"u-1","email":"a@b.c","name":"Asadullokh"}"#
		let service = AuthService(client: .shared)
		XCTAssertTrue(service.isSignedIn)

		service.handleUnauthorized()

		XCTAssertFalse(service.isSignedIn)
		XCTAssertNil(KeychainStore.sessionToken)
		XCTAssertNil(KeychainStore.currentUserJSON)
	}

	@MainActor
	func testInitWiresUnauthorizedHook() {
		KeychainStore.sessionToken = "tok-dead"
		KeychainStore.currentUserJSON = #"{"userId":"u-1","email":"a@b.c","name":"Asadullokh"}"#
		let client = APIClient(baseURL: URL(string: "http://localhost:1")!, tokenProvider: { KeychainStore.sessionToken })
		let service = AuthService(client: client)
		XCTAssertTrue(service.isSignedIn)

		client.onUnauthorized?()

		let cleared = expectation(description: "session cleared")
		Task { @MainActor in
			while service.isSignedIn { await Task.yield() }
			cleared.fulfill()
		}
		wait(for: [cleared], timeout: 2)
	}
}
