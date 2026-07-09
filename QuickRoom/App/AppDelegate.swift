//
//  AppDelegate.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 04/07/26.
//

import UIKit
import UserNotifications

extension Notification.Name {
	/// Fired when a push arrives (foreground) or is tapped — server state
	/// changed, so listeners refetch instead of waiting for the next poll.
	static let quickRoomPushReceived = Notification.Name("quickRoomPushReceived")
}

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
		NotificationCenter.default.post(name: .quickRoomPushReceived, object: nil)
		return [.banner, .list, .sound]
	}

	// A tapped notification opens the app on data the push was about —
	// refetch immediately rather than waiting for the poll.
	func userNotificationCenter(_ center: UNUserNotificationCenter,
		didReceive response: UNNotificationResponse) async {
		NotificationCenter.default.post(name: .quickRoomPushReceived, object: nil)
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
