//
//  StaticRooms.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import Foundation

struct StaticRooms {
	static let rooms: [Room] = [
		Room(id: "room-a", name: "Room A", relativePoints: [
			CGPoint(x: 0.04, y: 0.09), CGPoint(x: 0.28, y: 0.09),
			CGPoint(x: 0.28, y: 0.79), CGPoint(x: 0.04, y: 0.79)
		]),
		
		Room(id: "room-b", name: "Room B", relativePoints: [
			CGPoint(x: 0.33, y: 0.08), CGPoint(x: 0.46, y: 0.08),
			CGPoint(x: 0.46, y: 0.32), CGPoint(x: 0.33, y: 0.32)
		]),
		Room(id: "room-c", name: "Room C", relativePoints: [
			CGPoint(x: 0.47, y: 0.08), CGPoint(x: 0.59, y: 0.08),
			CGPoint(x: 0.59, y: 0.32), CGPoint(x: 0.47, y: 0.32)
		]),
		Room(id: "room-d", name: "Room D", relativePoints: [
			CGPoint(x: 0.60, y: 0.08), CGPoint(x: 0.72, y: 0.08),
			CGPoint(x: 0.72, y: 0.32), CGPoint(x: 0.60, y: 0.32)
		]),
		Room(id: "room-e", name: "Room E", relativePoints: [
			CGPoint(x: 0.73, y: 0.08), CGPoint(x: 0.86, y: 0.08),
			CGPoint(x: 0.86, y: 0.32), CGPoint(x: 0.73, y: 0.32)
		]),
		
		Room(id: "room-f", name: "Room F", relativePoints: [
			CGPoint(x: 0.29, y: 0.55), CGPoint(x: 0.42, y: 0.55),
			CGPoint(x: 0.42, y: 0.83), CGPoint(x: 0.29, y: 0.83)
		]),
		Room(id: "room-g", name: "Room G", relativePoints: [
			CGPoint(x: 0.42, y: 0.55), CGPoint(x: 0.56, y: 0.55),
			CGPoint(x: 0.56, y: 0.83), CGPoint(x: 0.42, y: 0.83)
		]),
		Room(id: "room-h", name: "Room H", relativePoints: [
			CGPoint(x: 0.56, y: 0.55), CGPoint(x: 0.72, y: 0.55),
			CGPoint(x: 0.72, y: 0.83), CGPoint(x: 0.56, y: 0.83)
		]),
		
		Room(id: "room-i", name: "Room I", relativePoints: [
			CGPoint(x: 0.77, y: 0.44), CGPoint(x: 0.97, y: 0.44),
			CGPoint(x: 0.97, y: 0.57), CGPoint(x: 0.77, y: 0.57)
		]),
		Room(id: "room-j", name: "Room J", relativePoints: [
			CGPoint(x: 0.77, y: 0.57), CGPoint(x: 0.97, y: 0.57),
			CGPoint(x: 0.97, y: 0.70), CGPoint(x: 0.77, y: 0.70)
		]),
		Room(id: "room-k", name: "Room K", relativePoints: [
			CGPoint(x: 0.77, y: 0.70), CGPoint(x: 0.97, y: 0.70),
			CGPoint(x: 0.97, y: 0.83), CGPoint(x: 0.77, y: 0.83)
		])
	]
}
