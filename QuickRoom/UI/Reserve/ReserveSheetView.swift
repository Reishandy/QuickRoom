//
//  ReserveSheetView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import SwiftUI
import AuthenticationServices

struct ReserveSheetView: View {
	@Environment(ReservationService.self) private var reservationService
	@Environment(AuthService.self) private var authService

	let roomId: String

	@State private var startTime: Date = .now
	@State private var endTime: Date = .now.addingTimeInterval(3600) // Default 1 hour
	@State private var isProcessing = false
	@State private var errorMessage: String?
	@State private var isSignInPresented = false

	var body: some View {
		NavigationStack {
			Form {
				Section("Book Time") {
					DatePicker("Start", selection: $startTime)
					DatePicker("End", selection: $endTime)

					Button {
						Task {
							isProcessing = true
							defer { isProcessing = false }
							do {
								try await reservationService.reserve(roomId: roomId, startTime: startTime, endTime: endTime)
							} catch APIError.unauthorized {
								isSignInPresented = true
							} catch {
								errorMessage = error.localizedDescription
							}
						}
					} label: {
						if isProcessing {
							ProgressView()
						} else {
							Text("Reserve")
								.frame(maxWidth: .infinity)
						}
					}
					.buttonStyle(.borderedProminent)
					.disabled(isProcessing || startTime >= endTime)
				}

				let myReservations = reservationService.reservations.filter { $0.roomId == roomId && $0.isMyReservation }

				if !myReservations.isEmpty {
					Section("My Active Reservations") {
						ForEach(myReservations) { reservation in
							HStack {
								Text(DateInterval(start: reservation.startTime, end: reservation.endTime).toReservationString())
									.font(.subheadline)
								Spacer()
								Button(role: .destructive) {
									Task {
										do {
											try await reservationService.cancelReservation(reservationId: reservation.id)
										} catch {
											errorMessage = error.localizedDescription
										}
									}
								} label: {
									Text("Cancel")
								}
								.buttonStyle(.bordered)
							}
						}
					}
				}
			}
			.navigationTitle("Reserve Room")
			.navigationBarTitleDisplayMode(.inline)
			.alert("Couldn't complete that", isPresented: Binding(
				get: { errorMessage != nil },
				set: { if !$0 { errorMessage = nil } }
			)) {
				Button("OK", role: .cancel) {}
			} message: {
				Text(errorMessage ?? "")
			}
			.sheet(isPresented: $isSignInPresented) {
				VStack(spacing: 16) {
					Text("Sign in to book rooms")
						.font(.headline)
					SignInWithAppleButton(.signIn) { request in
						authService.configure(request)
					} onCompletion: { result in
						Task {
							do {
								try await authService.completeSignIn(result)
								isSignInPresented = false
							} catch {
								errorMessage = error.localizedDescription
								isSignInPresented = false
							}
						}
					}
					.signInWithAppleButtonStyle(.black)
					.frame(height: 50)
					.padding(.horizontal, 40)
				}
				.presentationDetents([.height(200)])
			}
		}
	}
}

#Preview {
	ReserveSheetView(roomId: "ws-agung")
		.environment(ReservationService())
		.environment(AuthService.shared)
}
