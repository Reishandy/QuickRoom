//
//  TimelineUtilities.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import Foundation

struct TimelineUtilities {
	/// Last bookable day — Friday of next week. The scrubber, the booking
	/// sheet's day strip and the jump calendar all end there ("upcoming two
	/// weeks", weekends being closed anyway).
	static func lastSelectableDay(from date: Date = .now) -> Date {
		let calendar = Calendar.current
		let day = calendar.startOfDay(for: date)
		let weekday = calendar.component(.weekday, from: day) // Sun=1 ... Fri=6
		let daysToFriday = (6 - weekday + 7) % 7
		return calendar.date(byAdding: .day, value: daysToFriday + 7, to: day) ?? day
	}

	static func generateTicks(anchorDate: Date) -> [TimelineTick] {
		var generatedTicks: [TimelineTick] = []

		let startDate = Calendar.current.date(byAdding: .day, value: -AppConfig.Timeline.lookbehindDays, to: anchorDate) ?? anchorDate
		// Ruler ends with next Friday's closing tick — no trailing weekend.
		let endDate = workingHoursEnd(for: lastSelectableDay(from: anchorDate))
		
		var currentDate = startDate
		var id = 0
		let calendar = Calendar.current
		
		let workingHourStart = AppConfig.WorkingHours.start
		let workingHourEnd = AppConfig.WorkingHours.end
		
		while currentDate <= endDate {
			let weekday = calendar.component(.weekday, from: currentDate)
			let hour = calendar.component(.hour, from: currentDate)
			let minute = calendar.component(.minute, from: currentDate)
			
			let isWeekday = calendar.isWeekday(currentDate)
			let isExactWorkStart = isWeekday && (hour == workingHourStart && minute == 0)
			let isExactWorkEnd = isWeekday && (hour == workingHourEnd && minute == 0)
			
			let isFridayOff = (weekday == 6 && (hour > workingHourEnd || (hour == workingHourEnd && minute > 0)))
			let isSaturday = (weekday == 7)
			let isSunday = (weekday == 1)
			let isMondayOff = (weekday == 2 && hour < workingHourStart)
			
			let isWeekendOffTime = isFridayOff || isSaturday || isSunday || isMondayOff
			
			let isWeekdayOffTime = !isWeekendOffTime && !calendar.isWithinWorkingHours(currentDate) && !isExactWorkStart && !isExactWorkEnd
			
			let tickType: TickType
			var incrementMinutes: Int
			
			if isExactWorkStart || isExactWorkEnd || (!isWeekdayOffTime && !isWeekendOffTime && minute == 0) {
				tickType = .normalHour
				if isExactWorkEnd {
					incrementMinutes = (weekday == 6) ? 180 : 60
				} else {
					incrementMinutes = AppConfig.Timeline.tickStepMinutes
				}
			} else if isWeekendOffTime {
				tickType = .weekend
				incrementMinutes = 180
			} else if isWeekdayOffTime {
				tickType = .offHour
				incrementMinutes = 60
			} else {
				tickType = .normalMinute
				incrementMinutes = AppConfig.Timeline.tickStepMinutes
			}
			
			var tick = TimelineTick(id: id, date: currentDate, hour: hour, type: tickType)
			// Day boundaries are the scrubber's real separators (mentor
			// feedback: separate days, not hours) — each weekday's
			// work-start tick carries the day label.
			tick.isDayStart = isExactWorkStart
			generatedTicks.append(tick)
			id += 1
			
			var nextDate = calendar.date(byAdding: .minute, value: incrementMinutes, to: currentDate)!
			
			if let targetStart = calendar.date(bySettingHour: workingHourStart, minute: 0, second: 0, of: nextDate) {
				if currentDate < targetStart && nextDate > targetStart {
					if calendar.isWeekday(targetStart) {
						nextDate = targetStart
					}
				}
			}
			
			currentDate = nextDate
		}
		
		var i = 0
		while i < generatedTicks.count {
			let type = generatedTicks[i].type
			if type == .offHour || type == .weekend {
				var j = i
				while j < generatedTicks.count && generatedTicks[j].type == type {
					j += 1
				}
				
				let midIndex = i + (j - 1 - i) / 2
				generatedTicks[midIndex].isLabelTick = true
				i = j
			} else {
				i += 1
			}
		}
		
		return generatedTicks
	}
	
	// MARK: - For VerticalTimelineView

	/// The current minute with seconds dropped — the earliest allowed start
	/// when booking "from now" (a room free at 15:12 books at 15:12, not 15:15).
	static func bookableNow(_ now: Date = .now) -> Date {
		let calendar = Calendar.current
		let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
		return calendar.date(from: components) ?? now
	}

	/// Snaps a given date to the nearest 15-minute interval
	static func snapToTimeStep(_ date: Date) -> Date {
		let calendar = Calendar.current
		var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
		let minute = components.minute ?? 0
		
		let step = AppConfig.Reservation.timeStepMinutes
		let remainder = minute % step
		
		if remainder < (step / 2) {
			components.minute = minute - remainder
		} else {
			components.minute = minute + (step - remainder)
		}
		components.second = 0
		components.nanosecond = 0
		
		// Calendar automatically handles minute overflow (e.g., minute 60 becomes +1 hour)
		return calendar.date(from: components) ?? date
	}
	
	static func workingHoursStart(for date: Date) -> Date {
		let midnight = Calendar.current.startOfDay(for: date)
		return Calendar.current.date(bySettingHour: AppConfig.WorkingHours.start, minute: 0, second: 0, of: midnight) ?? date
	}
	
	static func workingHoursEnd(for date: Date) -> Date {
		let midnight = Calendar.current.startOfDay(for: date)
		return Calendar.current.date(bySettingHour: AppConfig.WorkingHours.end, minute: 0, second: 0, of: midnight) ?? date
	}
	
	/// Returns 00:00 for the given date
	static func midnight(for date: Date) -> Date {
		Calendar.current.startOfDay(for: date)
	}
	
	/// Calculates Y position from Midnight (00:00) instead of the start of the workday
	static func yPosition(for time: Date, baseDate: Date, hourHeight: CGFloat) -> CGFloat {
		let start = midnight(for: baseDate)
		let diff = time.timeIntervalSince(start)
		return CGFloat(diff / 3600.0) * hourHeight
	}
	
	/// Calculates Date from a Y position based on Midnight (00:00)
	static func date(for yPosition: CGFloat, baseDate: Date, hourHeight: CGFloat) -> Date {
		let start = midnight(for: baseDate)
		let hours = yPosition / hourHeight
		return start.addingTimeInterval(TimeInterval(hours * 3600.0))
	}
	
	static func isOverlapping(start: Date, end: Date, reservations: [Reservation]) -> Bool {
		for res in reservations {
			// Checks if the proposed time range intersects with an existing reservation
			if start < res.endTime && end > res.startTime {
				return true
			}
		}
		return false
	}
	
	/// Scans the day for the next free 15-minute slot that doesn't overlap with existing reservations
	static func findNextAvailableSlot(on date: Date, duration: TimeInterval = AppConfig.Reservation.minDuration, reservations: [Reservation]) -> (start: Date, end: Date)? {
		let now = Date()
		let workingStart = workingHoursStart(for: date)
		let workingEnd = workingHoursEnd(for: date)
		let isToday = Calendar.current.isDate(date, inSameDayAs: now)
		
		if !isToday && date < now { return nil }
		
		// Today's first candidate is "now" itself, not the next grid slot.
		var currentStart = isToday ? max(bookableNow(now), workingStart) : snapToTimeStep(workingStart)
		
		while currentStart.addingTimeInterval(duration) <= workingEnd {
			let currentEnd = currentStart.addingTimeInterval(duration)
			if !isOverlapping(start: currentStart, end: currentEnd, reservations: reservations) {
				return (currentStart, currentEnd)
			}
			currentStart = currentStart.addingTimeInterval(AppConfig.Reservation.minDuration)
		}
		
		return nil
	}
	
	/// Safely transfers the hour/minute of a time to match the year/month/day of a new base date (Used when changing days via the horizontal picker)
	static func updateDate(_ time: Date, toMatchDayOf baseDate: Date) -> Date {
		let calendar = Calendar.current
		let baseComponents = calendar.dateComponents([.year, .month, .day], from: baseDate)
		let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
		
		var newComponents = DateComponents()
		newComponents.year = baseComponents.year
		newComponents.month = baseComponents.month
		newComponents.day = baseComponents.day
		newComponents.hour = timeComponents.hour
		newComponents.minute = timeComponents.minute
		newComponents.second = timeComponents.second
		
		return calendar.date(from: newComponents) ?? time
	}
	
	static func resolveTimeSelection(
		proposedStart: Date,
		proposedEnd: Date,
		selectedDate: Date,
		reservations: [Reservation],
		changedBoundary: TimeBoundary
	) -> (start: Date, end: Date) {
		var start = snapToTimeStep(proposedStart)
		var end = snapToTimeStep(proposedEnd)

		let now = Date()
		let isToday = Calendar.current.isDate(selectedDate, inSameDayAs: now)
		let limitStart = workingHoursStart(for: selectedDate)
		let limitEnd = workingHoursEnd(for: selectedDate)

		// A booking may start at the current minute rather than the next grid
		// slot ("book it from now") — clamping to now is the only way an
		// off-grid start can appear.
		var minValidStart = limitStart
		if isToday {
			let nowFloor = bookableNow(now)
			if nowFloor > limitStart { minValidStart = nowFloor }
			if proposedStart == nowFloor { start = nowFloor }
		}
		
		if start < minValidStart {
			start = minValidStart
		}
		
		if end > limitEnd {
			end = limitEnd
		}
		
		let currentDuration = end.timeIntervalSince(start)
		let minDuration = AppConfig.Reservation.minDuration
		let maxDuration = AppConfig.Reservation.maxDuration
		
		if currentDuration < minDuration {
			if changedBoundary == .start {
				end = start.addingTimeInterval(minDuration)
			} else {
				start = end.addingTimeInterval(-minDuration)
			}
		} else if currentDuration > maxDuration {
			if changedBoundary == .start {
				start = end.addingTimeInterval(-maxDuration)
			} else {
				end = start.addingTimeInterval(maxDuration)
			}
		}
		
		if end > limitEnd {
			end = limitEnd
			start = max(minValidStart, end.addingTimeInterval(-minDuration))
		}
		if start < minValidStart {
			start = minValidStart
			end = min(limitEnd, start.addingTimeInterval(minDuration))
		}
		
		if isOverlapping(start: start, end: end, reservations: reservations) {
			if let safeSlot = findNextAvailableSlot(on: selectedDate, duration: end.timeIntervalSince(start), reservations: reservations) {
				start = safeSlot.start
				end = safeSlot.end
			} else if let minimalSlot = findNextAvailableSlot(on: selectedDate, duration: minDuration, reservations: reservations) {
				start = minimalSlot.start
				end = minimalSlot.end
			}
		}
		
		return (start, end)
	}
}
