//
//  StaticRooms.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import SwiftUI

struct StaticRooms {
	static let rooms: [Room] = [
		Room(name: "Room A", isDisabled: false, relativePoints: [
			CGPoint(x: 0.04, y: 0.09), CGPoint(x: 0.28, y: 0.09),
			CGPoint(x: 0.28, y: 0.79), CGPoint(x: 0.04, y: 0.79)
		]),
		
		Room(name: "Room B", isDisabled: false, relativePoints: [
			CGPoint(x: 0.33, y: 0.08), CGPoint(x: 0.46, y: 0.08),
			CGPoint(x: 0.46, y: 0.32), CGPoint(x: 0.33, y: 0.32)
		]),
		Room(name: "Room C", isDisabled: false, relativePoints: [
			CGPoint(x: 0.47, y: 0.08), CGPoint(x: 0.59, y: 0.08),
			CGPoint(x: 0.59, y: 0.32), CGPoint(x: 0.47, y: 0.32)
		]),
		Room(name: "Room D", isDisabled: false, relativePoints: [
			CGPoint(x: 0.60, y: 0.08), CGPoint(x: 0.72, y: 0.08),
			CGPoint(x: 0.72, y: 0.32), CGPoint(x: 0.60, y: 0.32)
		]),
		Room(name: "Room E", isDisabled: false, relativePoints: [
			CGPoint(x: 0.73, y: 0.08), CGPoint(x: 0.86, y: 0.08),
			CGPoint(x: 0.86, y: 0.32), CGPoint(x: 0.73, y: 0.32)
		]),
		
		Room(name: "Room F", isDisabled: false, relativePoints: [
			CGPoint(x: 0.29, y: 0.55), CGPoint(x: 0.42, y: 0.55),
			CGPoint(x: 0.42, y: 0.83), CGPoint(x: 0.29, y: 0.83)
		]),
		Room(name: "Room G", isDisabled: false, relativePoints: [
			CGPoint(x: 0.42, y: 0.55), CGPoint(x: 0.56, y: 0.55),
			CGPoint(x: 0.56, y: 0.83), CGPoint(x: 0.42, y: 0.83)
		]),
		Room(name: "Room H", isDisabled: false, relativePoints: [
			CGPoint(x: 0.56, y: 0.55), CGPoint(x: 0.72, y: 0.55),
			CGPoint(x: 0.72, y: 0.83), CGPoint(x: 0.56, y: 0.83)
		]),
		
		Room(name: "Room I", isDisabled: false, relativePoints: [
			CGPoint(x: 0.77, y: 0.44), CGPoint(x: 0.97, y: 0.44),
			CGPoint(x: 0.97, y: 0.57), CGPoint(x: 0.77, y: 0.57)
		]),
		Room(name: "Room J", isDisabled: false, relativePoints: [
			CGPoint(x: 0.77, y: 0.57), CGPoint(x: 0.97, y: 0.57),
			CGPoint(x: 0.97, y: 0.70), CGPoint(x: 0.77, y: 0.70)
		]),
		Room(name: "Room K", isDisabled: false, relativePoints: [
			CGPoint(x: 0.77, y: 0.70), CGPoint(x: 0.97, y: 0.70),
			CGPoint(x: 0.97, y: 0.83), CGPoint(x: 0.77, y: 0.83)
		])
	]
}
