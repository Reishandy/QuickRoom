//
//  APIClientTests.swift
//  QuickRoomTests
//
//  Created by Asadullokh Nurullaev on 05/07/26.
//

import XCTest
@testable import QuickRoom

final class APIClientTests: XCTestCase {
	func testDecodesReservationWithNanosecondDates() throws {
		let json = Data("""
		{"reservations":[{"reservation_id":"res-agung","room_id":"room-ws-agung","zoom_workspace_id":"ws-agung","user_id":"","user_email":"demo.day@adabali.dev","start_time":"2026-07-03T18:23:22.660190936Z","end_time":"2026-07-03T19:53:22.660190936Z","status":"booked","check_in_status":"checked_out","source":"zoom"}]}
		""".utf8)
		let response = try APIClient.decoder.decode(ReservationsResponse.self, from: json)
		let reservation = try XCTUnwrap(response.reservations.first)
		XCTAssertEqual(reservation.reservationId, "res-agung")
		XCTAssertEqual(reservation.zoomWorkspaceId, "ws-agung")
		XCTAssertNil(reservation.bookedByUserId)
		// 2026-07-03T18:23:22.660Z (fraction truncated to millis)
		XCTAssertEqual(reservation.startTime.timeIntervalSince1970, 1783103002.660, accuracy: 0.01)
	}

	func testDecodesPlainSecondDates() throws {
		let json = Data("""
		{"reservations":[{"reservation_id":"r1","room_id":"room-x","zoom_workspace_id":"ws-x","user_id":"u1","user_email":"e","start_time":"2026-07-05T07:00:00Z","end_time":"2026-07-05T08:00:00Z","status":"booked","check_in_status":"not_checked_in","source":"app","booked_by_user_id":"u1"}]}
		""".utf8)
		let response = try APIClient.decoder.decode(ReservationsResponse.self, from: json)
		XCTAssertEqual(response.reservations.first?.bookedByUserId, "u1")
	}

	func testDecodesRoomsBeaconsAuth() throws {
		let rooms = try APIClient.decoder.decode(RoomsResponse.self, from: Data("""
		{"rooms":[{"room_id":"room-ws-agung","zoom_workspace_id":"ws-agung","name":"BINB Agung Zoom","floor":"","capacity":80,"has_tv":true,"is_zoom_room":true}]}
		""".utf8))
		XCTAssertEqual(rooms.rooms.first?.capacity, 80)

		let beacons = try APIClient.decoder.decode(BeaconsResponse.self, from: Data("""
		{"beacons":[{"workspace_id":"ws-agung","uuid":"11111111-2222-3333-4444-555555555555","major":1,"minor":106,"name":"BINB Agung Zoom"}]}
		""".utf8))
		XCTAssertEqual(beacons.beacons.first?.minor, 106)

		let auth = try APIClient.decoder.decode(AuthResponse.self, from: Data("""
		{"session_token":"tok123","user":{"user_id":"u-1","email":"a@b.c","name":"Asadullokh","created_at":"2026-07-05T00:00:00Z"}}
		""".utf8))
		XCTAssertEqual(auth.sessionToken, "tok123")
		XCTAssertEqual(auth.user.userId, "u-1")
	}

	func testEncodesSnakeCaseAndRFC3339() throws {
		let body = CreateReservationRequest(workspaceId: "ws-ubud", startTime: Date(timeIntervalSince1970: 1783746000), endTime: Date(timeIntervalSince1970: 1783749600))
		let json = try XCTUnwrap(String(data: APIClient.encoder.encode(body), encoding: .utf8))
		XCTAssertTrue(json.contains("\"workspace_id\":\"ws-ubud\""), json)
		XCTAssertTrue(json.contains("\"start_time\":\"2026-07-11T05:00:00Z\""), json)
	}

	func testErrorMapping() async throws {
		let client = APIClient(baseURL: URL(string: "https://example.invalid")!, session: StubURLProtocol.session(), tokenProvider: { "tok" })

		StubURLProtocol.respond(status: 401, body: #"{"error":"invalid session"}"#)
		do {
			let _: StatusResponse = try await client.get("/reservations/mine")
			XCTFail("expected throw")
		} catch APIError.unauthorized {
		}

		StubURLProtocol.respond(status: 409, body: #"{"error":"room already booked"}"#)
		do {
			let _: StatusResponse = try await client.post("/reservations", body: CreateReservationRequest(workspaceId: "w", startTime: .now, endTime: .now))
			XCTFail("expected throw")
		} catch APIError.conflict(let message) {
			XCTAssertTrue(message.contains("already booked"))
		}
	}

	func testSendsBearerToken() async throws {
		let client = APIClient(baseURL: URL(string: "https://example.invalid")!, session: StubURLProtocol.session(), tokenProvider: { "secret-token" })
		StubURLProtocol.respond(status: 200, body: #"{"status":"ok"}"#)
		let _: StatusResponse = try await client.get("/health/live")
		XCTAssertEqual(StubURLProtocol.lastRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer secret-token")
	}
}

final class StubURLProtocol: URLProtocol {
	nonisolated(unsafe) static var stubStatus = 200
	nonisolated(unsafe) static var stubBody = Data()
	nonisolated(unsafe) static var lastRequest: URLRequest?

	static func respond(status: Int, body: String) {
		stubStatus = status
		stubBody = Data(body.utf8)
	}

	static func session() -> URLSession {
		let config = URLSessionConfiguration.ephemeral
		config.protocolClasses = [StubURLProtocol.self]
		return URLSession(configuration: config)
	}

	override class func canInit(with request: URLRequest) -> Bool { true }
	override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

	override func startLoading() {
		Self.lastRequest = request
		let response = HTTPURLResponse(url: request.url!, statusCode: Self.stubStatus, httpVersion: nil, headerFields: nil)!
		client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
		client?.urlProtocol(self, didLoad: Self.stubBody)
		client?.urlProtocolDidFinishLoading(self)
	}

	override func stopLoading() {}
}
