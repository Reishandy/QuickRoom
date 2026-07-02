//
//  LocationPermissionService.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 02/07/26.
//

import CoreLocation
import Observation

@Observable
@MainActor
public final class LocationPermissionService: NSObject, CLLocationManagerDelegate {
	private let locationManager = CLLocationManager()
	
	public private(set) var authorizationStatus: CLAuthorizationStatus
	private var authContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
	
	public override init() {
		self.authorizationStatus = locationManager.authorizationStatus
		super.init()
		self.locationManager.delegate = self
	}
	
	public var isFullyAuthorized: Bool {
		authorizationStatus == .authorizedAlways
	}
	
	public var isNotDetermined: Bool {
		authorizationStatus == .notDetermined
	}
	
	public func requestAlways() async {
		guard authorizationStatus != .authorizedAlways else { return }
		if authorizationStatus == .notDetermined {
			await requestWhenInUse()
		}
		
		guard authorizationStatus == .authorizedWhenInUse else { return }
		guard authContinuation == nil else { return }
		
		let _ = await withCheckedContinuation { continuation in
			self.authContinuation = continuation
			self.locationManager.requestAlwaysAuthorization()
		}
	}
	
	private func requestWhenInUse() async {
		guard authorizationStatus == .notDetermined else { return }
		guard authContinuation == nil else { return }
		
		let _ = await withCheckedContinuation { continuation in
			self.authContinuation = continuation
			self.locationManager.requestWhenInUseAuthorization()
		}
	}
	
	public nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		Task { @MainActor in
			self.authorizationStatus = manager.authorizationStatus
			
			if let continuation = self.authContinuation {
				self.authContinuation = nil
				continuation.resume(returning: manager.authorizationStatus)
			}
		}
	}
}
