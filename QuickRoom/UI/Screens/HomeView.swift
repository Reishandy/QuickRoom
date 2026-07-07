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

	@State private var isAtNow = true
	@State private var goToNowPulse = 0
	@State private var jumpDate: Date? = nil
	@State private var showDayStrip = false

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
		TabView {
			Tab("Free rooms", systemImage: "door.left.hand.open") {
				freeRoomsTab
			}
			Tab("My bookings", systemImage: "bookmark") {
				myBookingsTab
			}
		}
	}

	// MARK: - Free rooms

	private var freeRoomsTab: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 16) {
					VStack(spacing: 4) {
						// Hidden by default; a pull-down on the page reveals it
						// (search-bar style) for long jumps across days.
						if showDayStrip {
							HorizontalDatePickerView(selectedDate: Binding(
								get: { selectedDate },
								set: { day in
									jumpDate = day
									withAnimation(.spring(duration: 0.35)) { showDayStrip = false }
								}
							))
							.frame(maxHeight: 76)
							.padding(.top, 8)
							.transition(.move(edge: .top).combined(with: .opacity))

							Divider().padding(.horizontal, 16)
						}

						TimelineSliderView(
							selectedDate: $selectedDate,
							selectedIndex: $selectedIndex,
							isAtNow: $isAtNow,
							goToNowPulse: goToNowPulse,
							jumpDate: $jumpDate
						)
						.padding(.bottom, 6)
					}
					.background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))

					if availableRooms.isEmpty {
						emptyCard("There are no available rooms")
							.transition(.opacity)
					} else {
						roomList
							.transition(.opacity)
					}
				}
				.padding(.horizontal, 16)
				.padding(.top, 8)
			}
			.scrollIndicators(.hidden)
			.onScrollGeometryChange(for: CGFloat.self) { geometry in
				geometry.contentOffset.y + geometry.contentInsets.top
			} action: { _, offset in
				if offset < -64 && !showDayStrip {
					withAnimation(.spring(duration: 0.35)) { showDayStrip = true }
				} else if offset > 24 && showDayStrip {
					withAnimation(.spring(duration: 0.35)) { showDayStrip = false }
				}
			}
			.background(Color(uiColor: .systemGroupedBackground))
			.navigationTitle("Free rooms")
			.navigationSubtitle(selectedDate.toHomeString())
			.toolbar {
				if !isAtNow {
					ToolbarItem(placement: .topBarTrailing) {
						Button("Now") {
							goToNowPulse += 1
						}
					}
				}
			}
			.animation(.easeInOut(duration: 0.25), value: availableRooms)
			.animation(.easeInOut(duration: 0.2), value: isAtNow)
		}
	}

	private var roomList: some View {
		VStack(spacing: 0) {
			ForEach(availableRooms) { room in
				Button {
					onRoomClick(room.id)
				} label: {
					HStack(spacing: 12) {
						roomIcon(room)
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
	}

	// MARK: - My bookings

	private var myBookingsTab: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 16) {
					if myBookings.isEmpty {
						emptyCard("You have no bookings")
					} else {
						bookingList
					}
				}
				.padding(.horizontal, 16)
				.padding(.top, 8)
			}
			.scrollIndicators(.hidden)
			.background(Color(uiColor: .systemGroupedBackground))
			.navigationTitle("My bookings")
			.animation(.easeInOut(duration: 0.25), value: myBookings)
		}
	}

	private var bookingList: some View {
		VStack(spacing: 0) {
			ForEach(myBookings) { booking in
				Button {
					selectedDate = booking.startTime
					onRoomClick(booking.roomId)
				} label: {
					HStack(spacing: 12) {
						rowIcon("bookmark.fill", tint: Color(uiColor: .systemBlue))
						VStack(alignment: .leading, spacing: 2) {
							Text(booking.title.isEmpty ? roomName(booking.roomId) : booking.title)
								.fontWeight(.semibold)
							if !booking.title.isEmpty {
								Text(roomName(booking.roomId))
									.font(.footnote)
									.foregroundStyle(.secondary)
							}
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
	}

	// MARK: - Shared bits

	private func roomName(_ roomId: String) -> String {
		reservationService.rooms.first(where: { $0.id == roomId })?.name ?? roomId
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

	// Every room gets its own symbol (mentor feedback), all in the app's
	// single blue so the list stays calm; assigned from a stable hash of the
	// workspace id so it never changes between launches and new rooms need
	// no app update.
	private static let iconSymbols = [
		"mountain.2.fill", "water.waves", "leaf.fill", "sun.max.fill",
		"moon.stars.fill", "tree.fill", "flame.fill", "tornado",
		"bird.fill", "fish.fill",
	]

	private func roomIcon(_ room: Room) -> some View {
		let stableHash = room.id.unicodeScalars.reduce(0) { $0 &* 31 &+ Int($1.value) }
		return rowIcon(Self.iconSymbols[abs(stableHash) % Self.iconSymbols.count], tint: Color(uiColor: .systemBlue))
	}

	private func rowIcon(_ systemName: String, tint: Color) -> some View {
		Image(systemName: systemName)
			.font(.system(size: 15, weight: .semibold))
			.foregroundStyle(.white)
			.frame(width: 36, height: 36)
			.background(tint.gradient, in: Circle())
	}

	private func emptyCard(_ message: String) -> some View {
		Text(message)
			.foregroundStyle(.secondary)
			.frame(maxWidth: .infinity)
			.frame(minHeight: 320)
			.background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
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
