//
//  SubscriptionView.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 27.05.2022.
//

import SwiftUI

struct SubscriptionView: View {

    @Namespace
    private var cellNameSpace
    
    @EnvironmentObject
    private var mainViewModel: MainView.ViewModel
    
    @StateObject
    private var viewModel = ViewModel(subscriptionResource: .shared, trackingSystem: GoogleAnalytics.shared)
    
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
        
        return ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .center, spacing: 8) {
                    Spacer(minLength: h1)
                    Text("lze_subscribe_description".locolize).multilineTextAlignment(.center).font(.system(size: 14, weight: .regular)).foregroundColor(.black).padding(8)
                    ForEach(viewModel.cells) { cell in
                        SubscriptionCell(cellNameSpace: cellNameSpace, viewModel: cell).frame(height: 86, alignment: .center)
                            .gesture(TapGesture().onEnded {
                                viewModel.onTap(id: cell.id)
                            })
                    }
                    Text("lze_subscribe_cancel".locolize).font(.system(size: 12, weight: .regular)).foregroundColor(.gray)
                    Spacer(minLength: 8)
                    Button("lze_subscribe_action".locolize) {
                        viewModel.subscribe()
                    }
                    .padding()
                    .background(.yellow)
                    .clipShape(Capsule())
                    .padding(.bottom, 16)
                }
                .frame(maxWidth: 300, alignment: .center)
                .padding([.trailing, .leading], 16)
            }
            Path { path in
                path.move(to: CGPoint(x: 0, y: h0))
                path.addQuadCurve(to: CGPoint(x: w, y: h0), control: CGPoint(x: 0.5 * w, y: h1))
                path.addLine(to: CGPoint(x: w, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.closeSubpath()
            }.fill(mainViewModel.color)
            ZStack(alignment: .center) {
                Text("Big Ban English")
                    .font(.system(size: 40, weight: .semibold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    
                    .foregroundColor(.white)
                    .padding(24)
            }.frame(height: ceil(h1), alignment : .center)
        }.alert(viewModel.alert.message, isPresented: $viewModel.alert.isShow) {
            Button("OK", role: .cancel) { }
        }.task {
            await viewModel.onLoad()
        }.onAppear() {
            viewModel.onSuccess = { [weak mainViewModel] in
                mainViewModel?.isSubscriptionOpen = false
            }
        }
    }
    
}
