//
//  BeaconMonitoringService.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 04/07/26.
//

import Foundation
import CoreLocation
import Observation

@Observable
final class BeaconMonitoringService: NSObject, CLLocationManagerDelegate {
	static let shared = BeaconMonitoringService()

	private let locationManager = CLLocationManager()
	private var isRanging = false
	private let targetUUID = AppConfig.Beacon.proximityUUID
	private let presenceReporter = PresenceReporter()

	private override init() {
		super.init()
		locationManager.delegate = self
		locationManager.allowsBackgroundLocationUpdates = true

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

		let constraint = CLBeaconIdentityConstraint(uuid: beaconRegion.uuid)
		isRanging = true
		manager.startRangingBeacons(satisfying: constraint)

		DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
			manager.stopRangingBeacons(satisfying: constraint)
			self?.isRanging = false
		}
	}

	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		guard region is CLBeaconRegion else { return }

		Task {
			await presenceReporter.reportExit()
		}
	}

	func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
		guard isRanging, let closestBeacon = beacons.first else { return }

		isRanging = false
		manager.stopRangingBeacons(satisfying: beaconConstraint)

		let major = closestBeacon.major.intValue
		let minor = closestBeacon.minor.intValue
		Task {
			await presenceReporter.reportEnter(major: major, minor: minor)
		}
	}
}
