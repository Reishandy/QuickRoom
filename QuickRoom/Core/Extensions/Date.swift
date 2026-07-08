//
//  Date.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import Foundation

extension Date {
	/// Formats a date into "Friday, 6 May at 15.40"
	func toHomeString(locale: Locale = .current) -> String {
		let formatter = DateFormatter()
		formatter.locale = locale
		formatter.dateFormat = "EEEE, d MMMM 'at' HH.mm"
		return formatter.string(from: self)
	}
	
	/// Formats a date into "Friday, 21 July"
	func toReservationString(locale: Locale = .current) -> String {
		let formatter = DateFormatter()
		formatter.locale = locale
		formatter.dateFormat = "EEEE, d MMMM"
		return formatter.string(from: self)
	}
	
	/// Formats a date into "Wed" for scrubber day separators
	func toDayLabel(locale: Locale = .current) -> String {
		let formatter = DateFormatter()
		formatter.locale = locale
		formatter.dateFormat = "EEE"
		return formatter.string(from: self)
	}

	/// Formats a date into "9.30" (no leading zero, design: Abu)
	func toPickerString(locale: Locale = .current) -> String {
		let formatter = DateFormatter()
		formatter.locale = locale
		formatter.dateFormat = "H.mm"
		return formatter.string(from: self)
	}
}
