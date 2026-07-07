//
//  HomeView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 02/07/26.
//

import SwiftUI

struct HomeView: View {
	@Environment(ReservationService.self) private var reservationService
	
	let selectedDate: Date
	var onInteract: () -> Void
	let onRoomClick: (String) -> Void
	
	// TODO: Replace with UI redesign
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			Image("floorplan")
				.resizable()
				.scaledToFit()
				.containerRelativeFrame(.vertical)
				.overlay {
					GeometryReader { geo in
						ZStack {
							ForEach(StaticRooms.rooms) { room in
								RoomOverlayView(
									room: room,
									status: reservationService.status(for: room, at: selectedDate),
									geoSize: geo.size
								) { roomId in
									onRoomClick(roomId)
								}
							}
						}
					}
				}
		}
		.simultaneousGesture(
			DragGesture().onChanged { _ in
				onInteract()
			}
		)
	}
}

#Preview {
	HomeView(
		selectedDate: .now,
		onInteract: {},
		onRoomClick: { _ in }
	)
}
