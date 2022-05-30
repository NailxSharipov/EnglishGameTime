//
//  SubscriptionView.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 27.05.2022.
//

import SwiftUI

struct SubscriptionView: View {

    @EnvironmentObject
    private var mainViewModel: MainView.ViewModel
    
    @StateObject
    private var viewModel = ViewModel()
    
    var body: some View {
        GeometryReader() { proxy in
            self.content(proxy: proxy)
        }.background(.white)
    }

    private func content(proxy: GeometryProxy) -> some View {
        let w = proxy.size.width
        let h = proxy.size.height

        let h0 = 0.3 * h
        let h1 = 0.36 * h
        
        return ZStack {
            Path { path in
                path.move(to: CGPoint(x: 0, y: h0))
                path.addQuadCurve(to: CGPoint(x: w, y: h0), control: CGPoint(x: 0.5 * w, y: h1))
                path.addLine(to: CGPoint(x: w, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.closeSubpath()
            }.fill(mainViewModel.color)
            VStack(alignment: .center, spacing: 0) {
                ZStack(alignment: .center) {
                    Text("Big Ban English")
                        .font(.system(size: 40, weight: .semibold, design: .monospaced))
                        .multilineTextAlignment(.center)
                        
                        .foregroundColor(.white)
                        .padding(24)
                }.frame(height: ceil(h1), alignment : .center)
                Spacer()
                ForEach(viewModel.cells) { cell in
                    SubscriptionCell(viewModel: cell).frame(height: 100, alignment: .center)
                        .gesture(TapGesture().onEnded {
                            viewModel.onTap(id: cell.id)
                        })
                }
                Spacer()
                Button("Subscribe") {
                    print("Button pressed!")
                }
                .padding()
                .background(.yellow)
                .clipShape(Capsule())
                .padding(.bottom, 16)
            }.padding([.trailing, .leading], 16)
        }
    }
    
}
