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
	private let directory = BeaconDirectory.shared

	// Room regions are named "room|<major>|<minor>" so a background region
	// event identifies its room WITHOUT ranging — iOS doesn't range in the
	// background, which is why a burst-based enter only worked with the app
	// open in hand. The UUID-wide region stays as the foreground reconciler
	// and the catch-all for beacons the directory doesn't know yet.
	private static let roomPrefix = "room|"

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
			Task { await self?.syncRoomRegions(refresh: true) }
		}
	}

	private func uuidRegion() -> CLBeaconRegion? {
		locationManager.monitoredRegions
			.compactMap { $0 as? CLBeaconRegion }
			.first { $0.identifier == targetUUID.uuidString }
	}

	private static func roomIdentity(from identifier: String) -> (major: Int, minor: Int)? {
		guard identifier.hasPrefix(roomPrefix) else { return nil }
		let parts = identifier.dropFirst(roomPrefix.count).split(separator: "|")
		guard parts.count == 2, let major = Int(parts[0]), let minor = Int(parts[1]) else { return nil }
		return (major, minor)
	}

	private func requestStateSync() {
		for region in locationManager.monitoredRegions where region is CLBeaconRegion {
			locationManager.requestState(for: region)
		}
	}

	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
			startMonitoring()
		}
	}

	private func startMonitoring() {
		if uuidRegion() == nil {
			let constraint = CLBeaconIdentityConstraint(uuid: targetUUID)
			let region = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: targetUUID.uuidString)
			region.notifyOnEntry = true
			region.notifyOnExit = true
			locationManager.startMonitoring(for: region)
		}
		requestStateSync()
		Task { await syncRoomRegions(refresh: false) }
	}

	/// Registers one region per known room beacon (and drops regions for
	/// beacons that no longer exist). Region events then carry the room
	/// identity, so background enters/exits work with the app closed.
	private func syncRoomRegions(refresh: Bool) async {
		if refresh {
			await directory.refresh()
		}
		let beacons = await directory.allBeacons()
		await MainActor.run {
			let wanted = Dictionary(uniqueKeysWithValues: beacons.map {
				("\(Self.roomPrefix)\($0.major)|\($0.minor)", $0)
			})
			let existing = locationManager.monitoredRegions
				.compactMap { $0 as? CLBeaconRegion }
				.filter { $0.identifier.hasPrefix(Self.roomPrefix) }

			for region in existing where wanted[region.identifier] == nil {
				locationManager.stopMonitoring(for: region)
			}
			let existingIds = Set(existing.map(\.identifier))
			for (id, beacon) in wanted where !existingIds.contains(id) {
				let constraint = CLBeaconIdentityConstraint(
					uuid: targetUUID,
					major: CLBeaconMajorValue(beacon.major),
					minor: CLBeaconMinorValue(beacon.minor)
				)
				let region = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: id)
				region.notifyOnEntry = true
				region.notifyOnExit = true
				locationManager.startMonitoring(for: region)
				locationManager.requestState(for: region)
			}
		}
	}

	private func beginRangingBurst(_ manager: CLLocationManager, uuid: UUID) {
		guard !isRanging else { return } // didEnterRegion and didDetermineState can both fire
		let constraint = CLBeaconIdentityConstraint(uuid: uuid)
		isRanging = true
		manager.startRangingBeacons(satisfying: constraint)

		DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
			guard let self else { return }
			manager.stopRangingBeacons(satisfying: constraint)
			// isRanging still true = the whole burst saw no beacon. In the
			// foreground that's the truth (the region state that triggered us
			// was stale) — scrub server-side presence. In the background iOS
			// doesn't deliver ranging at all, so silence proves nothing.
			let sawNothing = self.isRanging
			self.isRanging = false
			if sawNothing && UIApplication.shared.applicationState == .active {
				Task { await self.presenceReporter.reportAbsent() }
			}
		}
	}

	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		guard let beaconRegion = region as? CLBeaconRegion else { return }
		if let room = Self.roomIdentity(from: region.identifier) {
			// Background-safe: the region itself says which room.
			Task { await presenceReporter.reportEnter(major: room.major, minor: room.minor) }
		} else {
			beginRangingBurst(manager, uuid: beaconRegion.uuid)
		}
	}

	// Fires after requestState(for:) and on OS-initiated state re-evaluations —
	// the only path that reports presence when we were inside all along.
	func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
		guard let beaconRegion = region as? CLBeaconRegion else { return }
		if let room = Self.roomIdentity(from: region.identifier) {
			// Only act on .inside: every OTHER room answers .outside on each
			// sync, and those say nothing about where we actually are.
			if state == .inside {
				Task { await presenceReporter.reportEnter(major: room.major, minor: room.minor) }
			}
			return
		}
		switch state {
		case .inside, .unknown:
			// .inside can be stale after a beacon dies and .unknown decides
			// nothing — either way, a ranging burst settles it: a sighting
			// reports the enter, 3 s of silence (foreground) scrubs presence.
			beginRangingBurst(manager, uuid: beaconRegion.uuid)
		case .outside:
			// Definitively outside every room: scrub server-side presence,
			// even if a lost exit made us forget which room we were in.
			Task { await presenceReporter.reportAbsent() }
		}
	}

	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		guard region is CLBeaconRegion else { return }
		if let room = Self.roomIdentity(from: region.identifier) {
			Task { await presenceReporter.reportExit(major: room.major, minor: room.minor) }
		} else {
			// Left the whole beacon region — we're nowhere.
			Task { await presenceReporter.reportAbsent() }
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
