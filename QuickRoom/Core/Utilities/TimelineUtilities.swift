//
//  TimelineUtilities.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import Foundation

struct TimelineUtilities {
	static func generateTicks(anchorDate: Date) -> [TimelineTick] {
		var generatedTicks: [TimelineTick] = []
		
		let startDate = Calendar.current.date(byAdding: .day, value: -AppConfig.Timeline.lookbehindDays, to: anchorDate) ?? anchorDate
		let endDate = Calendar.current.date(byAdding: .day, value: AppConfig.Timeline.lookaheadDays, to: anchorDate) ?? anchorDate
		
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
					incrementMinutes = 10
				}
			} else if isWeekendOffTime {
				tickType = .weekend
				incrementMinutes = 180
			} else if isWeekdayOffTime {
				tickType = .offHour
				incrementMinutes = 60
			} else {
				tickType = .normalMinute
				incrementMinutes = 10
			}
			
			generatedTicks.append(TimelineTick(id: id, date: currentDate, hour: hour, type: tickType))
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
}
