//
//  RoomOverlayView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import SwiftUI

struct RoomOverlayView: View {
	let room: Room
	let status: RoomStatus
	let geoSize: CGSize
	let onRoomClick: (String) -> Void
	
	private var roomColor: Color {
		switch status {
		case .available:
			return .green
		case .reserved(let isMine):
			return isMine ? .blue : .red
		case .disabled:
			return .gray
		}
	}
	
	// TODO: Match design
	var body: some View {
		RelativePolygonShape(relativePoints: room.relativePoints)
			.fill(roomColor.opacity(0.4))
			.stroke(roomColor, lineWidth: 2)
			.contentShape(RelativePolygonShape(relativePoints: room.relativePoints))
			.onTapGesture {
				onRoomClick(room.id)
			}
			.overlay {
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
}

#Preview {
	// No Preview cause I am lazy :P
}
