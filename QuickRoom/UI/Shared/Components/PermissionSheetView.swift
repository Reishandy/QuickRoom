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
	
	// TODO: Permission Sheet View UI
	// TODO: Tell which permission is missing individualy
    var body: some View {
		VStack {
			Text("TODO: Permission sheet")
			Text("TODO: Explanation about each permissions")
			Text("TODO: And why we need them")
			
			if shouldShowSettingsRedirect {
				Button("Go to settings") {
					if shouldShowSettingsRedirect {
						if let url = URL(string: UIApplication.openSettingsURLString) {
							UIApplication.shared.open(url)
						}
					}
				}
				.buttonStyle(.borderedProminent)
			} else {
				Button("Grant permissions") {
					Task {
						if notificationPermissionService.isNotDetermined {
							await notificationPermissionService.requestPermission()
						}
						
						if locationPermissionService.isNotDetermined || !locationPermissionService.isFullyAuthorized {
							await locationPermissionService.requestAlways()
						}
					}
				}
				.buttonStyle(.borderedProminent)
			}
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
