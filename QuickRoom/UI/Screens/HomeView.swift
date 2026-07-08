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

	@State private var isAtNow = true
	@State private var goToNowPulse = 0
	@State private var jumpDate: Date? = nil
	@State private var showDatePicker = false
	@State private var selectedRoomId: String? = nil
	@State private var bookedPulse = 0
	@State private var settledSlotState: SlotState = .open
	@State private var lastOpenDate: Date = .now

	private var availableRooms: [Room] {
		// While the scrubber is mid-flight over a closed stretch the list keeps
		// showing the last open moment, so nothing flashes underneath.
		let date = slotState == .open ? selectedDate : lastOpenDate
		return reservationService.rooms.filter {
			if case .available = reservationService.status(for: $0, at: date) {
				return true
			}
			return false
		}
	}

	private enum SlotState { case open, closed, weekend }

	// Mirrors the ruler's regions: Sat/Sun plus Friday night and Monday
	// pre-dawn read as "Weekend", weekday nights as "Close".
	private var slotState: SlotState {
		let calendar = Calendar.current
		if calendar.isWithinWorkingHours(selectedDate) { return .open }
		let weekday = calendar.component(.weekday, from: selectedDate)
		let hour = calendar.component(.hour, from: selectedDate)
		let isWeekendRegion = weekday == 1 || weekday == 7
			|| (weekday == 6 && hour >= AppConfig.WorkingHours.end)
			|| (weekday == 2 && hour < AppConfig.WorkingHours.start)
		return isWeekendRegion ? .weekend : .closed
	}

	// Bookings grouped per day, today first, then coming days (design: Abu).
	// Past days drop off entirely.
	private var bookingDays: [(day: Date, title: String, bookings: [Reservation])] {
		let calendar = Calendar.current
		let todayStart = calendar.startOfDay(for: .now)
		let upcoming = reservationService.myReservations.filter {
			calendar.startOfDay(for: $0.startTime) >= todayStart
		}
		let grouped = Dictionary(grouping: upcoming) { calendar.startOfDay(for: $0.startTime) }
		return grouped.keys.sorted().map { day in
			(day, dayTitle(day), grouped[day]!.sorted { $0.startTime < $1.startTime })
		}
	}

	private func dayTitle(_ day: Date) -> String {
		let date = DateFormatter()
		date.dateFormat = "d MMMM"
		let calendar = Calendar.current
		if calendar.isDateInToday(day) { return "Today, " + date.string(from: day) }
		if calendar.isDateInTomorrow(day) { return "Tomorrow, " + date.string(from: day) }
		let weekday = DateFormatter()
		weekday.dateFormat = "EEEE, d MMMM"
		return weekday.string(from: day)
	}

	private var myBookings: [Reservation] {
		bookingDays.flatMap(\.bookings)
	}

	var body: some View {
		TabView(selection: $tab) {
			Tab("Available rooms", systemImage: "door.left.hand.open", value: .rooms) {
				freeRoomsTab
			}
			Tab("My bookings", systemImage: "bookmark", value: .bookings) {
				myBookingsTab
			}
		}
		.sensoryFeedback(.success, trigger: bookedPulse)
		.sheet(isPresented: Binding(
			get: { selectedRoomId != nil },
			set: { isPresented in
				if !isPresented { selectedRoomId = nil }
			}
		)) {
			if let roomId = selectedRoomId {
				ReserveSheetView(selectedDate: $selectedDate, roomId: roomId) {
					bookedPulse += 1
					selectedRoomId = nil
					tab = .bookings
				}
				.presentationDetents([.large])
				.interactiveDismissDisabled(true)
				.presentationDragIndicator(.hidden)
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
					.padding(.horizontal, -16) // full-bleed ruler (Abu: full screen width)

					if reservationService.isLoading && reservationService.rooms.isEmpty {
						loadingCard
					} else if settledSlotState == .weekend {
						emptyCard(
							"Closed for the Weekend",
							systemImage: "beach.umbrella",
							description: "The space is closed on weekends. Jump to a weekday to book a room."
						)
						.transition(.opacity)
					} else if settledSlotState == .closed {
						emptyCard(
							"Closed at This Time",
							systemImage: "moon.zzz",
							description: "Working hours are \(AppConfig.WorkingHours.start):00–\(AppConfig.WorkingHours.end):00. Pick a time during the day."
						)
						.transition(.opacity)
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
			.navigationTitle("Available rooms")
			.navigationBarTitleDisplayMode(.inline)
			.navigationSubtitle(selectedDate.toHomeString())
			.toolbar {
				// Return-to-now lives top-left as a prominent capsule and only
				// appears once the scrubber has left the current time (design: Abu).
				if !isAtNow {
					ToolbarItem(placement: .topBarLeading) {
						Button("Now") {
							goToNowPulse += 1
						}
						.buttonStyle(.borderedProminent)
					}
				}

				ToolbarItem(placement: .topBarTrailing) {
					Button("Jump to date", systemImage: "calendar") {
						showDatePicker = true
					}
					.popover(isPresented: $showDatePicker) {
						JumpWeeksView(selectedDate: selectedDate) { day in
							jumpDate = day
							showDatePicker = false
						}
						.padding(16)
						.presentationCompactAdaptation(.popover)
					}
				}
			}
			.animation(.easeInOut(duration: 0.25), value: availableRooms)
			.animation(.easeInOut(duration: 0.25), value: settledSlotState)
			.animation(.easeInOut(duration: 0.2), value: isAtNow)
			.onAppear {
				settledSlotState = slotState
				lastOpenDate = slotState == .open ? selectedDate : TimelineUtilities.bookableNow()
			}
			.onChange(of: selectedDate) { _, newDate in
				if slotState == .open { lastOpenDate = newDate }
			}
			// A fling across a closed night or weekend must not flash the
			// Closed card — it only appears once the scrubber rests there.
			.task(id: slotState) {
				if slotState == .open {
					settledSlotState = .open
				} else {
					try? await Task.sleep(for: .milliseconds(350))
					guard !Task.isCancelled else { return }
					settledSlotState = slotState
				}
			}
		}
	}

	private var roomList: some View {
		VStack(spacing: 0) {
			ForEach(availableRooms) { room in
				Button {
					selectedRoomId = room.id
				} label: {
					HStack(spacing: 12) {
						roomIcon(room.id)
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
			.navigationBarTitleDisplayMode(.inline)
			.animation(.easeInOut(duration: 0.25), value: myBookings)
		}
	}

	private var bookingList: some View {
		VStack(alignment: .leading, spacing: 20) {
			ForEach(bookingDays, id: \.day) { section in
				VStack(alignment: .leading, spacing: 8) {
					Text(section.title)
						.font(.footnote.weight(.semibold))
						.foregroundStyle(.secondary)
						.padding(.leading, 4)

					VStack(spacing: 0) {
						ForEach(section.bookings) { booking in
							bookingRow(booking)

							if booking.id != section.bookings.last?.id {
								Divider().padding(.leading, 48)
							}
						}
					}
					.padding(.horizontal, 16)
					.padding(.vertical, 6)
					.background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
				}
			}
		}
	}

	private func bookingRow(_ booking: Reservation) -> some View {
		Button {
			selectedDate = booking.startTime
			selectedRoomId = booking.roomId
		} label: {
			HStack(spacing: 12) {
				roomIcon(booking.roomId)
				VStack(alignment: .leading, spacing: 2) {
					Text(booking.title.isEmpty ? roomName(booking.roomId) : booking.title)
						.fontWeight(.semibold)
					statusLabel(booking)
				}
				Spacer()
				Text("\(booking.startTime.toPickerString()) – \(booking.endTime.toPickerString())")
					.font(.subheadline)
					.foregroundStyle(.secondary)
				Image(systemName: "chevron.right")
					.font(.footnote.weight(.semibold))
					.foregroundStyle(.tertiary)
			}
			.padding(.vertical, 10)
			.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
	}

	// MARK: - Shared bits

	private func roomName(_ roomId: String) -> String {
		reservationService.rooms.first(where: { $0.id == roomId })?.name ?? roomId
	}

	// Status reads as a colored word under the room name (design: Abu).
	// One vocabulary across app and admin panel: Booked / Checked-In /
	// Released / Cancelled — a no-show shows as Released (the outcome).
	private func statusLabel(_ booking: Reservation) -> some View {
		let (label, color): (String, Color) = switch booking.status {
		case "booked" where booking.checkInStatus == "checked_in": ("Checked-In", .green)
		case "booked": ("Booked", .blue)
		case "released", "no_show": ("Released", .orange)
		case "cancelled": ("Cancelled", .red)
		default: (booking.status.capitalized, .secondary)
		}
		return Text(label)
			.font(.subheadline)
			.foregroundStyle(color)
	}

	// Icon states what's in the room: a TV for Zoom rooms, SharePlay for the
	// plain ones (design: Abu).
	private func roomIcon(_ roomId: String) -> some View {
		let isZoom = reservationService.rooms.first(where: { $0.id == roomId })?.isZoomRoom ?? false
		return rowIcon(isZoom ? "tv" : "shareplay", tint: Color(uiColor: .systemBlue))
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

// Two calendar weeks (today's and the next), closed days greyed — the month
// DatePicker can't disable weekends, so the jump popover draws its own grid.
private struct JumpWeeksView: View {
	let selectedDate: Date
	let onPick: (Date) -> Void

	private let calendar = Calendar.current

	private var weeks: [[Date]] {
		let today = calendar.startOfDay(for: .now)
		let last = TimelineUtilities.lastSelectableDay()
		guard let firstWeek = calendar.dateInterval(of: .weekOfYear, for: today) else { return [] }
		var result: [[Date]] = []
		var weekStart = firstWeek.start
		while weekStart <= last {
			result.append((0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) })
			weekStart = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? last.addingTimeInterval(1)
		}
		return result
	}

	var body: some View {
		let today = calendar.startOfDay(for: .now)
		let last = TimelineUtilities.lastSelectableDay()

		VStack(spacing: 10) {
			HStack(spacing: 0) {
				ForEach(weeks.first ?? [], id: \.self) { day in
					Text(day.formatted(.dateTime.weekday(.narrow)))
						.font(.footnote)
						.foregroundStyle(.secondary)
						.frame(maxWidth: .infinity)
				}
			}

			ForEach(weeks, id: \.first) { week in
				HStack(spacing: 0) {
					ForEach(week, id: \.self) { day in
						let isClosed = calendar.isDateInWeekend(day) || day < today || day > last
						let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)

						Button {
							onPick(day)
						} label: {
							Text(day.formatted(.dateTime.day()))
								.font(.title3)
								.frame(width: 40, height: 40)
								.background {
									if isSelected {
										Circle().fill(Color.blue)
									}
								}
								.foregroundStyle(isSelected ? .white : isClosed ? Color(uiColor: .tertiaryLabel) : .primary)
						}
						.buttonStyle(.plain)
						.disabled(isClosed)
						.frame(maxWidth: .infinity)
					}
				}
			}
		}
		.frame(width: 308)
	}
}

#Preview {
	@Previewable @State var selectedDate: Date = .now
	@Previewable @State var selectedIndex: Int? = nil
	@Previewable @State var tab: HomeTab = .rooms

	let service = ReservationService()
	service.rooms = [
		Room(id: "ws-petang", name: "Petang", capacity: 6),
		Room(id: "ws-mengwi", name: "Mengwi", capacity: 2),
		Room(id: "ws-bedugul", name: "Bedugul", capacity: 2),
	]

	return HomeView(
		selectedDate: $selectedDate,
		selectedIndex: $selectedIndex,
		tab: $tab
	)
	.environment(service)
}
