//
//  DateInterval.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import Foundation

extension DateInterval {
	/// Formats a reservation slot into "Today at 16:33 - 19:22" or "3 July at 10:00 - 10:10"
	func toReservationString(locale: Locale = .current) -> String {
		let calendar = Calendar.current
		
		let timeFormatter = DateFormatter()
		timeFormatter.locale = locale
		timeFormatter.dateFormat = "HH:mm"
		
		let startStr = timeFormatter.string(from: self.start)
		let endStr = timeFormatter.string(from: self.end)
		let timeRangeStr = "\(startStr) - \(endStr)"
		
		if calendar.isDateInToday(self.start) {
			return String(localized: "Today at \(timeRangeStr)")
		} else if calendar.isDateInTomorrow(self.start) {
			return String(localized: "Tomorrow at \(timeRangeStr)")
		} else {
			let dateFormatter = DateFormatter()
			dateFormatter.locale = locale
			dateFormatter.dateFormat = "d MMMM"
			let dateStr = dateFormatter.string(from: self.start)
			
			return String(localized: "\(dateStr) at \(timeRangeStr)")
		}
	}
}
