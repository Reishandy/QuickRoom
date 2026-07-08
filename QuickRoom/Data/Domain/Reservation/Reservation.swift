//
//  Reservation.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import Foundation

struct Reservation: Identifiable, Hashable {
	let id: String
	let roomId: String
	let isMyReservation: Bool
	let status: String
	var checkInStatus: String = "not_checked_in"
	let title: String
	let startTime: Date
	let endTime: Date
}
