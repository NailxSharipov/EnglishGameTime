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
    var viewModel = ViewModel(resource: .shared)
    
    private let lessonId: Int
    
    init(lessonId: Int) {
        self.lessonId = lessonId
    }
    
    var body: some View {
        GeometryReader { rootProxy in
            ZStack {
                VStack {
                    GameBar(time: viewModel.time, progress: viewModel.progress, lifeCount: viewModel.lifeCount)
                    Spacer(minLength: Layout.gridSpacing)
                    HStack {
                        Spacer(minLength: 24)
                        ZStack {
                            Color.white
                            Text(viewModel.word).fontWeight(.semibold).font(.largeTitle).foregroundColor(.black)
                        }
                        .frame(height: 80, alignment: .center)
                        .cornerRadius(8)
                        Spacer(minLength: 24)
                    }
                    Spacer(minLength: Layout.gridSpacing)
                    GeometryReader { gridProxy in
                        grid(size: gridProxy.size).task {
                            await viewModel.start(lessonId: lessonId)
                        }
                    }
                    Spacer(minLength: Layout.gridSpacing)
                }
                if viewModel.isEndViewShown {
                    endView(size: rootProxy.size)
                }
            }
        }.toolbar {
            ToolbarItemGroup(placement: .automatic) {}
        }.environmentObject(viewModel)
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
            .zIndex(1)
            .transition(.move(edge: .bottom))
            .frame(width: a, height: a, alignment: .center)
    }
    
}
