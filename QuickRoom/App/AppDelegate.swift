//
//  AppDelegate.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 04/07/26.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
	func application(_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

		_ = BeaconMonitoringService.shared
		UNUserNotificationCenter.current().delegate = self

		return true
	}

	// Without this, iOS delivers pushes silently while the app is open — the
	// booker watching the app after booking never saw "Are you coming?".
	func userNotificationCenter(_ center: UNUserNotificationCenter,
		willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
		[.banner, .list, .sound]
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
