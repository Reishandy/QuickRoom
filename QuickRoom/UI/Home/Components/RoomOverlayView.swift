//
//  RoomOverlayView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import SwiftUI

struct RoomOverlayView: View {
	let room: Room
	let geoSize: CGSize
	let onRoomClick: (UUID) -> Void
	
	// TODO: Match design
	// TODO: Disable room when out of hour or weekend
    var body: some View {
		RelativePolygonShape(relativePoints: room.relativePoints)
			.fill(room.isDisabled ? Color.secondary.opacity(0.4) : Color.green.opacity(0.4))
			.stroke(room.isDisabled ? Color.secondary : Color.green, lineWidth: 2)
			.contentShape(RelativePolygonShape(relativePoints: room.relativePoints))
			.onTapGesture {
				onRoomClick(room.id)
			}
		
		let minX = room.relativePoints.map(\.x).min() ?? 0
		let maxX = room.relativePoints.map(\.x).max() ?? 0
		let minY = room.relativePoints.map(\.y).min() ?? 0
		let maxY = room.relativePoints.map(\.y).max() ?? 0
		
		let midX = (minX + maxX) / 2.0
		let midY = (minY + maxY) / 2.0
		
		Text(room.name)
			.font(.caption)
			.fontWeight(.bold)
			.foregroundColor(.white)
			.padding(.horizontal, 6)
			.padding(.vertical, 4)
			.background(Color.black.opacity(0.6))
			.clipShape(Capsule())
			.position(x: midX * geoSize.width, y: midY * geoSize.height)
			.allowsHitTesting(false)
    }
}

#Preview {
	// No Preview cause I am lazy :P
}
