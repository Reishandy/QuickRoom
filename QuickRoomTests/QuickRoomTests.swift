//
//  QuickRoomTests.swift
//  QuickRoomTests
//
//  Created by Asadullokh Nurullaev on 05/07/26.
//

import XCTest
@testable import QuickRoom

final class SmokeTests: XCTestCase {
	func testHarnessRuns() {
		XCTAssertLessThan(AppConfig.WorkingHours.start, AppConfig.WorkingHours.end)
	}
}
