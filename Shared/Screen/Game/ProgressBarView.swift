//
//  ProgressBarView.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 23.05.2022.
//

import SwiftUI


struct ProgressBarView: View {
    
    let color: Color
    let value: CGFloat
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                Path { path in
                    let y = 0.5 * proxy.size.height
                    path.move(to: .init(x: 0, y: y))
                    path.addLine(to: .init(x: proxy.size.width, y: y))
                }
                .strokedPath(.init(lineWidth: proxy.size.height, lineCap: .round))
                .foregroundColor(color)
                .opacity(0.5)
                Path { path in
                    let y = 0.5 * proxy.size.height
                    path.move(to: .init(x: 0, y: y))
                    path.addLine(to: .init(x: value * proxy.size.width, y: y))
                }
                .strokedPath(.init(lineWidth: proxy.size.height, lineCap: .round))
                .foregroundColor(color)
            }
        }
    }

}
