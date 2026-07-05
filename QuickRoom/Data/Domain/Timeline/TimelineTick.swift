//
//  TimelineTick.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import Foundation

struct TimelineTick: Identifiable, Hashable {
	let id: Int
	let date: Date
	let hour: Int
	let type: TickType
	var isLabelTick: Bool = false
}
