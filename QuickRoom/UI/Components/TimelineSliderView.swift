//
//  TimelineSliderView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import SwiftUI
import Combine

struct TimelineSliderView: View {
	@Binding var selectedDate: Date
	@Binding var selectedIndex: Int?
	/// True while the scrubber sits on the current time; the parent shows its
	/// own return-to-now control (title-row button, per mentor feedback).
	@Binding var isAtNow: Bool
	/// Incremented by the parent to snap the scrubber back to now.
	let goToNowPulse: Int

	@State private var scrollPosition = ScrollPosition(idType: Int.self)
	
	@State private var ticks: [TimelineTick]
	@State private var minAllowedIndex: Int = 0
	@State private var boundaryHitTrigger: Int = 0
	@State private var nowIndex: Int = 0
	
	private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
	
	init(selectedDate: Binding<Date>, selectedIndex: Binding<Int?>, isAtNow: Binding<Bool> = .constant(true), goToNowPulse: Int = 0) {
		self._selectedDate = selectedDate
		self._selectedIndex = selectedIndex
		self._isAtNow = isAtNow
		self.goToNowPulse = goToNowPulse

		let anchor = Calendar.current.startOfDay(for: .now)
		self._ticks = State(initialValue: TimelineUtilities.generateTicks(anchorDate: anchor))
	}
	
	var body: some View {
		GeometryReader { geometry in
			let centerPadding = (geometry.size.width / 2) - (AppConfig.Timeline.tickWidth / 2)
			
			ZStack(alignment: .top) {
				ScrollView(.horizontal, showsIndicators: false) {
					LazyHStack(alignment: .top, spacing: 0) {
						ForEach(ticks) { tick in
							TimelineTickView(tick: tick, nowIndex: nowIndex, tickWidth: AppConfig.Timeline.tickWidth)
								.equatable()
								.id(tick.id)
						}
					}
					.scrollTargetLayout()
				}
				.scrollPosition($scrollPosition)
				.scrollTargetBehavior(.viewAligned)
				.safeAreaPadding(.horizontal, centerPadding)
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
				.onChange(of: scrollPosition) { _, newPosition in
					if let newIndex = newPosition.viewID as? Int, selectedIndex != newIndex {
						selectedIndex = newIndex
					}
				}
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
					
					if scrollPosition.viewID as? Int != newIndex {
						scrollPosition.scrollTo(id: newIndex)
					}
				}
				
				ZStack {
					Image(systemName: "triangle.fill")
						.font(.callout)
						.foregroundStyle(.ultraThinMaterial)
						.scaleEffect(1.3)
						.offset(y: -1)
					
					Image(systemName: "triangle.fill")
						.font(.callout)
						.foregroundStyle(selectedIndex == nowIndex ? Color.blue : Color(uiColor: .label))
				}
				.rotationEffect(.degrees(180))
			}
		}
		.frame(height: 70)
		.onAppear {
			updateCurrentTimeConstraints()
			
			if selectedIndex == nil {
				selectedIndex = minAllowedIndex
			}
			
			if let selectedIndex {
				scrollPosition.scrollTo(id: selectedIndex)
			}
		}
		.onReceive(timer) { _ in
			updateCurrentTimeConstraints()
		}
		.onChange(of: selectedIndex) { _, newIndex in
			isAtNow = newIndex == nowIndex
		}
		.onChange(of: goToNowPulse) { _, _ in
			withAnimation(.bouncy) {
				selectedIndex = nowIndex
			}
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

struct TimelineTickView: View, Equatable {
	let tick: TimelineTick
	let nowIndex: Int
	let tickWidth: CGFloat
	
	var body: some View {
		let isPast = tick.id < nowIndex

		// Day starts are the prominent separators (mentor feedback: the tall
		// lines must divide days, not hours); hours are medium, half-hours
		// faint — otherwise it reads like a ruler.
		let baseColor: Color = tick.isDayStart ? Color(uiColor: .label)
			: tick.type == .normalHour ? Color(uiColor: .tertiaryLabel)
			: Color(uiColor: .quaternaryLabel)
		let opacity: Double = (isPast || tick.type == .offHour || tick.type == .weekend) ? 0.3 : 1.0
		let tickColor = baseColor.opacity(opacity)
		let height: CGFloat = tick.isDayStart ? 36 : tick.type == .normalHour ? 24 : 14

		VStack(spacing: 8) {
			Capsule()
				.fill(tickColor)
				.frame(width: tick.isDayStart ? 3 : 2, height: height)
				.padding(.top, tick.isDayStart ? 4 : 4 + (36 - height) / 2)

			if tick.isLabelTick {
				let labelText = tick.type == .weekend ? "Weekend" : "Off"
				Text(labelText)
					.font(.caption)
					.foregroundStyle(Color(uiColor: .secondaryLabel).opacity(isPast ? 0.3 : 1.0))
					.fixedSize()
			} else if tick.isDayStart {
				Text(tick.date.toDayLabel())
					.font(.caption.weight(.semibold))
					.foregroundStyle(Color(uiColor: .label).opacity(isPast ? 0.3 : 1.0))
					.fixedSize()
			} else if tick.type == .normalHour {
				Text("\(tick.hour)")
					.font(.caption)
					.foregroundStyle(Color(uiColor: .secondaryLabel).opacity(isPast ? 0.3 : 1.0))
					.fixedSize()
			} else {
				Spacer(minLength: 0)
			}
		}
		.frame(width: tickWidth)
	}
}

#Preview {
	@Previewable @State var selectedDate: Date = .now
	@Previewable @State var selectedIndex: Int?
	
	TimelineSliderView(selectedDate: $selectedDate, selectedIndex: $selectedIndex)
}
