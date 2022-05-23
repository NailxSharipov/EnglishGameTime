//
//  WheelView.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 22.05.2022.
//

import SwiftUI

struct WheelView: View {
    
    private struct OriginalSize {
        static let radius: CGFloat = 65
        static let legsLength: CGFloat = 80
        static let legsDistance: CGFloat = 60
        static let legDepth: CGFloat = 6
        
        static let height = 2 * (legsLength + legDepth)
    }
    
    @State private var isAnimating = false
    
    let color: Color
    
    var body: some View {
        GeometryReader { proxy in
            self.resized(size: proxy.size)
        }.onAppear() {
            withAnimation(.linear(duration: 32).repeatForever(autoreverses: false)) {
                self.isAnimating = true
            }
        }.onDisappear() {
            self.isAnimating = false
        }
    }
    
    private func resized(size: CGSize) -> some View {
        let scale = size.height / OriginalSize.height
        let r = OriginalSize.radius * scale
        let d = 2 * r
        let c = CGPoint(x: r, y: r)
        let depth = OriginalSize.legDepth * scale
        
        return ZStack(alignment: .top) {
            Image("wheel_circle")
                .renderingMode(.template)
                .resizable()
                .foregroundColor(color)
                .frame(width: d, height: d)
                .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0), anchor: .center)
            Path { path in
                let distance = OriginalSize.legsDistance * scale
                let dx = 0.5 * (d - distance)
                let x0 = dx
                let y0 = size.height
                let x1 = c.x
                let y1 = c.y
                let x2 = x0 + distance
                let y2 = y0
                
                path.move(to: .init(x: x0, y: y0))
                path.addLine(to: .init(x: x1, y: y1))
                path.addLine(to: .init(x: x2, y: y2))
            }
            .strokedPath(.init(lineWidth: depth, lineCap: .round, lineJoin: .round))
            .foregroundColor(color)
            
        }
        .frame(width: d, height: size.height)
    }
}
