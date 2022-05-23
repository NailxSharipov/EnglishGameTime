//
//  EndView.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 15.05.2022.
//

import SwiftUI

struct EndView: View {

    @EnvironmentObject
    var viewModel: GameView.ViewModel
    
    var body: some View {
        ZStack {
            Rectangle().fill(.green).cornerRadius(8)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    heart(index: 0).frame(width: 50, height: 50, alignment: .center)
                    Spacer()
                    heart(index: 1).frame(width: 50, height: 50, alignment: .center)
                    Spacer()
                    heart(index: 2).frame(width: 50, height: 50, alignment: .center)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "list.bullet")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .gesture(TapGesture().onEnded() {
                            viewModel.pressLeaderBoard()
                        })
                    Spacer()
                    Image(systemName: "repeat")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .gesture(TapGesture().onEnded() {
                            viewModel.pressRepeat()
                        })
                    if viewModel.statistic.isWin && viewModel.nextPermision != .more {
                        Spacer()
                        Image(systemName: "arrow.right")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .gesture(TapGesture().onEnded() {
                                viewModel.pressNext()
                            })
                    }
                    Spacer()
                }.frame(height: 100, alignment: .center).padding(8)
            }
        }
    }
    
    private func heart(index: Int) -> Image {
        let lifeCount = 3 - viewModel.statistic.failWords.count
        if index < lifeCount {
            return Image(systemName: "heart.fill").resizable()
        } else {
            return Image(systemName: "heart").resizable()
        }
    }
    
}

private struct RoundButton: View {
    
    let name: String
    let action: () -> ()
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .center) {
                Circle().fill(.yellow)
                Image(systemName: name).resizable().frame(width: 0.25 * proxy.size.width, height: 0.25 * proxy.size.height)
            }
        }.gesture(TapGesture().onEnded(action))
    }
}
