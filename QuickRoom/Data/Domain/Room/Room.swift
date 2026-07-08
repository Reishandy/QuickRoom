//
//  Room.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import Foundation

struct Room: Identifiable, Hashable {
	let id: String
	let name: String
	let capacity: Int
	var isZoomRoom: Bool = false
}
