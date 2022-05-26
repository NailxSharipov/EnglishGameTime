//
//  ColorGrid.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 24.05.2022.
//

import SwiftUI

struct ColorGrid: View {

    @EnvironmentObject
    var viewModel: MainView.ViewModel
    
    var body: some View {
        GeometryReader { proxy in
            self.grid(size: proxy.size)
        }
    }
    
    private func grid(size: CGSize) -> some View {
        let colors = viewModel.colors
        let b = size.height
        let a = ceil(1.4 * size.height)
        
        let n = colors.count
        let w = CGFloat(n) * (a + 8) + 8
        let h =  b + 16
        
        return ZStack(alignment: .center) {
            HStack() {
                ForEach(0..<n, id: \.self) { id in
                    colors[id]
                    .frame(width: a, height: b, alignment: .center)
                    .cornerRadius(4)
                    .gesture(TapGesture().onEnded() {
                        viewModel.setColor(index: id)
                    })
                }
            }.frame(width: w, height: h, alignment: .center).background(.ultraThickMaterial).cornerRadius(8)
        }.frame(maxWidth: .infinity)
    }
    
}
