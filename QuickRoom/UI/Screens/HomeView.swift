//
//  HomeView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 02/07/26.
//

import SwiftUI

enum HomeTab: Hashable {
	case rooms, bookings
}

struct HomeView: View {
	@Environment(ReservationService.self) private var reservationService

	@Binding var selectedDate: Date
	@Binding var selectedIndex: Int?
	@Binding var tab: HomeTab
	@Binding var newBookingId: String?
	let onRoomClick: (String) -> Void

	@State private var isAtNow = true
	@State private var goToNowPulse = 0
	@State private var jumpDate: Date? = nil
	@State private var showDatePicker = false

	// The scrubber's reachable window: today through its lookahead.
	private var jumpRange: ClosedRange<Date> {
		let today = Calendar.current.startOfDay(for: .now)
		let last = Calendar.current.date(byAdding: .day, value: AppConfig.Timeline.lookaheadDays, to: today) ?? today
		return today...last
	}

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
		TabView(selection: $tab) {
			Tab("Free rooms", systemImage: "door.left.hand.open", value: .rooms) {
				freeRoomsTab
			}
			Tab("My bookings", systemImage: "bookmark", value: .bookings) {
				myBookingsTab
			}
		}
	}

	// MARK: - Free rooms

	private var freeRoomsTab: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 16) {
					TimelineSliderView(
						selectedDate: $selectedDate,
						selectedIndex: $selectedIndex,
						isAtNow: $isAtNow,
						goToNowPulse: goToNowPulse,
						jumpDate: $jumpDate
					)
					.padding(.vertical, 6)
					.background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))

					if reservationService.isLoading && reservationService.rooms.isEmpty {
						loadingCard
					} else if availableRooms.isEmpty {
						emptyCard(
							"No Rooms Available",
							systemImage: "door.left.hand.closed",
							description: "Everything is booked at this time. Try another time or day."
						)
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
			.refreshable {
				await reservationService.refreshNow()
			}
			.background(Color(uiColor: .systemGroupedBackground))
			.navigationTitle("Free rooms")
			.navigationSubtitle(selectedDate.toHomeString())
			.toolbar {
				ToolbarItemGroup(placement: .topBarTrailing) {
					Button("Now") {
						goToNowPulse += 1
					}
					.disabled(isAtNow)

					Button("Jump to date", systemImage: "calendar") {
						showDatePicker = true
					}
					.popover(isPresented: $showDatePicker) {
						DatePicker(
							"Jump to date",
							selection: Binding(
								get: { selectedDate },
								set: { day in
									jumpDate = day
									showDatePicker = false
								}
							),
							in: jumpRange,
							displayedComponents: [.date]
						)
						.datePickerStyle(.graphical)
						.frame(width: 320, height: 330)
						.padding(.horizontal, 8)
						.presentationCompactAdaptation(.popover)
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
					if reservationService.isLoading && myBookings.isEmpty {
						loadingCard
					} else if myBookings.isEmpty {
						emptyCard(
							"No Bookings Yet",
							systemImage: "bookmark",
							description: "Rooms you book will show up here."
						)
					} else {
						bookingList
					}
				}
				.padding(.horizontal, 16)
				.padding(.top, 8)
			}
			.scrollIndicators(.hidden)
			.refreshable {
				await reservationService.refreshNow()
			}
			.background(Color(uiColor: .systemGroupedBackground))
			.navigationTitle("My bookings")
			.animation(.easeInOut(duration: 0.25), value: myBookings)
			.animation(.easeOut(duration: 0.6), value: newBookingId)
			.task(id: newBookingId) {
				// Let the fresh booking glow briefly, then fade the tint out.
				guard newBookingId != nil else { return }
				try? await Task.sleep(for: .seconds(1.8))
				newBookingId = nil
			}
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
				.padding(.horizontal, 10)
				.background(
					booking.id == newBookingId ? Color(uiColor: .systemBlue).opacity(0.12) : .clear,
					in: RoundedRectangle(cornerRadius: 10)
				)
				.padding(.horizontal, -10)

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

	private func emptyCard(_ title: String, systemImage: String, description: String) -> some View {
		ContentUnavailableView(title, systemImage: systemImage, description: Text(description))
			.frame(maxWidth: .infinity)
			.frame(minHeight: 320)
			.background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
	}

	private var loadingCard: some View {
		ProgressView()
			.controlSize(.large)
			.frame(maxWidth: .infinity)
			.frame(minHeight: 320)
			.background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
	}
}

#Preview {
	@Previewable @State var selectedDate: Date = .now
	@Previewable @State var selectedIndex: Int? = nil
	@Previewable @State var tab: HomeTab = .rooms
	@Previewable @State var newBookingId: String? = nil

	let service = ReservationService()
	service.rooms = [
		Room(id: "ws-petang", name: "Petang", capacity: 6),
		Room(id: "ws-mengwi", name: "Mengwi", capacity: 2),
		Room(id: "ws-bedugul", name: "Bedugul", capacity: 2),
	]

	return HomeView(
		selectedDate: $selectedDate,
		selectedIndex: $selectedIndex,
		tab: $tab,
		newBookingId: $newBookingId,
		onRoomClick: { _ in }
	)
	.environment(service)
}
