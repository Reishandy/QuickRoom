//
//  BeaconMonitoringService.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 04/07/26.
//

import Foundation
import CoreLocation
import Observation
import UIKit

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

		// Region callbacks only fire on boundary crossings, so a phone that is
		// already inside (relaunch, beacon power-cycle, backend restart) never
		// re-reports on its own. Reconcile the real state on every foreground.
		NotificationCenter.default.addObserver(
			forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main
		) { [weak self] _ in
			self?.requestStateSync()
		}
	}

	private func monitoredBeaconRegion() -> CLBeaconRegion? {
		locationManager.monitoredRegions
			.compactMap { $0 as? CLBeaconRegion }
			.first { $0.uuid == targetUUID }
	}

	private func requestStateSync() {
		guard let region = monitoredBeaconRegion() else { return }
		locationManager.requestState(for: region)
	}

	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
			startMonitoring()
		}
	}

	private func startMonitoring() {
		if monitoredBeaconRegion() != nil {
			requestStateSync() // already monitoring — still reconcile the state
			return
		}

		let constraint = CLBeaconIdentityConstraint(uuid: targetUUID)
		let region = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: targetUUID.uuidString)

		region.notifyOnEntry = true
		region.notifyOnExit = true

		locationManager.startMonitoring(for: region)
		locationManager.requestState(for: region)
	}

	private func beginRangingBurst(_ manager: CLLocationManager, uuid: UUID) {
		guard !isRanging else { return } // didEnterRegion and didDetermineState can both fire
		let constraint = CLBeaconIdentityConstraint(uuid: uuid)
		isRanging = true
		manager.startRangingBeacons(satisfying: constraint)

		DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
			manager.stopRangingBeacons(satisfying: constraint)
			self?.isRanging = false
		}
	}

	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		guard let beaconRegion = region as? CLBeaconRegion else { return }
		beginRangingBurst(manager, uuid: beaconRegion.uuid)
	}

	// Fires after requestState(for:) and on OS-initiated state re-evaluations —
	// the only path that reports presence when we were inside all along.
	func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
		guard let beaconRegion = region as? CLBeaconRegion else { return }
		switch state {
		case .inside:
			beginRangingBurst(manager, uuid: beaconRegion.uuid)
		case .outside:
			// Definitively outside every room: scrub server-side presence,
			// even if a lost exit made us forget which room we were in.
			Task { await presenceReporter.reportAbsent() }
		default:
			break
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
