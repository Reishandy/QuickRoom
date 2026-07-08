//
//  VerticalTimelineView.swift
//  QuickRoom
//

import SwiftUI

struct VerticalTimelineView: View {
	let reservations: [Reservation]
	@Binding var selectedDate: Date
	@Binding var startTime: Date
	@Binding var endTime: Date
	let hasExistingReservation: Bool
	
	private let hourHeight: CGFloat = 80
	private let timeColumnWidth: CGFloat = 52

	// Working hours plus one context hour each side — a midnight-to-6am
	// dead zone is just scrolling for nothing.
	private let displayStartHour = AppConfig.WorkingHours.start - 1
	private let displayEndHour = AppConfig.WorkingHours.end + 1

	/// Y position within the displayed window (not the full day).
	private func y(for date: Date) -> CGFloat {
		TimelineUtilities.yPosition(for: date, baseDate: selectedDate, hourHeight: hourHeight) - CGFloat(displayStartHour) * hourHeight
	}
	
	@State private var dragInitialStart: Date?
	@State private var dragInitialEnd: Date?
	
	private var isToday: Bool {
		Calendar.current.isDate(selectedDate, inSameDayAs: Date())
	}
	
	var body: some View {
		ScrollView {
			ScrollViewReader { proxy in
				ZStack(alignment: .topLeading) {
					VStack(spacing: 0) {
						ForEach(displayStartHour...displayEndHour, id: \.self) { hour in
							HStack(spacing: 8) {
								Text(String(format: "%02d:00", hour == 24 ? 0 : hour))
									.font(.caption)
									.foregroundColor(.secondary)
									.frame(width: 44, alignment: .trailing)
									.offset(y: -7)
								
								Rectangle()
									.fill(Color.gray.opacity(0.3))
									.frame(height: 1)
							}
							.frame(height: hourHeight, alignment: .top)
							.id(hour) // Tagged for auto-scrolling
						}
					}
					.contentShape(Rectangle())
					.onTapGesture { location in
						if hasExistingReservation { return }
						handleTapOnGrid(at: location.y)
					}
					
					let topGreyHeight = CGFloat(AppConfig.WorkingHours.start - displayStartHour) * hourHeight
					if topGreyHeight > 0 {
						Rectangle()
							.fill(Color.gray.opacity(0.1))
							.frame(height: topGreyHeight)
							.offset(x: timeColumnWidth, y: 0)
							.allowsHitTesting(false)
					}
					
					let bottomGreyStart = CGFloat(AppConfig.WorkingHours.end - displayStartHour) * hourHeight
					let bottomGreyHeight = CGFloat(displayEndHour - AppConfig.WorkingHours.end) * hourHeight
					if bottomGreyHeight > 0 {
						Rectangle()
							.fill(Color.gray.opacity(0.1))
							.frame(height: bottomGreyHeight)
							.offset(x: timeColumnWidth, y: bottomGreyStart)
							.allowsHitTesting(false)
					}
					
					if isToday {
						let nowY = y(for: Date())
						if nowY > 0 {
							Rectangle()
								.fill(Color.gray.opacity(0.1))
								.frame(height: nowY)
								.offset(x: timeColumnWidth)
								.allowsHitTesting(false)
						}
					}
					
					ForEach(reservations) { reservation in
						let startY = y(for: reservation.startTime)
						let endY = y(for: reservation.endTime)
						
						let blockTitle = !reservation.title.isEmpty ? reservation.title
							: reservation.isMyReservation ? "My Reservation" : "Reservation"
						
						ReservationBlockView(
							title: blockTitle,
							isMine: reservation.isMyReservation,
							isNew: false,
							height: max(0, endY - startY)
						)
						.offset(x: timeColumnWidth, y: startY)
						.padding(.trailing, 16)
					}
					
					if !hasExistingReservation {
						let startY = y(for: startTime)
						let endY = y(for: endTime)
						
						ZStack {
							ReservationBlockView(
								title: "New Reservation",
								isMine: true,
								isNew: true,
								height: max(0, endY - startY)
							)
							.gesture(centerDragGesture)
							
							VStack(spacing: 0) {
								dragHandle.gesture(topDragGesture)
								Spacer()
								dragHandle.gesture(bottomDragGesture)
							}
						}
						.frame(height: max(0, endY - startY))
						.offset(x: timeColumnWidth, y: startY)
						.padding(.trailing, 16)
						.animation(.spring(response: 0.3, dampingFraction: 0.7), value: startTime)
						.animation(.spring(response: 0.3, dampingFraction: 0.7), value: endTime)
					}
					
					if isToday {
						TimelineView(.everyMinute) { context in
							let nowY = y(for: context.date)
							let totalHeight = CGFloat(displayEndHour - displayStartHour) * hourHeight
							
							if nowY >= 0 && nowY <= totalHeight {
								HStack(spacing: 0) {
									Text(context.date.formatted(date: .omitted, time: .shortened))
										.font(.caption2)
										.fontWeight(.bold)
										.foregroundColor(.red)
										.frame(width: 44, alignment: .trailing)
										.background(Color(UIColor.systemBackground))
										.offset(y: -7)
									
									Circle().fill(Color.red).frame(width: 6, height: 6).offset(x: 4, y: -7)
									Rectangle().fill(Color.red).frame(height: 1).offset(x: 4, y: -7)
								}
								.offset(y: nowY)
								.allowsHitTesting(false)
							}
						}
					}
				}
				.padding(.top, 20)
				.padding(.bottom, 40)
				.onAppear {
					setupInitialTime()
					// Focus the picked slot (or the existing booking), not "now".
					let focus = hasExistingReservation
						? (reservations.first(where: { $0.isMyReservation })?.startTime ?? startTime)
						: startTime
					let focusHour = Calendar.current.component(.hour, from: focus)
					let scrollTarget = min(max(focusHour - 1, displayStartHour), displayEndHour)
					proxy.scrollTo(scrollTarget, anchor: .top)
				}
			}
		}
		.onChange(of: selectedDate) { _, _ in setupInitialTime() }
		.sensoryFeedback(.selection, trigger: startTime)
		.sensoryFeedback(.selection, trigger: endTime)
	}
	
	private func setupInitialTime() {
		if hasExistingReservation { return }

		let calendar = Calendar.current
		let hasTimeOfDay = calendar.component(.hour, from: selectedDate) != 0 || calendar.component(.minute, from: selectedDate) != 0
		var proposedStart = TimelineUtilities.snapToTimeStep(hasTimeOfDay ? selectedDate : TimelineUtilities.updateDate(startTime, toMatchDayOf: selectedDate))
		var proposedEnd = proposedStart.addingTimeInterval(endTime.timeIntervalSince(startTime))
		
		if !isValid(start: proposedStart, end: proposedEnd) {
			// Propose 45 minutes; when the day is fuller, tighten to 30
			// and then 15 minutes.
			if let nextSlot = TimelineUtilities.findNextAvailableSlot(on: selectedDate, duration: AppConfig.Reservation.defaultDuration, reservations: reservations)
				?? TimelineUtilities.findNextAvailableSlot(on: selectedDate, duration: 30 * 60, reservations: reservations)
				?? TimelineUtilities.findNextAvailableSlot(on: selectedDate, reservations: reservations) {
				proposedStart = nextSlot.start
				proposedEnd = nextSlot.end
			}
		}
		
		startTime = proposedStart
		endTime = proposedEnd
	}
	
	private func isValid(start: Date, end: Date) -> Bool {
		let now = Date()
		if isToday && start < TimelineUtilities.bookableNow(now) { return false }
		
		// Still forces the block inside working hours, even though 24 hours are shown
		let limitStart = TimelineUtilities.workingHoursStart(for: selectedDate)
		let limitEnd = TimelineUtilities.workingHoursEnd(for: selectedDate)
		
		if start < limitStart || end > limitEnd { return false }
		
		let duration = end.timeIntervalSince(start)
		if duration < AppConfig.Reservation.minDuration || duration > AppConfig.Reservation.maxDuration { return false }
		
		return !TimelineUtilities.isOverlapping(start: start, end: end, reservations: reservations)
	}
	
	private func handleTapOnGrid(at yPosition: CGFloat) {
		let tappedTime = TimelineUtilities.date(for: yPosition + CGFloat(displayStartHour) * hourHeight, baseDate: selectedDate, hourHeight: hourHeight)
		let snappedTime = TimelineUtilities.snapToTimeStep(tappedTime)
		let duration = endTime.timeIntervalSince(startTime)
		let newEnd = snappedTime.addingTimeInterval(duration)
		
		if isValid(start: snappedTime, end: newEnd) {
			startTime = snappedTime
			endTime = newEnd
		}
	}
	
	private var centerDragGesture: some Gesture {
		DragGesture()
			.onChanged { value in
				if dragInitialStart == nil {
					dragInitialStart = startTime
					dragInitialEnd = endTime
				}
				
				let hoursDelta = value.translation.height / hourHeight
				let newStart = TimelineUtilities.snapToTimeStep(dragInitialStart!.addingTimeInterval(hoursDelta * 3600))
				let duration = dragInitialEnd!.timeIntervalSince(dragInitialStart!)
				let newEnd = newStart.addingTimeInterval(duration)
				
				if isValid(start: newStart, end: newEnd) {
					startTime = newStart
					endTime = newEnd
				}
			}
			.onEnded { _ in clearDragState() }
	}
	
	private var topDragGesture: some Gesture {
		DragGesture()
			.onChanged { value in
				if dragInitialStart == nil { dragInitialStart = startTime }
				
				let hoursDelta = value.translation.height / hourHeight
				let newStart = TimelineUtilities.snapToTimeStep(dragInitialStart!.addingTimeInterval(hoursDelta * 3600))
				
				if isValid(start: newStart, end: endTime) {
					startTime = newStart
				}
			}
			.onEnded { _ in clearDragState() }
	}
	
	private var bottomDragGesture: some Gesture {
		DragGesture()
			.onChanged { value in
				if dragInitialEnd == nil { dragInitialEnd = endTime }
				
				let hoursDelta = value.translation.height / hourHeight
				let newEnd = TimelineUtilities.snapToTimeStep(dragInitialEnd!.addingTimeInterval(hoursDelta * 3600))
				
				if isValid(start: startTime, end: newEnd) {
					endTime = newEnd
				}
			}
			.onEnded { _ in clearDragState() }
	}
	
	private func clearDragState() {
		dragInitialStart = nil
		dragInitialEnd = nil
	}
	
	private var dragHandle: some View {
		Rectangle()
			.fill(.white.opacity(0.01))
			.frame(height: 20)
			.overlay {
				Capsule()
					.fill(Color.white)
					.frame(width: 30, height: 4)
					.overlay(
						Capsule().stroke(Color.gray.opacity(0.4), lineWidth: 0.5)
					)
					.shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
			}
	}
}

private struct ReservationBlockView: View {
	let title: String
	let isMine: Bool
	let isNew: Bool
	let height: CGFloat
	
	var body: some View {
		let themeColor: Color = isMine ? .blue : .red
		
		HStack(spacing: 0) {
			Rectangle()
				.fill(themeColor)
				.frame(width: AppConfig.Timeline.tickWidth)
			
			ZStack(alignment: .topLeading) {
				Rectangle()
					.fill(isNew ? themeColor : themeColor.opacity(0.2))
				
				Text(title)
					.font(.caption)
					.fontWeight(.semibold)
					.foregroundColor(isNew ? .white : themeColor)
					.padding(.horizontal, 6)
					.padding(.vertical, 4)
			}
		}
		.frame(height: height)
		.cornerRadius(4)
	}
}
