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

	func testMapRoomsUsesWorkspaceIdAndCapacity() {
		let server = try! APIClient.decoder.decode(RoomsResponse.self, from: Data("""
		{"rooms":[{"room_id":"room-ws-agung","zoom_workspace_id":"ws-agung","name":"Agung","floor":"","capacity":8,"has_tv":true,"is_zoom_room":true}]}
		""".utf8)).rooms
		let rooms = ReservationService.mapRooms(server)
		XCTAssertEqual(rooms, [Room(id: "ws-agung", name: "Agung", capacity: 8)])
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

	func testStatusDisabledOutsideWorkingHours() {
		let service = ReservationService()
		let room = Room(id: "ws-ubud", name: "Ubud", capacity: 4)
		let lateHour = Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: .now)!
		if case .disabled = service.status(for: room, at: lateHour) {} else {
			XCTFail("expected .disabled outside working hours")
		}
	}
}
