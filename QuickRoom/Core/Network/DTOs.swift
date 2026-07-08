//
//  DTOs.swift
//  QuickRoom
//
//  Created by Asadullokh Nurullaev on 05/07/26.
//

import Foundation

struct RoomsResponse: Decodable {
	let rooms: [RoomDTO]
}

struct RoomDTO: Decodable {
	let roomId: String
	let zoomWorkspaceId: String
	let name: String
	let capacity: Int
	let hasTv: Bool
	let isZoomRoom: Bool
}

struct ReservationsResponse: Decodable {
	let reservations: [ReservationDTO]
}

struct ReservationDTO: Decodable {
	let reservationId: String
	let roomId: String
	let zoomWorkspaceId: String
	let title: String
	let userId: String
	let userEmail: String
	let startTime: Date
	let endTime: Date
	let status: String
	let checkInStatus: String
	let source: String
	let bookedByUserId: String?
}

struct UserDTO: Codable {
	let userId: String
	let email: String
	let name: String
}

struct AuthResponse: Decodable {
	let sessionToken: String
	let user: UserDTO
}

struct BeaconsResponse: Decodable {
	let beacons: [BeaconEntryDTO]
}

struct BeaconEntryDTO: Decodable {
	let workspaceId: String
	let uuid: String
	let major: Int
	let minor: Int
	let name: String
}

/// Generic `{"status":"ok"}`-style responses; also absorbs POST /presence,
/// which returns either a status object or a full reservation.
struct StatusResponse: Decodable {
	let status: String?
	let workspaceId: String?
}

struct CreateReservationRequest: Encodable {
	let workspaceId: String
	let title: String?
	let startTime: Date
	let endTime: Date
}

struct UpdateReservationRequest: Encodable {
	let title: String?
}

struct AppleAuthRequest: Encodable {
	let identityToken: String
	let name: String?
}

struct PresenceRequest: Encodable {
	let workspaceId: String
	let userId: String
	let displayName: String
	let eventType: String
	let eventTs: Int64
}
