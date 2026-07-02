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
public final class NotificationPermissionService {
	public private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
	public private(set) var timeSensitiveSetting: UNNotificationSetting = .notSupported
	
	public init() {
		Task { await checkStatus() }
	}
	
	public var isFullyAuthorized: Bool {
		let isAuthorized = (authorizationStatus == .authorized || authorizationStatus == .provisional)
		let isTimeSensitiveEnabled = (timeSensitiveSetting == .enabled)
		
		return isAuthorized && isTimeSensitiveEnabled
	}
	
	public var isNotDetermined: Bool {
		authorizationStatus == .notDetermined
	}
	
	public func checkStatus() async {
		let settings = await UNUserNotificationCenter.current().notificationSettings()
		
		self.authorizationStatus = settings.authorizationStatus
		self.timeSensitiveSetting = settings.timeSensitiveSetting
	}
	
	public func requestPermission() async {
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
