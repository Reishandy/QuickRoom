//
//  RoomStatus.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import Foundation

enum RoomStatus {
	case available
	case reserved(isMine: Bool)
	case disabled
}
