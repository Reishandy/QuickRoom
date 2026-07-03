//
//  RelativePolygonShape.swift
//  QuickRoom
//
//  Created by Muhammad Akbar Reishandy on 03/07/26.
//

import SwiftUI

struct RelativePolygonShape: Shape {
	let relativePoints: [CGPoint]
	
	func path(in rect: CGRect) -> Path {
		var path = Path()
		guard let first = relativePoints.first else { return path }
		
		path.move(to: CGPoint(x: first.x * rect.width, y: first.y * rect.height))
		
		for point in relativePoints.dropFirst() {
			path.addLine(to: CGPoint(x: point.x * rect.width, y: point.y * rect.height))
		}
		
		path.closeSubpath()
		return path
	}
}
