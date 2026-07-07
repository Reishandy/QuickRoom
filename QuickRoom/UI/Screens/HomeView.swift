//
//  HomeView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 02/07/26.
//

import SwiftUI

struct HomeView: View {
	@Environment(ReservationService.self) private var reservationService

	@Binding var selectedDate: Date
	@Binding var selectedIndex: Int?
	let onRoomClick: (String) -> Void

	private enum Tab {
		case freeRooms, myBookings
	}

	@State private var tab: Tab = .freeRooms

	private var availableRooms: [Room] {
		reservationService.rooms.filter {
			if case .available = reservationService.status(for: $0, at: selectedDate) {
				return true
			}
			return false
		}
	}

	// Active and upcoming bookings first (soonest on top), then history
	// (released, cancelled, no-show, past) newest first.
	private var myBookings: [Reservation] {
		let now = Date.now
		let active = reservationService.myReservations
			.filter { $0.status == "booked" && $0.endTime >= now }
			.sorted { $0.startTime < $1.startTime }
		let history = reservationService.myReservations
			.filter { !($0.status == "booked" && $0.endTime >= now) }
			.sorted { $0.startTime > $1.startTime }
		return active + history
	}

	var body: some View {
		ZStack(alignment: .bottom) {
			VStack(alignment: .leading, spacing: 16) {
				header

				if tab == .freeRooms {
					TimelineSliderView(selectedDate: $selectedDate, selectedIndex: $selectedIndex)
						.padding(.vertical, 6)
						.background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))

					if availableRooms.isEmpty {
						emptyCard("There are no available rooms")
							.transition(.opacity)
					} else {
						roomList
							.transition(.opacity)
					}
				} else {
					if myBookings.isEmpty {
						emptyCard("You have no bookings")
					} else {
						bookingList
					}
				}
			}
			.padding(.horizontal, 16)

			tabBar
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color(uiColor: .systemGroupedBackground))
		.animation(.easeInOut(duration: 0.2), value: tab)
		.animation(.easeInOut(duration: 0.25), value: availableRooms)
		.animation(.easeInOut(duration: 0.25), value: myBookings)
	}

	@ViewBuilder
	private var header: some View {
		VStack(alignment: .leading, spacing: 2) {
			if tab == .freeRooms {
				Text("Available rooms for")
					.font(.title2)
					.fontWeight(.semibold)
				Text(selectedDate.toHomeString())
					.font(.title)
					.bold()
					.contentTransition(.numericText())
					.animation(.default, value: selectedDate)
			} else {
				Text("My bookings")
					.font(.title)
					.bold()
			}
		}
		.padding(.top, 12)
	}

	private var roomList: some View {
		ScrollView {
			VStack(spacing: 0) {
				ForEach(availableRooms) { room in
					Button {
						onRoomClick(room.id)
					} label: {
						HStack(spacing: 12) {
							rowIcon("door.left.hand.open")
							VStack(alignment: .leading, spacing: 2) {
								Text(room.name)
									.fontWeight(.semibold)
								Text("For \(room.capacity) people")
									.font(.subheadline)
									.foregroundStyle(.secondary)
							}
							Spacer()
							Image(systemName: "chevron.right")
								.font(.footnote.weight(.semibold))
								.foregroundStyle(.tertiary)
						}
						.padding(.vertical, 10)
						.contentShape(Rectangle())
					}
					.buttonStyle(.plain)

					if room.id != availableRooms.last?.id {
						Divider().padding(.leading, 48)
					}
				}
			}
			.padding(.horizontal, 16)
			.padding(.vertical, 6)
			.background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
			.padding(.bottom, 90) // keep the last row clear of the tab bar
		}
		.scrollIndicators(.hidden)
	}

	private var bookingList: some View {
		ScrollView {
			VStack(spacing: 0) {
				ForEach(myBookings) { booking in
					Button {
						selectedDate = booking.startTime
						onRoomClick(booking.roomId)
					} label: {
						HStack(spacing: 12) {
							rowIcon("bookmark.fill")
							VStack(alignment: .leading, spacing: 2) {
								Text(reservationService.rooms.first(where: { $0.id == booking.roomId })?.name ?? booking.roomId)
									.fontWeight(.semibold)
								Text(DateInterval(start: booking.startTime, end: booking.endTime).toReservationString())
									.font(.subheadline)
									.foregroundStyle(.secondary)
							}
							Spacer()
							statusBadge(booking.status)
							Image(systemName: "chevron.right")
								.font(.footnote.weight(.semibold))
								.foregroundStyle(.tertiary)
						}
						.padding(.vertical, 10)
						.contentShape(Rectangle())
					}
					.buttonStyle(.plain)

					if booking.id != myBookings.last?.id {
						Divider().padding(.leading, 48)
					}
				}
			}
			.padding(.horizontal, 16)
			.padding(.vertical, 6)
			.background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
			.padding(.bottom, 90)
		}
		.scrollIndicators(.hidden)
	}

	private func statusBadge(_ status: String) -> some View {
		let (label, color): (String, Color) = switch status {
		case "booked": ("Booked", .blue)
		case "released": ("Released", .orange)
		case "no_show": ("No-show", .red)
		case "cancelled": ("Cancelled", .secondary)
		default: (status.capitalized, .secondary)
		}
		return Text(label)
			.font(.caption2.weight(.semibold))
			.foregroundStyle(color)
			.padding(.horizontal, 8)
			.padding(.vertical, 4)
			.background(color.opacity(0.12), in: Capsule())
	}

	private func rowIcon(_ systemName: String) -> some View {
		Image(systemName: systemName)
			.font(.system(size: 15, weight: .semibold))
			.foregroundStyle(.white)
			.frame(width: 36, height: 36)
			.background(Color(uiColor: .systemBlue).gradient, in: Circle())
	}

	private func emptyCard(_ message: String) -> some View {
		Text(message)
			.foregroundStyle(.secondary)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
			.padding(.bottom, 90)
	}

	private var tabBar: some View {
		HStack(spacing: 4) {
			tabButton(.freeRooms, icon: "door.left.hand.open", label: "Free rooms")
			tabButton(.myBookings, icon: "bookmark.circle.fill", label: "My bookings")
		}
		.padding(6)
		.background(.regularMaterial, in: Capsule())
		.shadow(color: .black.opacity(0.12), radius: 12, y: 4)
		.padding(.bottom, 8)
	}

	private func tabButton(_ target: Tab, icon: String, label: String) -> some View {
		Button {
			tab = target
		} label: {
			HStack(spacing: 6) {
				Image(systemName: icon)
				Text(label)
					.font(.footnote.weight(.semibold))
			}
			.foregroundStyle(tab == target ? Color(uiColor: .systemBlue) : Color(uiColor: .label))
			.padding(.horizontal, 14)
			.padding(.vertical, 10)
			.background {
				if tab == target {
					Capsule()
						.fill(Color(uiColor: .systemBackground))
						.shadow(color: .black.opacity(0.08), radius: 4, y: 1)
				}
			}
		}
		.buttonStyle(.plain)
		.sensoryFeedback(.selection, trigger: tab)
	}
}

#Preview {
	@Previewable @State var selectedDate: Date = .now
	@Previewable @State var selectedIndex: Int? = nil

	let service = ReservationService()
	service.rooms = [
		Room(id: "ws-petang", name: "Petang", capacity: 6),
		Room(id: "ws-mengwi", name: "Mengwi", capacity: 2),
		Room(id: "ws-bedugul", name: "Bedugul", capacity: 2),
	]

	return HomeView(
		selectedDate: $selectedDate,
		selectedIndex: $selectedIndex,
		onRoomClick: { _ in }
	)
	.environment(service)
}
