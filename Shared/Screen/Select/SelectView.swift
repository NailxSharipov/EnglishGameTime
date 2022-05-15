//
//  SelectView.swift
//  EnglishGameTime (iOS)
//
//  Created by Nail Sharipov on 12.05.2022.
//

import SwiftUI

struct SelectView: View {
    
    @StateObject
    var viewModel = ViewModel(resource: .shared)
    
    var body: some View {
        ZStack {
            NavigationLink(destination: GameView(lessonId: viewModel.selectedLessonId), isActive: $viewModel.isOpenGame) {
                EmptyView()
            }.hidden()
            GeometryReader { geometryProxy in
                ScrollView(.vertical) {
                    Image("logo")
                    Spacer(minLength: 16)
                    grid(size: geometryProxy.size)
                }.task {
                    await viewModel.load()
                }
            }
        }.toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button(action: {
                    print("gearshape")
                }) {
                    Image(systemName: "gearshape")
                }
            }
        }
    }
    
    private func grid(size: CGSize) -> some View {
        let spacing: CGFloat = 24
        let cellSize = CellSize(size: CGSize(width: size.width - 2 * spacing, height: size.height), minSpace: spacing)
        let columns = cellSize.columns
        let a = cellSize.side
        
        return LazyVGrid(
            columns: columns,
            spacing: spacing
        ) {
            ForEach(viewModel.cells) { cell in
                LessonCell(item: cell)
                    .frame(width: a, height: a, alignment: .center)
                    .onTapGesture() {
                        viewModel.tap(id: cell.id)
                    }
            }
        }
    }
}

private struct CellSize {
    
    let side: CGFloat
    private let count: Int
    private let spacing: CGFloat
    
    var columns: [GridItem] {
        let grid = GridItem(.fixed(side), spacing: spacing)
        return Array<GridItem>(repeating: grid, count: count)
    }
    
    init(size: CGSize, minSpace: CGFloat) {
        let width = size.width
        let side: CGFloat = 100
        let maxCount = size.width > size.height ? 5 : 4

        let n = ((width + minSpace) / (side + minSpace)).rounded(.toNearestOrAwayFromZero)
        
        let rCount = min(n, CGFloat(maxCount))
        let real = (width - (rCount - 1) * minSpace) / rCount
        
        self.side = real.rounded(.toNearestOrAwayFromZero)
        count = Int(rCount)
        
        if rCount > 1.1 {
            spacing = (width - self.side * rCount) / (rCount - 1)
        } else {
            spacing = 0
        }
    }
    
}
