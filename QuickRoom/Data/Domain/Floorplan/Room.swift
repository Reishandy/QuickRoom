//
//  Room.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import Foundation

struct Room: Identifiable {
	let id = UUID()
	let name: String
	let isDisabled: Bool
	let relativePoints: [CGPoint]
}
