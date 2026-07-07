//
//  HorizontalDatePickerView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 07/07/26.
//

import SwiftUI

struct HorizontalDatePickerView: View {
	@Binding var selectedDate: Date
	
	private let calendar = Calendar.current
	
	private var dates: [Date] {
		let today = calendar.startOfDay(for: .now)
		let startOffset = -AppConfig.Timeline.lookbehindDays
		let endOffset = AppConfig.Timeline.lookaheadDays
		
		return (startOffset...endOffset).compactMap { dayOffset in
			calendar.date(byAdding: .day, value: dayOffset, to: today)
		}
	}
	
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			ScrollViewReader { proxy in
				LazyHStack(spacing: 12) {
					ForEach(dates, id: \.self) { date in
						DateCell(
							date: date,
							isSelected: calendar.isDate(date, inSameDayAs: selectedDate)
						) {
							withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
								selectedDate = date
							}
						}
						.id(calendar.startOfDay(for: date))
					}
				}
				.padding(.horizontal, 20)
				.onAppear {
					let targetDate = calendar.startOfDay(for: selectedDate)
					proxy.scrollTo(targetDate, anchor: .center)
				}
			}
		}
		.sensoryFeedback(.selection, trigger: selectedDate)
	}
}

private struct DateCell: View {
	let date: Date
	let isSelected: Bool
	let action: () -> Void
	
	private var isWeekend: Bool {
		Calendar.current.isDateInWeekend(date)
	}
	
	private var isPast: Bool {
		Calendar.current.startOfDay(for: date) < Calendar.current.startOfDay(for: .now)
	}
	
	private var isDisabled: Bool {
		isWeekend || isPast
	}
	
	private var dayOfWeek: String {
		date.formatted(.dateTime.weekday(.narrow))
	}
	
	private var dayOfMonth: String {
		date.formatted(.dateTime.day())
	}
	
	var body: some View {
		Button(action: action) {
			VStack(spacing: 10) {
				Text(dayOfWeek)
					.font(.subheadline)
					.foregroundStyle(isDisabled ? .secondary : .primary)
				
				Text(dayOfMonth)
					.font(.title3)
					.fontWeight(.regular)
					.frame(width: 44, height: 44)
					.background {
						if isSelected {
							Circle()
								.fill(Color.blue)
						}
					}
					.foregroundStyle(isSelected ? .white : (isDisabled ? .secondary : .primary))
			}
		}
		.buttonStyle(.plain)
		.disabled(isDisabled)
	}
}

#Preview {
	@Previewable @State var date = Date.now
	HorizontalDatePickerView(selectedDate: $date)
}
