//
//  HomeView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 02/07/26.
//

import SwiftUI

struct HomeView: View {
	var onInteract: () -> Void
	let onRoomClick: (UUID) -> Void
	
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
		onInteract: {},
		onRoomClick: { _ in }
	)
}
