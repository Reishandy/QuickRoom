//
//  NotificationPermissionService.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 02/07/26.
//

import UserNotifications
import Observation

@Observable
@MainActor
final class NotificationPermissionService {
	private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
	private(set) var timeSensitiveSetting: UNNotificationSetting = .notSupported
	
	init() {
		Task { await checkStatus() }
	}
	
	var isFullyAuthorized: Bool {
		isAuthorized && isTimeSensitiveEnabled
	}
	
	var isTimeSensitiveEnabled: Bool {
		timeSensitiveSetting == .enabled
	}
	
	var isAuthorized: Bool {
		authorizationStatus == .authorized || authorizationStatus == .provisional
	}
	
	var isNotDetermined: Bool {
		authorizationStatus == .notDetermined
	}
	
	func checkStatus() async {
		let settings = await UNUserNotificationCenter.current().notificationSettings()
		
		self.authorizationStatus = settings.authorizationStatus
		self.timeSensitiveSetting = settings.timeSensitiveSetting
	}
	
	func requestPermission() async {
		guard authorizationStatus == .notDetermined else { return }
	
		let options: UNAuthorizationOptions = [.alert, .sound, .badge]
		
		do {
			try await UNUserNotificationCenter.current().requestAuthorization(options: options)
		} catch {
			print("Failed to request notification permission: \(error.localizedDescription)")
		}
		
		await checkStatus()
	}
}
