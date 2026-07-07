//
//  ReservationService.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import Foundation
import SwiftUI
import UIKit

@Observable
class ReservationService {
	var rooms: [Room] = []
	var reservations: [Reservation] = []
	var isLoading: Bool = false
	var serverBacked: Set<String> = []

	private let client: APIClient
	private let auth: AuthService
	private var refreshTask: Task<Void, Never>?

	init(client: APIClient = .shared, auth: AuthService = .shared) {
		self.client = client
		self.auth = auth
		self.rooms = StaticRooms.rooms
	}

	// TODO: Reservation rule
	func fetchReservationsOnLoad() async throws {
		isLoading = true
		// Auto-refresh must start even when this first fetch fails: before
		// sign-in the API answers 401, and the refresh loop is what heals
		// the app once a session exists.
		defer {
			isLoading = false
			startAutoRefresh()
		}
		try await refresh()
	}

	func reserve(roomId: String, startTime: Date, endTime: Date) async throws {
		let _: ReservationDTO = try await client.post("/reservations", body: CreateReservationRequest(workspaceId: roomId, startTime: startTime, endTime: endTime))
		try await refresh()
	}

	func cancelReservation(reservationId: String) async throws {
		let _: ReservationDTO = try await client.post("/reservations/\(reservationId)/cancel")
		try await refresh()
	}

	func status(for room: Room, at time: Date) -> RoomStatus {
		guard serverBacked.contains(room.id) else {
			return .disabled
		}
		guard Calendar.current.isWithinWorkingHours(time) else {
			return .disabled
		}

		let activeReservation = reservations.first { reservation in
			reservation.roomId == room.id && time >= reservation.startTime && time < reservation.endTime
		}

		if let reservation = activeReservation {
			return .reserved(isMine: reservation.isMyReservation)
		}

		return .available
	}

	private func refresh() async throws {
		async let roomsResponse: RoomsResponse = client.get("/rooms")
		async let reservationsResponse: ReservationsResponse = client.get("/reservations")
		let (serverRooms, serverReservations) = try await (roomsResponse.rooms, reservationsResponse.reservations)

		let overlay = Self.overlayServerRooms(onto: StaticRooms.rooms, server: serverRooms)
		rooms = overlay.rooms
		serverBacked = overlay.serverBacked
		reservations = Self.mapReservations(serverReservations, myUserId: auth.currentUser?.userId)
	}

	/// Static polygons + live server names. A mapped room the server no
	/// longer reports stays visible but renders disabled via `serverBacked`.
	static func overlayServerRooms(onto staticRooms: [Room], server: [RoomDTO]) -> (rooms: [Room], serverBacked: Set<String>) {
		let byWorkspaceId = Dictionary(uniqueKeysWithValues: server.map { ($0.zoomWorkspaceId, $0) })
		let rooms = staticRooms.map { room in
			guard let dto = byWorkspaceId[room.id] else { return room }
			return Room(id: room.id, name: dto.name, relativePoints: room.relativePoints)
		}
		return (rooms, Set(staticRooms.map(\.id).filter { byWorkspaceId[$0] != nil }))
	}

	/// Only `booked` reservations block a room; no-shows, releases and
	/// cancellations free it.
	static func mapReservations(_ dtos: [ReservationDTO], myUserId: String?) -> [Reservation] {
		dtos.filter { $0.status == "booked" }.map { dto in
			Reservation(
				id: dto.reservationId,
				roomId: dto.zoomWorkspaceId,
				isMyReservation: myUserId != nil && dto.bookedByUserId == myUserId,
				startTime: dto.startTime,
				endTime: dto.endTime
			)
		}
	}

	/// Other users' bookings and the backend's no-show releases should show
	/// up without a relaunch.
	private func startAutoRefresh() {
		guard refreshTask == nil else { return }
		refreshTask = Task { [weak self] in
			while !Task.isCancelled {
				try? await Task.sleep(for: .seconds(30))
				guard let self else { return }
				if UIApplication.shared.applicationState == .active {
					try? await self.refresh()
				}
			}
		}
	}
}
