//
//  TimelineSliderView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import SwiftUI

struct TimelineSliderView: View {
	@Binding var selectedDate: Date
	
	// TODO: Scroll up to 7 days, still discussing
	// TODO: Make if we snap to day it updates with current time
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
			.frame(maxWidth: .infinity)
			.frame(height: 80)
			.background(.red)
    }
}

#Preview {
	@Previewable @State var selectedDate: Date = .now
	
    TimelineSliderView(selectedDate: $selectedDate)
}
