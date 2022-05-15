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
            GeometryReader { geometryProxy in
                grid(size: geometryProxy.size).task {
                    await viewModel.start(lessonId: lessonId)
                }
            }
            Spacer(minLength: Layout.gridSpacing)
        }.toolbar {
            ToolbarItemGroup(placement: .automatic) {}
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
                        WordCell(item: cell)
                            .frame(width: a, height: a, alignment: .center)
                            .onTapGesture() {
                                viewModel.tap(word: cell.name)
                            }
                    }
                }
                .frame(width: layout.size.width, height: layout.size.height, alignment: .center)
                Spacer()
            }
            Spacer()
        }
    }
    
}
