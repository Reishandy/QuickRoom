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
	var myReservations: [Reservation] = []
	var isLoading: Bool = false

	private let client: APIClient
	private let auth: AuthService
	private var refreshTask: Task<Void, Never>?

	init(client: APIClient = .shared, auth: AuthService = .shared) {
		self.client = client
		self.auth = auth
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

	func refreshNow() async {
		try? await refresh()
	}

	func reserve(roomId: String, title: String?, startTime: Date, endTime: Date) async throws {
		let _: ReservationDTO = try await client.post("/reservations", body: CreateReservationRequest(workspaceId: roomId, title: title, startTime: startTime, endTime: endTime))
		try await refresh()
	}

	func renameReservation(reservationId: String, title: String) async throws {
		let _: ReservationDTO = try await client.patch("/reservations/\(reservationId)", body: UpdateReservationRequest(title: title))
		try await refresh()
	}

	func cancelReservation(reservationId: String) async throws {
		let _: ReservationDTO = try await client.post("/reservations/\(reservationId)/cancel")
		try await refresh()
	}

	func status(for room: Room, at time: Date) -> RoomStatus {
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

		rooms = Self.mapRooms(serverRooms)
		reservations = Self.mapReservations(serverReservations, myUserId: auth.currentUser?.userId)

		// Separate fetch: the user's own history (all statuses, so released
		// and cancelled bookings stay visible in My bookings). Tolerated on
		// failure so a hiccup here never blanks the rooms list.
		if auth.isSignedIn, let mine: ReservationsResponse = try? await client.get("/reservations/mine") {
			myReservations = Self.mapMine(mine.reservations)
		}
	}

	static func mapMine(_ dtos: [ReservationDTO]) -> [Reservation] {
		dtos.map { dto in
			Reservation(
				id: dto.reservationId,
				roomId: dto.zoomWorkspaceId,
				isMyReservation: true,
				status: dto.status,
<<<<<<< HEAD
				title: dto.title,
=======
>>>>>>> origin/main
				startTime: dto.startTime,
				endTime: dto.endTime
			)
		}
	}

	static func mapRooms(_ dtos: [RoomDTO]) -> [Room] {
		dtos.map { Room(id: $0.zoomWorkspaceId, name: $0.name, capacity: $0.capacity) }
	}

	/// Only `booked` reservations block a room; no-shows, releases and
	/// cancellations free it.
	static func mapReservations(_ dtos: [ReservationDTO], myUserId: String?) -> [Reservation] {
		dtos.filter { $0.status == "booked" }.map { dto in
			Reservation(
				id: dto.reservationId,
				roomId: dto.zoomWorkspaceId,
				isMyReservation: myUserId != nil && dto.bookedByUserId == myUserId,
				status: dto.status,
<<<<<<< HEAD
				title: dto.title,
=======
>>>>>>> origin/main
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
