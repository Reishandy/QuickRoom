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

	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		Task {
			await PushRegistrar.shared.handleToken(deviceToken)
		}
	}

	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		print("PushRegistrar: APNs registration failed: \(error)")
	}
}
