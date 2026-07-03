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
	
	@State private var minAllowedIndex: Int = 0
	@State private var boundaryHitTrigger: Int = 0
	@State private var nowIndex: Int = 0
	
	private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
	private let anchorDate: Date = {
		Calendar.current.dateInterval(of: .hour, for: .now)?.start ?? .now
	}()

	// 12 ticks per hour (5-minute intervals).
	private let tickRange = -1000...100_000 // TODO: Decide the range
	private let secondaryTickSecond = 300
	private let tickWidth: CGFloat = 10
	
	var body: some View {
		GeometryReader { geometry in
			let centerPadding = (geometry.size.width / 2) - (tickWidth / 2)
			
			ZStack(alignment: .top) {
				ScrollView(.horizontal, showsIndicators: false) {
					LazyHStack(alignment: .top, spacing: 0) {
						ForEach(tickRange, id: \.self) { index in
							let date = anchorDate.addingTimeInterval(TimeInterval(index * secondaryTickSecond))
							tickView(for: index, date: date, nowIndex: nowIndex)
								.id(index)
						}
					}
					.scrollTargetLayout()
				}
				.scrollPosition(id: $selectedIndex)
				.scrollTargetBehavior(.viewAligned)
				.safeAreaPadding(.horizontal, centerPadding)
				.onChange(of: selectedIndex) { _, newIndex in
					guard let newIndex else { return }
					
					if newIndex < minAllowedIndex {
						boundaryHitTrigger += 1
						
						withAnimation(.bouncy(duration: 0.3, extraBounce: 0.2)) {
							selectedIndex = minAllowedIndex
						}
					} else {
						selectedDate = anchorDate.addingTimeInterval(TimeInterval(newIndex * secondaryTickSecond))
					}
				}
				
				Image(systemName: "triangle.fill")
					.foregroundStyle(Color(uiColor: .systemBlue))
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
								.foregroundStyle(Color(uiColor: .systemBlue))
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
	
	@ViewBuilder
	private func tickView(for index: Int, date: Date, nowIndex: Int) -> some View {
		let isHour = index % 12 == 0
		let isNow = index == nowIndex
		let isTooCloseToNow = abs(index - nowIndex) <= 3
		
		VStack(spacing: 8) {
			Capsule()
				.fill(isNow ? Color(uiColor: .systemBlue) : (isHour ? Color(uiColor: .label) : Color(uiColor: .quaternaryLabel)))
				.frame(width: 2, height: 32)
				.padding(.top, 8)
			
			if isNow {
				Text("Now")
					.foregroundStyle(Color(uiColor: .systemBlue))
					.fixedSize()
			} else if isHour && !isTooCloseToNow {
				Text(date.formatted(.dateTime.hour().minute()))
					.foregroundStyle(Color(uiColor: .secondaryLabel))
					.fixedSize()
			} else {
				Spacer()
			}
		}
		.frame(width: tickWidth)
	}
	
	private func updateCurrentTimeConstraints() {
		let diff = Date.now.timeIntervalSince(anchorDate)
		let currentIndex = Int(round(diff / Double(secondaryTickSecond)))
		
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
