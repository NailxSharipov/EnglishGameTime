//
//  GameView.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 12.05.2022.
//

import SwiftUI

struct GameView: View {

    private enum Layout {
        static let gridSpacing: CGFloat = 24
    }
    
    @StateObject
    var viewModel = ViewModel(lessonResource: .shared, permisionResource: .shared, progressResource: .shared, audioResource: .shared)
    
    private let color: Color
    private let transaction: OpenGameTransaction
    
    init(color: Color, transaction: OpenGameTransaction) {
        self.color = color
        self.transaction = transaction
    }
    
    var body: some View {
        GeometryReader { rootProxy in
            ZStack {
                VStack(alignment: .center) {
                    GameBarView(color: color).frame(height: 44).padding(.top, 20)
                    Spacer(minLength: Layout.gridSpacing)
                    if viewModel.isGameEnd {
                        HStack {
                            if viewModel.statistic.isWin {
                            Spacer()
                                Image(systemName: "list.bullet")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .gesture(TapGesture().onEnded() {
                                        viewModel.pressLeaderBoard()
                                    })
                            }
                            Spacer()
                            Image(systemName: "arrow.clockwise")
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
                        }
                        .frame(height: 100, alignment: .center).padding(8)
                        .transition(.opacity)
                    } else {
                        VStack {
                            Text(viewModel.word)
                                .font(.system(size: 60, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(alignment: .center)
                                .cornerRadius(12)
                                .padding(.top, 32)
                            Spacer(minLength: Layout.gridSpacing)
                            GeometryReader { gridProxy in
                                grid(size: gridProxy.size)
                            }
                            Spacer(minLength: Layout.gridSpacing)
                        }
                        .transition(.opacity)
                    }
                }
            }.background(.pink)
        }.environmentObject(viewModel).task {
            await viewModel.start(transaction: transaction)
        }
    }
    
    private func grid(size: CGSize) -> some View {
        let n = viewModel.cells.count
        let layout = CenteredGridLayout(
            size: CGSize(width: size.width - 2 * Layout.gridSpacing, height: size.height),
            count: n,
            minSpace: Layout.gridSpacing
        )
        let columns = layout.columns
        let a = layout.side
        
        return HStack {
            Spacer()
            VStack {
                Spacer()
                LazyVGrid(
                    columns: columns,
                    spacing: Layout.gridSpacing
                ) {
                    ForEach(viewModel.cells) { cell in
                        WordCell(viewModel: cell).frame(width: a, height: a, alignment: .center)
                    }
                }
                .frame(width: layout.size.width, height: layout.size.height, alignment: .center)
                Spacer()
            }
            Spacer()
        }
    }
    
    private func endView(size: CGSize) -> some View {
        let m = min(size.width, size.height)
        var a: CGFloat = trunc(0.6 * m)
        if a < 300 {
            a = m - 40
        }

        return EndView()
            .frame(width: a, height: a, alignment: .center)
            .zIndex(1)
            .transition(.move(edge: .bottom))
        
    }
    
}
