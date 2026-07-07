//
//  OnboardingView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 02/07/26.
//

import SwiftUI
import AuthenticationServices

struct OnboardingView: View {
	@Environment(PreferenceService.self) private var preferenceService
	@Environment(AuthService.self) private var authService

	@State private var signInErrorMessage: String?

	var body: some View {
		VStack(alignment: .leading) {
			VStack(alignment: .leading, spacing: 14) {
				Text("Welcome to")
				
				Text("Apple Developer Academy @ BINUS, Bali")
					.font(.largeTitle)
					.bold()
			}
			
			Spacer()

			if authService.isSignedIn {
				Button {
					preferenceService.hasSeenOnboarding = true
				} label: {
					Text("Continue as \(authService.currentUser?.name ?? "User")")
						.padding(.vertical, 6)
						.frame(maxWidth: .infinity)
				}
				.buttonStyle(.borderedProminent)
			} else {
				SignInWithAppleButton(.signIn) { request in
					authService.configure(request)
				} onCompletion: { result in
					Task {
						do {
							try await authService.completeSignIn(result)
							preferenceService.hasSeenOnboarding = true
						} catch {
							signInErrorMessage = error.localizedDescription
						}
					}
				}
				.signInWithAppleButtonStyle(.black)
				.frame(height: 45)
				.clipShape(RoundedRectangle(cornerRadius: 24))
			}
		}
		.padding(20)
		.alert("Sign-in failed", isPresented: Binding(
			get: { signInErrorMessage != nil },
			set: { if !$0 { signInErrorMessage = nil } }
		)) {
			Button("OK", role: .cancel) {}
		} message: {
			Text(signInErrorMessage ?? "")
		}
	}
}

#Preview {
	OnboardingView()
		.environment(PreferenceService())
		.environment(AuthService.shared)
}
