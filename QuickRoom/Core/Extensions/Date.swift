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
}
