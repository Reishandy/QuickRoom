//
//  Calendar.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 05/07/26.
//

import Foundation

extension Calendar {
	
	/// Checks if a given date falls on a weekday.
	func isWeekday(_ date: Date) -> Bool {
		let weekday = component(.weekday, from: date)
		return weekday != 1 && weekday != 7
	}
	
	/// Whether the given date falls within configured working hours on a weekday.
	func isWithinWorkingHours(_ date: Date,
							  start: Int = AppConfig.WorkingHours.start,
							  end: Int = AppConfig.WorkingHours.end) -> Bool {
		guard isWeekday(date) else { return false }
		let hour = component(.hour, from: date)
		return hour >= start && hour < end
	}
}
