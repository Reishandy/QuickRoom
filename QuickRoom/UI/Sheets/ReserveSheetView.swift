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
	
	@Binding var selectedDate: Date
	
	let roomId: String
	let onDismissClick: () -> Void
	
	@State private var startTime: Date = .now
	@State private var endTime: Date = .now.addingTimeInterval(AppConfig.Reservation.minDuration)
	@State private var isProcessing = false
	@State private var errorMessage: String?
	@State private var isStartPickerPresented = false
	@State private var isEndPickerPresented = false
	@State private var showDeleteConfirmation = false
	
	private var dailyReservations: [Reservation] {
		reservationService.reservations.filter {
			$0.roomId == roomId && Calendar.current.isDate($0.startTime, inSameDayAs: selectedDate)
		}
	}
	
	private var myReservation: Reservation? {
		dailyReservations.first(where: { $0.isMyReservation })
	}
	
	private var hasExistingReservation: Bool {
		dailyReservations.contains { $0.isMyReservation }
	}
	
	// TODO: Delete reservation
	var body: some View {
		NavigationStack {
			VStack {
				HorizontalDatePickerView(selectedDate: $selectedDate)
					.frame(maxHeight: 80)
				
				VerticalTimelineView(
					reservations: dailyReservations,
					selectedDate: $selectedDate,
					startTime: $startTime,
					endTime: $endTime,
					hasExistingReservation: hasExistingReservation
				)
			}
			.navigationTitle(reservationService.rooms.first(where: { $0.id == roomId })?.name ?? roomId)
			.navigationSubtitle(selectedDate.toReservationString())
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button("Dismiss", systemImage: "xmark") {
						onDismissClick()
					}
				}
				
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						Task {
							isProcessing = true
							defer { isProcessing = false }
							do {
								try await reservationService.reserve(roomId: roomId, startTime: startTime, endTime: endTime)
								// } catch APIError.unauthorized {
								// TODO: Kick out of the app?
								// Right now this should not happen right? with the implementation of PR #20?
							} catch {
								errorMessage = error.localizedDescription
							}
						}
					} label: {
						if isProcessing {
							ProgressView()
						} else {
							Label("Add", systemImage: "checkmark")
						}
					}
					.buttonStyle(.borderedProminent)
					.disabled(isProcessing || startTime >= endTime || hasExistingReservation)
				}
				
				ToolbarItemGroup(placement: .bottomBar) {
					Button("Starts: \(startTime.toPickerString())") {
						isStartPickerPresented = true
					}
					.popover(isPresented: $isStartPickerPresented) {
						IntervalWheelPicker(date: $startTime)
							.frame(width: 320, height: 260)
							.presentationCompactAdaptation(.popover)
							.onDisappear {
								isStartPickerPresented = false
							}
					}
				}
				
				ToolbarSpacer(placement: .bottomBar)
				
				if myReservation != nil {
					ToolbarItemGroup(placement: .bottomBar) {
						Button("Delete", systemImage: "trash", role: .destructive) {
							showDeleteConfirmation = true
						}
						.tint(.red)
						.disabled(isProcessing)
						.confirmationDialog("Delete Reservation", isPresented: $showDeleteConfirmation, titleVisibility: .hidden) {
							Button("Delete Reservation", role: .destructive) {
								if let reservationId = myReservation?.id {
									Task {
										isProcessing = true
										defer { isProcessing = false }
										do {
											try await reservationService.cancelReservation(reservationId: reservationId)
										} catch {
											errorMessage = error.localizedDescription
										}
									}
								}
							}
							Button("Cancel", role: .cancel) {}
						} message: {
							Text("Are you sure you want to delete this reservation? This action cannot be undone.")
						}
					}
				}
				
				ToolbarSpacer(placement: .bottomBar)
				
				ToolbarItemGroup(placement: .bottomBar) {
					Button("Ends: \(endTime.toPickerString())") {
						isEndPickerPresented = true
					}
					.popover(isPresented: $isEndPickerPresented) {
						IntervalWheelPicker(date: $endTime)
							.frame(width: 320, height: 260)
							.presentationCompactAdaptation(.popover)
							.onDisappear {
								isEndPickerPresented = false
							}
					}
				}
			}
			.alert("Couldn't complete that", isPresented: Binding(
				get: { errorMessage != nil },
				set: { if !$0 { errorMessage = nil } }
			)) {
				Button("OK", role: .cancel) {}
			} message: {
				Text(errorMessage ?? "")
			}
			.onChange(of: startTime) { oldValue, newValue in
				let resolved = TimelineUtilities.resolveTimeSelection(
					proposedStart: newValue,
					proposedEnd: endTime,
					selectedDate: selectedDate,
					reservations: dailyReservations,
					changedBoundary: .start
				)
				
				if startTime != resolved.start { startTime = resolved.start }
				if endTime != resolved.end { endTime = resolved.end }
			}
			.onChange(of: endTime) { oldValue, newValue in
				let resolved = TimelineUtilities.resolveTimeSelection(
					proposedStart: startTime,
					proposedEnd: newValue,
					selectedDate: selectedDate,
					reservations: dailyReservations,
					changedBoundary: .end
				)
				
				if startTime != resolved.start { startTime = resolved.start }
				if endTime != resolved.end { endTime = resolved.end }
			}
			.task {
				try? await reservationService.fetchReservationsOnLoad()
			}
		}
	}
}

#Preview {
	ReserveSheetView(
		selectedDate: .constant(.now),
		roomId: "ws-agung",
		onDismissClick: {}
	)
	.environment(ReservationService())
	.environment(AuthService.shared)
}
