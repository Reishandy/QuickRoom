//
//  IntervalWheelPicker.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 07/07/26.
//

import SwiftUI
import UIKit

struct IntervalWheelPicker: UIViewRepresentable {
	@Binding var date: Date
	
	func makeUIView(context: Context) -> UIDatePicker {
		let picker = UIDatePicker()
		picker.datePickerMode = .time
		picker.preferredDatePickerStyle = .wheels
		picker.minuteInterval = AppConfig.Reservation.timeStepMinutes
		picker.addTarget(context.coordinator, action: #selector(Coordinator.dateChanged), for: .valueChanged)
		return picker
	}
	
	func updateUIView(_ uiView: UIDatePicker, context: Context) {
		uiView.date = date
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	class Coordinator: NSObject {
		let parent: IntervalWheelPicker
		init(_ parent: IntervalWheelPicker) { self.parent = parent }
		
		@objc func dateChanged(_ sender: UIDatePicker) {
			parent.date = sender.date
		}
	}
}
