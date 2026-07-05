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

	// TODO: Onboarding view UI
	var body: some View {
		VStack(spacing: 16) {
			Text("This is onboarding")

			if authService.isSignedIn {
				Text("Signed in as \(authService.currentUser?.name ?? "")")
					.font(.subheadline)
					.foregroundStyle(.secondary)
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
				.frame(height: 50)
				.padding(.horizontal, 40)
			}

			Button(authService.isSignedIn ? "Continue" : "Skip for now") {
				preferenceService.hasSeenOnboarding = true
			}
			.buttonStyle(.borderedProminent)
		}
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
