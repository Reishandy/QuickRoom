//
//  TimelineSliderView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import SwiftUI
import Combine

enum TickType: Equatable {
	case normalHour
	case normalMinute
	case offHour
	case weekend
}

struct TimelineTick: Identifiable, Hashable {
	let id: Int
	let date: Date
	let hour: Int
	let type: TickType
	var isLabelTick: Bool = false
}

struct TimelineTickView: View, Equatable {
	let tick: TimelineTick
	let nowIndex: Int
	let tickWidth: CGFloat
	
	var body: some View {
		let isPast = tick.id < nowIndex
		
		// Only normal hours get the prominent major tick. Off hours/weekends match minutes.
		let isMajorTick = (tick.type == .normalHour)
		let baseColor: Color = isMajorTick ? Color(uiColor: .label) : Color(uiColor: .quaternaryLabel)
		let opacity: Double = (isPast || tick.type == .offHour || tick.type == .weekend) ? 0.3 : 1.0
		let tickColor = baseColor.opacity(opacity)
		
		VStack(spacing: 8) {
			Capsule()
				.fill(tickColor)
				.frame(width: 2.5, height: 32)
				.padding(.top, 8)
			
			if tick.isLabelTick {
				let labelText = tick.type == .weekend ? "Weekend" : "Off"
				Text(labelText)
					.foregroundStyle(Color(uiColor: .secondaryLabel).opacity(isPast ? 0.3 : 1.0))
					.fixedSize()
			} else if tick.type == .normalHour {
				Text("\(tick.hour)")
					.foregroundStyle(Color(uiColor: .secondaryLabel).opacity(isPast ? 0.3 : 1.0))
					.fixedSize()
			} else {
				Spacer(minLength: 0)
			}
		}
		.frame(width: tickWidth)
	}
}

struct TimelineSliderView: View {
	@Binding var selectedDate: Date
	@Binding var selectedIndex: Int?
	
	@State private var ticks: [TimelineTick]
	@State private var minAllowedIndex: Int = 0
	@State private var boundaryHitTrigger: Int = 0
	@State private var nowIndex: Int = 0
	
	var workingHourStart: Int
	var workingHourEnd: Int
	
	private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
	private let tickWidth: CGFloat = 8
	
	init(selectedDate: Binding<Date>, selectedIndex: Binding<Int?>, workingHourStart: Int = 7, workingHourEnd: Int = 19) {
		self._selectedDate = selectedDate
		self._selectedIndex = selectedIndex
		self.workingHourStart = workingHourStart
		self.workingHourEnd = workingHourEnd
		
		let anchor = Calendar.current.startOfDay(for: .now)
		self._ticks = State(initialValue: Self.generateTicks(anchorDate: anchor, workingHourStart: workingHourStart, workingHourEnd: workingHourEnd))
	}
	
	static func generateTicks(anchorDate: Date, workingHourStart: Int, workingHourEnd: Int) -> [TimelineTick] {
		var generatedTicks: [TimelineTick] = []
		let startDate = Calendar.current.date(byAdding: .day, value: -14, to: anchorDate) ?? anchorDate
		let endDate = Calendar.current.date(byAdding: .day, value: 30, to: anchorDate) ?? anchorDate
		
		var currentDate = startDate
		var id = 0
		let calendar = Calendar.current
		
		while currentDate <= endDate {
			let weekday = calendar.component(.weekday, from: currentDate)
			let hour = calendar.component(.hour, from: currentDate)
			let minute = calendar.component(.minute, from: currentDate)
			
			// Constrain exact hour bounds strictly to weekdays to prevent fragmenting the weekend block
			let isWeekday = (weekday >= 2 && weekday <= 6)
			let isExactWorkStart = isWeekday && (hour == workingHourStart && minute == 0)
			let isExactWorkEnd = isWeekday && (hour == workingHourEnd && minute == 0)
			
			// Weekend definitions
			let isFridayOff = (weekday == 6 && (hour > workingHourEnd || (hour == workingHourEnd && minute > 0)))
			let isSaturday = (weekday == 7)
			let isSunday = (weekday == 1)
			let isMondayOff = (weekday == 2 && hour < workingHourStart)
			
			let isWeekendOffTime = isFridayOff || isSaturday || isSunday || isMondayOff
			let isWeekdayOffTime = !isWeekendOffTime && (hour < workingHourStart || hour > workingHourEnd || (hour == workingHourEnd && minute > 0)) && !isExactWorkStart && !isExactWorkEnd
			
			let tickType: TickType
			var incrementMinutes: Int
			
			if isExactWorkStart || isExactWorkEnd || (!isWeekdayOffTime && !isWeekendOffTime && minute == 0) {
				tickType = .normalHour
				if isExactWorkEnd {
					// At the exact end of work, determine next tick leap based on whether weekend starts
					incrementMinutes = (weekday == 6) ? 180 : 60
				} else {
					incrementMinutes = 10
				}
			} else if isWeekendOffTime {
				tickType = .weekend
				incrementMinutes = 180
			} else if isWeekdayOffTime {
				tickType = .offHour
				incrementMinutes = 60
			} else {
				tickType = .normalMinute
				incrementMinutes = 10
			}
			
			generatedTicks.append(TimelineTick(id: id, date: currentDate, hour: hour, type: tickType))
			id += 1
			
			var nextDate = calendar.date(byAdding: .minute, value: incrementMinutes, to: currentDate)!
			
			// Clamp to exact work start if a 3-hour weekend jump unintentionally steps over it
			if let targetStart = calendar.date(bySettingHour: workingHourStart, minute: 0, second: 0, of: nextDate) {
				if currentDate < targetStart && nextDate > targetStart {
					let targetWeekday = calendar.component(.weekday, from: targetStart)
					if targetWeekday >= 2 && targetWeekday <= 6 {
						nextDate = targetStart
					}
				}
			}
			
			currentDate = nextDate
		}
		
		// Post-process to group continuous blocks and assign exactly ONE label to the middle tick
		var i = 0
		while i < generatedTicks.count {
			let type = generatedTicks[i].type
			if type == .offHour || type == .weekend {
				var j = i
				while j < generatedTicks.count && generatedTicks[j].type == type {
					j += 1
				}
				
				let midIndex = i + (j - 1 - i) / 2
				generatedTicks[midIndex].isLabelTick = true
				i = j
			} else {
				i += 1
			}
		}
		
		return generatedTicks
	}
	
	// TODO: Update latest figma
	var body: some View {
		GeometryReader { geometry in
			let centerPadding = (geometry.size.width / 2) - (tickWidth / 2)
			
			ZStack(alignment: .top) {
				ScrollView(.horizontal, showsIndicators: false) {
					LazyHStack(alignment: .top, spacing: 0) {
						ForEach(ticks) { tick in
							TimelineTickView(tick: tick, nowIndex: nowIndex, tickWidth: tickWidth)
								.equatable() // Stops unchanged ticks from re-rendering
								.id(tick.id)
						}
					}
					.scrollTargetLayout()
				}
				.scrollPosition(id: $selectedIndex)
				.scrollTargetBehavior(.viewAligned)
				.safeAreaPadding(.horizontal, centerPadding)
				.onChange(of: selectedIndex) { _, newIndex in
					guard let newIndex, ticks.indices.contains(newIndex) else { return }
					
					if newIndex < minAllowedIndex {
						boundaryHitTrigger += 1
						
						withAnimation(.bouncy(duration: 0.3, extraBounce: 0.2)) {
							selectedIndex = minAllowedIndex
						}
					} else {
						selectedDate = ticks[newIndex].date
					}
				}
				
				Image(systemName: "triangle.fill")
					.foregroundStyle(selectedIndex == nowIndex ? Color.blue : Color.black)
					.rotationEffect(.degrees(180))
				
				if selectedIndex != nowIndex {
					HStack(alignment: .center) {
						// TODO: Style the button glass better
						Button {
							withAnimation(.bouncy) {
								selectedIndex = nowIndex
							}
						} label: {
							Image(systemName: "arrowshape.backward.fill")
								.foregroundStyle(Color.blue)
								.font(.title2)
								.frame(height: 32)
						}
						.buttonStyle(.glass)
						.padding(.leading, 30)
						.padding(.top, 8)
						
						Spacer()
					}
				}
			}
			.animation(.default, value: selectedIndex != nowIndex)
			.mask {
				LinearGradient(
					stops: [
						.init(color: .clear, location: 0.0),
						.init(color: .black, location: 0.1),
						.init(color: .black, location: 0.9),
						.init(color: .clear, location: 1.0)
					],
					startPoint: .leading,
					endPoint: .trailing
				)
			}
		}
		.frame(height: 70)
		.onAppear {
			updateCurrentTimeConstraints()
			
			if selectedIndex == nil {
				selectedIndex = minAllowedIndex
			}
		}
		.onReceive(timer) { _ in
			updateCurrentTimeConstraints()
		}
		.sensoryFeedback(.selection, trigger: selectedIndex)
		.sensoryFeedback(.error, trigger: boundaryHitTrigger)
	}
	
	private func updateCurrentTimeConstraints() {
		let now = Date.now
		
		guard let currentIndex = ticks.lastIndex(where: { $0.date <= now }) else { return }
		
		nowIndex = currentIndex
		minAllowedIndex = currentIndex
		
		if selectedIndex ?? 0 < nowIndex {
			selectedIndex = currentIndex
		}
	}
}

#Preview {
	@Previewable @State var selectedDate: Date = .now
	@Previewable @State var selectedIndex: Int?
	
	TimelineSliderView(selectedDate: $selectedDate, selectedIndex: $selectedIndex)
}
