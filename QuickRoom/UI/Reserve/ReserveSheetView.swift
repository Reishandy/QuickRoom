//
//  ReserveSheetView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import SwiftUI

struct ReserveSheetView: View {
	@Environment(ReservationService.self) private var reservationService
	
	let roomId: String
	
	@State private var startTime: Date = .now
	@State private var endTime: Date = .now.addingTimeInterval(3600) // Default 1 hour
	@State private var isProcessing = false
	
	var body: some View {
		NavigationStack {
			Form {
				Section("Book Time") {
					DatePicker("Start", selection: $startTime)
					DatePicker("End", selection: $endTime)
					
					Button {
						Task {
							isProcessing = true
							try? await reservationService.reserve(roomId: roomId, startTime: startTime, endTime: endTime)
							isProcessing = false
						}
					} label: {
						if isProcessing {
							ProgressView()
						} else {
							Text("Reserve")
								.frame(maxWidth: .infinity)
						}
					}
					.buttonStyle(.borderedProminent)
					.disabled(isProcessing || startTime >= endTime)
				}
				
				let myReservations = reservationService.reservations.filter { $0.roomId == roomId && $0.isMyReservation }
				
				if !myReservations.isEmpty {
					Section("My Active Reservations") {
						ForEach(myReservations) { reservation in
							HStack {
								Text(DateInterval(start: reservation.startTime, end: reservation.endTime).toReservationString())
									.font(.subheadline)
								Spacer()
								Button(role: .destructive) {
									Task {
										try? await reservationService.cancelReservation(reservationId: reservation.id)
									}
								} label: {
									Text("Cancel")
								}
								.buttonStyle(.bordered)
							}
						}
					}
				}
			}
			.navigationTitle("Reserve Room")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

#Preview {
	ReserveSheetView(roomId: "room-a")
		.environment(ReservationService())
}
