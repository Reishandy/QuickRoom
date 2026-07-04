//
//  AppDelegate.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 04/07/26.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
	func application(_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		
		_ = BeaconMonitoringService.shared
		
		return true
	}
}
