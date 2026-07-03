//
//  ReservationList.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import SwiftUI

struct ReservationList: View {
	let reservations: [Reservation]
	let onReservationClick: (String) -> Void
	@State private var showInlineTitle = false
	
	private var myReservations: [Reservation] {
		reservations.filter { $0.isMyReservation }
	}
	
	var body: some View {
		if myReservations.isEmpty {
			VStack(spacing: 12) {
				Image(systemName: "hand.tap")
					.font(.system(size: 48))
					.foregroundStyle(Color(UIColor.systemBlue))
				Text("Select a room to reserve")
					.font(.title)
					.foregroundStyle(.secondary)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		} else {
			NavigationStack {
				List {
					Text("My Reservation")
						.font(.title2)
						.bold()
						.listRowSeparator(.hidden)
					
					ForEach(myReservations) { reservation in
						Button {
							onReservationClick(reservation.roomId)
						} label: {
							listItem(for: reservation)
						}
						.alignmentGuide(.listRowSeparatorLeading) { dimensions in
							dimensions[.leading]
						}
					}
				}
				.listStyle(.plain)
				.contentMargins(.top, -50, for: .scrollContent)
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .principal) {
						Text("My Reservation")
							.font(.headline)
							.opacity(showInlineTitle ? 1 : 0)
					}
				}
				.onScrollGeometryChange(for: Bool.self) { geometry in
					geometry.contentOffset.y > 0
				} action: { oldValue, newValue in
					withAnimation(.easeInOut(duration: 0.2)) {
						showInlineTitle = newValue
					}
				}
			}
		}
	}
	
	private func listItem(for reservation: Reservation) -> some View {
		let room = StaticRooms.rooms.first(where: { $0.id == reservation.roomId })
		let roomName = room?.name ?? "Unknown Room"
		
		let dynamicInterval = DateInterval(start: reservation.startTime, end: reservation.endTime)
		
		return HStack(spacing: 12) {
			Image(systemName: "door.left.hand.closed")
				.foregroundStyle(.blue.gradient)
				.font(.largeTitle)
			
			VStack(alignment: .leading, spacing: 4) {
				Text(roomName)
					.bold()
				Text(dynamicInterval.toReservationString())
					.foregroundStyle(.secondary)
			}
			Spacer()
			Image(systemName: "chevron.right")
				.foregroundStyle(.secondary)
		}
	}
}

#Preview {
	ReservationList(reservations: [
		Reservation(
			id: UUID().uuidString,
			roomId: "room-a",
			isMyReservation: true,
			startTime: .now,
			endTime: .now.addingTimeInterval(3600)
		)
	]) { _ in }
}

#Preview {
	ReservationList(reservations: []) { _ in }
}
