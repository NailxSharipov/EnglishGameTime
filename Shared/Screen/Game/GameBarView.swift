//
//  GameBarView.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 13.05.2022.
//

import SwiftUI

struct GameBarView: View {
    
    private let heartSize: CGFloat = 30
    
    @EnvironmentObject
    private var viewModel: GameView.ViewModel
    
    let color: Color
    
    var body: some View {
        ZStack(alignment: .leading) {
            Image(systemName: "house").resizable().foregroundColor(.white)
                .frame(width: 30, height: 30)
                .gesture(TapGesture().onEnded({
                    viewModel.pressHome()
            })).padding(.leading, 30)
            if !viewModel.isGameEnd {
                VStack(alignment: .center, spacing: 0) {
                    Text(viewModel.time)
                        .font(.system(size: 40, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.top, 24)
                    ProgressBarView(color: .white, value: viewModel.progress.value)
                        .frame(width: 200, height: 4, alignment: .center)
                        .padding(.top, 12)
                    Spacer()
                }.frame(maxWidth: .infinity)
            }
            ZStack {
                HStack {
                    self.heart(index: 0, lifeCount: viewModel.lifeCount).frame(width: heartSize, height: heartSize).foregroundColor(.white)
                    self.heart(index: 1, lifeCount: viewModel.lifeCount).frame(width: heartSize, height: heartSize).foregroundColor(.white)
                    self.heart(index: 2, lifeCount: viewModel.lifeCount).frame(width: heartSize, height: heartSize).foregroundColor(.white)
                }.padding(.trailing, 30)
            }.frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    
    private func heart(index: Int, lifeCount: Int) -> Image {
        if index < lifeCount {
            return Image(systemName: "heart.fill").resizable()
        } else {
            return Image(systemName: "heart").resizable()
        }
    }
}
