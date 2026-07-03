//
//  ReservationService.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import Foundation
import SwiftUI

@Observable
class ReservationService {
	var rooms: [Room] = []
	var reservations: [Reservation] = []
	var isLoading: Bool = false
	
	init() {
		self.rooms = StaticRooms.rooms
		generateInitialMockData()
	}
	
	// TODO: Replace with network
	// TODO: Reservation rule
	func fetchReservationsOnLoad() async throws {
		isLoading = true
		defer { isLoading = false }
		
		// Simulate a 1.5-second network delay
		try await Task.sleep(nanoseconds: 1_500_000_000)
	}
	
	func reserve(roomId: String, startTime: Date, endTime: Date) async throws {
		try await Task.sleep(nanoseconds: 1_000_000_000)
		
		let newReservation = Reservation(
			id: UUID().uuidString,
			roomId: roomId,
			isMyReservation: true,
			startTime: startTime,
			endTime: endTime
		)
		
		reservations.append(newReservation)
	}
	
	func cancelReservation(reservationId: String) async throws {
		try await Task.sleep(nanoseconds: 1_000_000_000)
		
		reservations.removeAll { $0.id == reservationId }
	}
	
	func status(for room: Room, at time: Date) -> RoomStatus {
		let calendar = Calendar.current
		let weekday = calendar.component(.weekday, from: time)
		let hour = calendar.component(.hour, from: time)
		let minute = calendar.component(.minute, from: time)
		
		let isWeekend = (weekday == 1 || weekday == 7)
		let isOffHour = hour < 7 || hour > 19 || (hour == 19 && minute > 0)
		
		if isWeekend || isOffHour {
			return .disabled
		}
		
		let activeReservation = reservations.first { reservation in
			reservation.roomId == room.id && time >= reservation.startTime && time < reservation.endTime
		}
		
		if let reservation = activeReservation {
			return .reserved(isMine: reservation.isMyReservation)
		}
		
		return .available
	}
	
	// TODO: Remove
	private func generateInitialMockData() {
		var generatedReservations: [Reservation] = []
		let calendar = Calendar.current
		let now = Date()
		
		// Generate schedule for today + the next 6 days
		for dayOffset in 0..<7 {
			guard let currentDate = calendar.date(byAdding: .day, value: dayOffset, to: now) else { continue }
			
			for room in self.rooms {
				// Simulate a busy environment: 3 to 6 meetings per room, per day
				let meetingsCount = Int.random(in: 3...6)
				
				// Start the scheduling day around 7:00 AM
				var currentStartHour = 7
				
				for _ in 0..<meetingsCount {
					// Add a random gap between meetings (0 to 2 hours)
					currentStartHour += Int.random(in: 0...2)
					
					// Stop scheduling if we hit 7:00 PM (19:00)
					if currentStartHour >= 19 { break }
					
					// Randomize meeting duration (30, 60, 90, or 120 minutes)
					let durationOptions = [30, 60, 90, 120]
					let duration = durationOptions.randomElement() ?? 60
					let randomMinuteStart = [0, 15, 30, 45].randomElement()!
					
					if let startTime = calendar.date(bySettingHour: currentStartHour, minute: randomMinuteStart, second: 0, of: currentDate),
					   let endTime = calendar.date(byAdding: .minute, value: duration, to: startTime) {
						
						let reservation = Reservation(
							id: UUID().uuidString,
							roomId: room.id,
							isMyReservation: false,
							startTime: startTime,
							endTime: endTime
						)
						
						generatedReservations.append(reservation)
					}
					
					// Advance the hour tracker so the next meeting doesn't overlap
					currentStartHour += (duration / 60) + 1
				}
			}
		}
		
		self.reservations = generatedReservations
	}
}
