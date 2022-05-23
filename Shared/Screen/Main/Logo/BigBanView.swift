//
//  BigBanView.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 22.05.2022.
//

import SwiftUI

struct BigBanView: View {

    private static let size = CGSize(width: 44, height: 252)
    private static let center = CGPoint(x: 22, y: 76)
    private static let radius: CGFloat = 16
    
    private let calendar: Calendar = {
        var calendar = Calendar.current
        if let londonTimeZone = TimeZone(identifier: "Europe/London") {
            calendar.timeZone = londonTimeZone
        }
        return calendar
    }()
    
    let color: Color
    let date: Date
    
    var body: some View {
        GeometryReader { proxy in
            self.layout(size: proxy.size)
        }
    }
    
    private func layout(size: CGSize) -> some View {
        let ratio = Self.size.width / Self.size.height
        let scale = size.height / Self.size.height
        let depth = 1.4 * scale

        let rh = scale * 0.5 * Self.radius
        let rm = scale * 0.8 * Self.radius

        let calendar = Calendar.current

        let h = calendar.component(.hour, from: date) % 12
        let m = calendar.component(.minute, from: date)

        let p1 = scale * Self.center
        let p0 = rh * self.vector(h: h) + p1
        let p2 = rm * self.vector(m: m) + p1
        
        return ZStack(alignment: .center) {
            Image("big_ban")
                .renderingMode(.template)
                .resizable()
                .foregroundColor(color)
            Path { path in
                path.move(to: p0)
                path.addLine(to: p1)
                path.addLine(to: p2)
            }
            .strokedPath(.init(lineWidth: depth, lineCap: .round, lineJoin: .round))
            .foregroundColor(color)
            
        }
        .frame(width: size.height * ratio, height: size.height)
    }
    
    private func vector(m: Int) -> CGPoint {
        let a = 2 * Double.pi * (Double(m) / 60) - 0.5 * .pi
        return CGPoint(x: cos(a), y: sin(a))
    }
    
    private func vector(h: Int) -> CGPoint {
        let a = 2 * Double.pi * (Double(h) / 12) - 0.5 * .pi
        return CGPoint(x: cos(a), y: sin(a))
    }
    
}
