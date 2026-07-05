//
//  BeaconMonitoringService.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 04/07/26.
//

import Foundation
import CoreLocation
import Observation
import UserNotifications // TODO: remove

@Observable
final class BeaconMonitoringService: NSObject, CLLocationManagerDelegate, UNUserNotificationCenterDelegate { // TODO: Remove notif
	static let shared = BeaconMonitoringService()
	
	private let locationManager = CLLocationManager()
	private var isRanging = false
	private let targetUUID = AppConfig.Beacon.proximityUUID
	
	private override init() {
		super.init()
		locationManager.delegate = self
		locationManager.allowsBackgroundLocationUpdates = true
		
		// TODO: remove - Force notifications to show in foreground
		UNUserNotificationCenter.current().delegate = self
		
		if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
			startMonitoring()
		}
	}
	
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
			startMonitoring()
		}
	}
	
	private func startMonitoring() {
		let isAlreadyMonitoring = locationManager.monitoredRegions.contains { region in
			guard let beaconRegion = region as? CLBeaconRegion else { return false }
			return beaconRegion.uuid == targetUUID
		}
		
		guard !isAlreadyMonitoring else {
			return
		}
		
		let constraint = CLBeaconIdentityConstraint(uuid: targetUUID)
		let region = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: targetUUID.uuidString)
		
		region.notifyOnEntry = true
		region.notifyOnExit = true
		
		locationManager.startMonitoring(for: region)
	}
	
	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		guard let beaconRegion = region as? CLBeaconRegion else { return }
		
		// TODO: remove
		sendLocalNotification(title: "ENTERED REGION", body: beaconRegion.identifier)
		
		let constraint = CLBeaconIdentityConstraint(uuid: beaconRegion.uuid)
		isRanging = true
		manager.startRangingBeacons(satisfying: constraint)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
			manager.stopRangingBeacons(satisfying: constraint)
			self?.isRanging = false
		}
	}
	
	// TODO: Implement server callback for exit and detect
	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		guard let beaconRegion = region as? CLBeaconRegion else { return }
		
		// TODO: remove
		sendLocalNotification(title: "EXITED REGION", body: beaconRegion.identifier)
	}
	
	func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
		guard isRanging, let closestBeacon = beacons.first else { return }
		
		// TODO: remove
		sendLocalNotification(title: "BEACON DETECTED", body: "Major: \(closestBeacon.major), Minor: \(closestBeacon.minor)")
		
		isRanging = false
		manager.stopRangingBeacons(satisfying: beaconConstraint)
	}
	
	// TODO: remove this entire block
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.banner, .sound])
	}
}


// TODO: remove this entire helper block
private func sendLocalNotification(title: String, body: String) {
	let content = UNMutableNotificationContent()
	content.title = title
	content.body = body
	content.sound = .default
	
	let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
	UNUserNotificationCenter.current().add(request)
}
