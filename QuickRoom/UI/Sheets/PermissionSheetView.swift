//
//  PermissionSheetView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 02/07/26.
//

import SwiftUI

struct PermissionSheetView: View {
	@Environment(LocationPermissionService.self) private var locationPermissionService
	@Environment(NotificationPermissionService.self) private var notificationPermissionService
	
	private var shouldShowSettingsRedirect: Bool {
		!locationPermissionService.isNotDetermined || !notificationPermissionService.isNotDetermined
	}
	
    var body: some View {
		VStack(spacing: 32) {
			Spacer()
			
			VStack(spacing: 8) {
				Image(systemName: "lock.shield.fill")
					.font(.system(size: 80))
				
				Text("Permission Request")
					.font(.title2)
					.bold()
					.multilineTextAlignment(.center)
				
				Text("We need a few permissions from you to make our app works and helps you manage your resrvations,")
					.foregroundStyle(.secondary)
					.multilineTextAlignment(.center)
			}
			
			
			VStack(spacing: 24) {
				PermissionRowView(
					iconName: "location.fill",
					isGranted: locationPermissionService.isFullyAuthorized,
					title: "Always Allow Location",
					description: "We need your always location access to know when you enter or exit our managed meeting rooms, we do not track your location."
				)
				
				PermissionRowView(
					iconName: "bell.fill",
					isGranted: notificationPermissionService.isAuthorized,
					title: "Allow Notifications",
					description: "We need your notification permission to let you know of upoming reservations, overstay, auto release notifications, and more."
				)
				
				PermissionRowView(
					iconName: "clock.fill",
					isGranted: notificationPermissionService.isTimeSensitiveEnabled,
					title: "Time-Sensitive Alerts",
					description: "We need time sensitive notification support to let you know of important notifications such as auto release and overstay notification when you are focused."
				)
			}
			
			Spacer()
			
			Button {
				if shouldShowSettingsRedirect {
					if let url = URL(string: UIApplication.openSettingsURLString) {
						UIApplication.shared.open(url)
					}
				} else {
					Task {
						if notificationPermissionService.isNotDetermined {
							await notificationPermissionService.requestPermission()
						}
						
						if locationPermissionService.isNotDetermined || !locationPermissionService.isFullyAuthorized {
							await locationPermissionService.requestAlways()
						}
					}
				}
			} label: {
				Text(shouldShowSettingsRedirect ? "Go to settings" : "Grant permissions")
					.padding(.vertical, 6)
					.frame(maxWidth: .infinity)
			}
			.buttonStyle(.borderedProminent)
		}
		.padding(20)
    }
}

struct PermissionRowView: View {
	let iconName: String
	let isGranted: Bool
	let title: String
	let description: String
	
	var body: some View {
		HStack(alignment: .center, spacing: 16) {
			ZStack(alignment: .bottomTrailing) {
				Image(systemName: iconName)
					.font(.system(size: 28))
				
				Image(systemName: isGranted ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
					.font(.system(size: 14))
					.foregroundStyle(isGranted ? .green : .red)
					.background(Circle().fill(Color(UIColor.systemBackground)))
					.offset(x: 2, y: 2)
			}
			.frame(width: 40)
			
			VStack(alignment: .leading, spacing: 4) {
				Text(title)
					.font(.headline)
					.foregroundStyle(.primary)
				
				Text(description)
					.font(.subheadline)
					.foregroundStyle(.secondary)
					.fixedSize(horizontal: false, vertical: true)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
		}
	}
}

#Preview {
	NavigationStack {
		Text("This is supposed to be home")
			.sheet(isPresented: .constant(true)) {
				PermissionSheetView()
					.interactiveDismissDisabled()
					.presentationDetents([.large])
			}
	}
	.environment(LocationPermissionService())
	.environment(NotificationPermissionService())
}
