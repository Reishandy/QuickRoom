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
	
	@State private var scrollPosition = ScrollPosition(idType: Int.self)
	
	@State private var ticks: [TimelineTick]
	@State private var minAllowedIndex: Int = 0
	@State private var boundaryHitTrigger: Int = 0
	@State private var nowIndex: Int = 0
	
	private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
	
	init(selectedDate: Binding<Date>, selectedIndex: Binding<Int?>) {
		self._selectedDate = selectedDate
		self._selectedIndex = selectedIndex
		
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
				
				if selectedIndex != nowIndex {
					HStack(alignment: .center) {
						Button {
							withAnimation(.bouncy) {
								selectedIndex = nowIndex
							}
						} label: {
							Image(systemName: "arrow.backward.circle.fill")
								.font(.title)
								.foregroundStyle(Color(UIColor.systemBlue))
								.frame(width: 60, height: 60)
								.background(.thinMaterial, in: Circle())
						}
						.buttonStyle(.plain)
						.padding(.leading, 12)
						.padding(.top, 4)
						
						Spacer()
					}
					.transition(.opacity.combined(with: .scale(scale: 0.9)))
				}
			}
			.animation(.default, value: selectedIndex != nowIndex)
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

#Preview {
	@Previewable @State var selectedDate: Date = .now
	@Previewable @State var selectedIndex: Int?
	
	TimelineSliderView(selectedDate: $selectedDate, selectedIndex: $selectedIndex)
}
