//
//  ReservationServiceTests.swift
//  QuickRoomTests
//
//  Created by Asadullokh Nurullaev on 05/07/26.
//

import XCTest
@testable import QuickRoom

final class ReservationServiceTests: XCTestCase {
	private func makeReservationDTO(id: String = "r1", status: String = "booked", bookedBy: String? = nil) -> ReservationDTO {
		let bookedByFragment = bookedBy.map { #","booked_by_user_id":"\#($0)""# } ?? ""
		return try! APIClient.decoder.decode(ReservationDTO.self, from: Data("""
		{"reservation_id":"\(id)","room_id":"room-ws-ubud","zoom_workspace_id":"ws-ubud","user_id":"","user_email":"e","start_time":"2026-07-05T07:00:00Z","end_time":"2026-07-05T08:00:00Z","status":"\(status)","check_in_status":"not_checked_in","source":"app"\(bookedByFragment)}
		""".utf8))
	}

	func testOverlayUsesServerNamesAndTracksBacking() {
		let server = try! APIClient.decoder.decode(RoomsResponse.self, from: Data("""
		{"rooms":[{"room_id":"room-ws-agung","zoom_workspace_id":"ws-agung","name":"Agung (Renamed)","floor":"","capacity":80,"has_tv":true,"is_zoom_room":true}]}
		""".utf8)).rooms
		let result = ReservationService.overlayServerRooms(onto: StaticRooms.rooms, server: server)
		XCTAssertEqual(result.rooms.first(where: { $0.id == "ws-agung" })?.name, "Agung (Renamed)")
		XCTAssertEqual(result.serverBacked, ["ws-agung"])
		// Unknown-to-server rooms keep their static name and polygons.
		XCTAssertEqual(result.rooms.first(where: { $0.id == "ws-ubud" })?.name, "BINB Ubud Zoom")
		XCTAssertEqual(result.rooms.count, StaticRooms.rooms.count)
	}

	func testMapReservationsFiltersToBookedAndMarksMine() {
		let dtos = [
			makeReservationDTO(id: "mine", bookedBy: "u-1"),
			makeReservationDTO(id: "theirs", bookedBy: "u-2"),
			makeReservationDTO(id: "cancelled", status: "cancelled", bookedBy: "u-1"),
			makeReservationDTO(id: "released", status: "released"),
		]
		let mapped = ReservationService.mapReservations(dtos, myUserId: "u-1")
		XCTAssertEqual(mapped.map(\.id).sorted(), ["mine", "theirs"])
		XCTAssertEqual(mapped.first(where: { $0.id == "mine" })?.isMyReservation, true)
		XCTAssertEqual(mapped.first(where: { $0.id == "theirs" })?.isMyReservation, false)
		XCTAssertEqual(mapped.first?.roomId, "ws-ubud")
	}

	func testMapReservationsWithNoUserMarksNothingMine() {
		let mapped = ReservationService.mapReservations([makeReservationDTO(bookedBy: "u-1")], myUserId: nil)
		XCTAssertEqual(mapped.first?.isMyReservation, false)
	}

	func testStatusDisabledForUnbackedRoom() {
		let service = ReservationService()
		service.serverBacked = ["ws-agung"]
		let ubud = StaticRooms.rooms.first(where: { $0.id == "ws-ubud" })!
		// 10:00 is inside working hours; the room is unbacked so still disabled.
		let workingHour = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: .now)!
		if case .disabled = service.status(for: ubud, at: workingHour) {} else {
			XCTFail("expected .disabled for room missing from the server")
		}
	}
}
