//
//  Date.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import Foundation

extension Date {
	/// Formats a date into "3 July at 15:40"
	func toHomeString(locale: Locale = .current) -> String {
		let formatter = DateFormatter()
		formatter.locale = locale
		formatter.dateFormat = "d MMMM 'at' HH:mm"
		return formatter.string(from: self)
	}
	
	/// Formats a date into "Friday, 21 July 2023"
	func toReservationString(locale: Locale = .current) -> String {
		let formatter = DateFormatter()
		formatter.locale = locale
		formatter.dateFormat = "EEEE, d MMMM yyyy"
		return formatter.string(from: self)
	}
	
	/// Formats a date into "Wed 9" for scrubber day separators
	func toDayLabel(locale: Locale = .current) -> String {
		let formatter = DateFormatter()
		formatter.locale = locale
		formatter.dateFormat = "EEE d"
		return formatter.string(from: self)
	}

	/// Formats a date into "09.30"
	func toPickerString(locale: Locale = .current) -> String {
		let formatter = DateFormatter()
		formatter.locale = locale
		formatter.dateFormat = "HH.mm"
		return formatter.string(from: self)
	}
}
