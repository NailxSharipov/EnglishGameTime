//
//  GameView.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 12.05.2022.
//

import SwiftUI

struct GameView: View {
    
    private enum Layout {
        static let buttonSize: CGFloat = 36
    }
    
    @StateObject
    var viewModel = ViewModel(lessonResource: .shared, permisionResource: .shared, progressResource: .shared, audioResource: .shared, replicaSource: .shared, trackingSystem: GoogleAnalytics.shared)
    
    private let color: Color
    private let transaction: OpenGameTransaction
    
    init(color: Color, transaction: OpenGameTransaction) {
        self.color = color
        self.transaction = transaction
    }
    
    var body: some View {
        GeometryReader { mainProxy in
            ZStack(alignment: .top) {
                HStack(alignment: .center) {
                    Image(systemName: "house.fill").resizable().aspectRatio(contentMode: .fit).foregroundColor(.white)
                        .frame(width: Layout.buttonSize, height: Layout.buttonSize)
                        .gesture(TapGesture().onEnded({
                            viewModel.pressHome()
                    })).padding(.leading, 20)
                    Spacer()
                    self.heart(index: 2, lifeCount: viewModel.lifeCount)
                    self.heart(index: 1, lifeCount: viewModel.lifeCount)
                    self.heart(index: 0, lifeCount: viewModel.lifeCount).padding(.trailing, 20)
                }.frame(height: 44).padding(.top, 20)
                
                VStack(alignment: .center) {
                    if viewModel.isGameEnd {
                        if viewModel.statistic.isWin {
                            ZStack(alignment: .center) {
                                Text("You win!")
                                    .font(.system(
                                        size: mainProxy.isIPad ? 40 : 20,
                                        weight: .semibold,
                                        design: .monospaced
                                    ))
                                    .foregroundColor(.white)
                                    .frame(alignment: .center)
                                FireWorkView(
                                    animation: .init(
                                        count: 14...20,
                                        blust: 9...12,
                                        first: .init(maxLifeTime: 1.5...2.4, speed: 1.6...2.2, size: 2, friction: 0.99),
                                        second: .init(maxLifeTime: 1.7...2.1, speed: 0.6...1.0, size: 2, friction: 0.98),
                                        gravity: -0.4
                                    ),
                                    animate: true
                                )
                            }
                        } else {
                            Spacer()
                            HStack {
                                Text(viewModel.loseReplica.text)
                                    .font(.system(size: mainProxy.isIPad ? 24 : 12, weight: .regular)).foregroundColor(.white)
                                Text(" - \(viewModel.loseReplica.author)")
                                    .font(.system(size: mainProxy.isIPad ? 24 : 12, weight: .ultraLight)).foregroundColor(.white)
                            }.padding(mainProxy.isIPad ? 40 : 20)
                        }
                        Spacer()
                        HStack {
                            if viewModel.statistic.isWin {
                                Spacer()
                                Image(systemName: "list.bullet")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.white)
                                    .frame(width: Layout.buttonSize, height: Layout.buttonSize)
                                    .gesture(TapGesture().onEnded() {
                                        viewModel.pressLeaderBoard()
                                    })
                            }
                            Spacer()
                            Image(systemName: "arrow.clockwise")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.white)
                                .frame(width: Layout.buttonSize, height: Layout.buttonSize)
                                .gesture(TapGesture().onEnded() {
                                    viewModel.pressRepeat()
                                })
                            if viewModel.statistic.isWin && viewModel.nextPermision {
                                Spacer()
                                Image(systemName: "arrow.right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.white)
                                    .frame(width: Layout.buttonSize, height: Layout.buttonSize)
                                    .gesture(TapGesture().onEnded() {
                                        viewModel.pressNext()
                                    })
                            }
                            Spacer()
                        }
                        .frame(height: 100, alignment: .center).padding(8)
                        .transition(.opacity)
                    } else {
                        VStack(alignment: .center, spacing: 0) {
                            Text(viewModel.time)
                                .font(.system(
                                    size: mainProxy.isIPad ? 40 : 20,
                                    weight: .semibold,
                                    design: .monospaced
                                ))
                                .foregroundColor(.white)
                                .frame(height: 44, alignment: .center)
                                .padding(.top, 20)
                            ProgressBarView(color: .white, value: viewModel.progress.value)
                                .frame(width: mainProxy.isIPad ? 200 : 100, height: 4, alignment: .center)
                                .padding(.top, mainProxy.isIPad ? 20 : 0)
                            Text(viewModel.word)
                                .font(.system(size: mainProxy.isIPad ? 60 : 36, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white)
                                .id("name \(viewModel.word)")
                                .padding(.top, 20)
                            GeometryReader { gridProxy in
                                grid(size: gridProxy.size, spacing: mainProxy.isIPad ? 24 : 4)
                            }
                            if mainProxy.isIPad {
                                Spacer(minLength: 8)
                            }
                        }
                        .transition(.opacity)
                    }
                }
            }
        }
        .background(color)
        .task {
            await viewModel.start(transaction: transaction)
        }
    }
    
    private func grid(size: CGSize, spacing: CGFloat) -> some View {
        let n = viewModel.cells.count
        let layout = CenteredGridLayout(
            size: CGSize(width: size.width - 2 * spacing, height: size.height),
            count: n,
            minSpace: spacing
        )
        let columns = layout.columns
        let a = layout.side
        
        return VStack(alignment: .center) {
            LazyVGrid(
                columns: columns,
                spacing: spacing
            ) {
                ForEach(viewModel.cells) { cell in
                    WordCell(viewModel: cell).frame(width: a, height: a, alignment: .center)
                }
            }
        }.frame(width: size.width, height: size.height)
    }
    
    private func heart(index: Int, lifeCount: Int) -> some View {
        if index < lifeCount {
            return Image(systemName: "heart.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
        } else {
            return Image(systemName: "heart")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
        }
    }

}
