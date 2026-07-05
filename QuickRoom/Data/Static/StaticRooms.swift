//
//  StaticRooms.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import Foundation

struct StaticRooms {
	// Room ids/names match the backend's workspaces; polygons stay local.
	// The polygon->workspace assignment is size-matched and demo-arbitrary;
	// re-key here if beacons/rooms move. (One former polygon was dropped:
	// 11 shapes, 10 real rooms.)
	static let rooms: [Room] = [
		Room(id: "ws-agung", name: "BINB Agung Zoom", relativePoints: [
			CGPoint(x: 0.04, y: 0.09), CGPoint(x: 0.28, y: 0.09),
			CGPoint(x: 0.28, y: 0.79), CGPoint(x: 0.04, y: 0.79)
		]),

		Room(id: "ws-bedugul", name: "BINB Bedugul Zoom", relativePoints: [
			CGPoint(x: 0.33, y: 0.08), CGPoint(x: 0.46, y: 0.08),
			CGPoint(x: 0.46, y: 0.32), CGPoint(x: 0.33, y: 0.32)
		]),
		Room(id: "ws-mengwi", name: "BINB Mengwi Zoom", relativePoints: [
			CGPoint(x: 0.47, y: 0.08), CGPoint(x: 0.59, y: 0.08),
			CGPoint(x: 0.59, y: 0.32), CGPoint(x: 0.47, y: 0.32)
		]),
		Room(id: "ws-nusadua", name: "BINB Nusa Dua Zoom", relativePoints: [
			CGPoint(x: 0.60, y: 0.08), CGPoint(x: 0.72, y: 0.08),
			CGPoint(x: 0.72, y: 0.32), CGPoint(x: 0.60, y: 0.32)
		]),
		Room(id: "ws-petang", name: "BINB Petang Zoom", relativePoints: [
			CGPoint(x: 0.73, y: 0.08), CGPoint(x: 0.86, y: 0.08),
			CGPoint(x: 0.86, y: 0.32), CGPoint(x: 0.73, y: 0.32)
		]),

		Room(id: "ws-sanur", name: "BINB Sanur Zoom", relativePoints: [
			CGPoint(x: 0.29, y: 0.55), CGPoint(x: 0.42, y: 0.55),
			CGPoint(x: 0.42, y: 0.83), CGPoint(x: 0.29, y: 0.83)
		]),
		Room(id: "ws-ubud", name: "BINB Ubud Zoom", relativePoints: [
			CGPoint(x: 0.42, y: 0.55), CGPoint(x: 0.56, y: 0.55),
			CGPoint(x: 0.56, y: 0.83), CGPoint(x: 0.42, y: 0.83)
		]),
		Room(id: "ws-ceningan", name: "Ceningan", relativePoints: [
			CGPoint(x: 0.56, y: 0.55), CGPoint(x: 0.72, y: 0.55),
			CGPoint(x: 0.72, y: 0.83), CGPoint(x: 0.56, y: 0.83)
		]),

		Room(id: "ws-lembongan", name: "Lembongan", relativePoints: [
			CGPoint(x: 0.77, y: 0.44), CGPoint(x: 0.97, y: 0.44),
			CGPoint(x: 0.97, y: 0.57), CGPoint(x: 0.77, y: 0.57)
		]),
		Room(id: "ws-penida", name: "Penida", relativePoints: [
			CGPoint(x: 0.77, y: 0.57), CGPoint(x: 0.97, y: 0.57),
			CGPoint(x: 0.97, y: 0.70), CGPoint(x: 0.77, y: 0.70)
		])
	]
}
