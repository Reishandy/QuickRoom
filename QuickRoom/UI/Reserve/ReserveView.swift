//
//  ReserveView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import SwiftUI

struct ReserveView: View {
	let roomId: String
	@Environment(ReservationService.self) private var reservationService
	
	var body: some View {
		List {
			Section("Room Reservations") {
				let roomReservations = reservationService.reservations
					.filter { $0.roomId == roomId }
					.sorted { $0.startTime < $1.startTime }
				
				if roomReservations.isEmpty {
					Text("No reservations for this room.")
						.foregroundStyle(.secondary)
				} else {
					ForEach(roomReservations) { reservation in
						VStack(alignment: .leading, spacing: 4) {
							Text(reservation.isMyReservation ? "My Reservation" : "Reserved")
								.font(.headline)
								.foregroundStyle(reservation.isMyReservation ? .blue : .red)
							
							Text(DateInterval(start: reservation.startTime, end: reservation.endTime).toReservationString())
								.font(.subheadline)
								.foregroundStyle(.secondary)
						}
						.padding(.vertical, 4)
					}
				}
			}
		}
		.navigationTitle(StaticRooms.rooms.first(where: { $0.id == roomId })?.name ?? "Room")
		.navigationBarTitleDisplayMode(.inline)
	}
}

#Preview {
	NavigationStack {
		ReserveView(roomId: "ws-agung")
			.environment(ReservationService())
	}
}
