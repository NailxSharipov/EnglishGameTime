//
//  CheckView.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 18.05.2022.
//

import SwiftUI

struct CheckView: View {
    
    @StateObject
    private var viewModel = ViewModel()
    
    let visible: Bool
    let lineWeight: CGFloat = 0.15
    let color: Color = .green
    
    var body: some View {
        GeometryReader() { proxy in
            path(size: proxy.size)
                .stroke(style: .init(lineWidth: viewModel.lineWidth, lineCap: .round, lineJoin: .miter))
                .foregroundColor(viewModel.color)
        }
    }
    
    private func path(size: CGSize) -> Path {
        self.viewModel.set(size: size, color: color, lineWeight: lineWeight, visible: visible)
        return Path { path in
            let w = size.width
            let h = size.height
            
            let p1 = CGPoint(x: 0.5 * w, y: 5/8 * h)
            let p0 = p1 + CGPoint(x: -1/4 * w, y: -1/4 * h)
            let p2 = p1 + CGPoint(x: 3/8 * w, y: -3/8 * h)
            
            path.move(to: p0)
            path.addLine(to: p1)
            path.addLine(to: p2)
        }
    }

}

private final class ViewModel: ObservableObject {
    
    private var visible: Bool?
    private var hiddenLine: CGFloat = 0
    private var visibleLine: CGFloat = 0
    private var size: CGSize = .zero
    private var visibleColor: Color = .clear
    
    var lineWidth: CGFloat = 0
    var color: Color = .clear

    func set(size: CGSize, color: Color, lineWeight: CGFloat, visible: Bool) {
        if self.size != size {
            let a = (size.height * size.width).squareRoot().rounded(.towardZero)
            hiddenLine = 2 * a
            visibleLine = a * lineWeight
        }
        self.size = size
        self.visibleColor = color
        self.color = visible ? visibleColor : visibleColor.opacity(0)
        self.lineWidth = visible ? visibleLine : hiddenLine
    }
    
    func set(visible: Bool) {
        guard self.visible != visible else { return }
        self.visible = visible
        color = visible ? visibleColor : visibleColor.opacity(0)
        lineWidth = visible ? visibleLine : hiddenLine
        self.objectWillChange.send()
    }
}
