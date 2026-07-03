//
//  HomeView.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 02/07/26.
//

import SwiftUI

struct HomeView: View {
	var onInteract: () -> Void
	
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			Image("floorplan")
				.resizable()
				.scaledToFit()
				.containerRelativeFrame(.vertical)
		}
		.simultaneousGesture(
			DragGesture().onChanged { _ in
				onInteract()
			}
		)
	}
}

#Preview {
	HomeView() {}
}
