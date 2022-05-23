//
//  MainView.swift
//  EnglishGameTime (iOS)
//
//  Created by Nail Sharipov on 12.05.2022.
//

import SwiftUI

struct MainView: View {
    
    let color: Color
    
    @StateObject
    private var viewModel = ViewModel(
        resource: .shared,
        audioResource: .shared,
        progressResource: .shared,
        permisionResource: .shared,
        rateResource: .shared,
        shareResource: .shared
    )
    
    @Namespace
    private var openGameNameSpace
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                ScrollView(.vertical) {
                    self.logo(size: proxy.size)
                        .padding(.top, 20)
                    Text("Big Ban English")
                        .font(.system(size: 52, weight: .semibold, design: .monospaced))
                        .foregroundColor(color)
                        .padding(.top, 24)
                    grid(size: proxy.size)
                        .padding(.top, 24)
                }.task {
                    await viewModel.load()
                }
            }
            
            if case let .opend(transaction) = viewModel.openGameState {
                GameView(color: color, transaction: transaction)
                    .zIndex(1)
                    .matchedGeometryEffect(id: transaction.id, in: openGameNameSpace)
            }
            ZStack {
                Button("Share") {
                    viewModel.pressShare()
                }.padding(40)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
#if os(iOS)
        .sheet(isPresented: $viewModel.isShareOpen, content: {
            ShareActivityView(shareLink: viewModel.shareLink) {
                viewModel.onSuccessShare()
            }
        })
#endif
    }

    private func grid(size: CGSize) -> some View {
        let spacing: CGFloat = 24
        let cellSize = CellSize(size: CGSize(width: size.width - 2 * spacing, height: size.height), minSpace: spacing)
        let columns = cellSize.columns
        let a = cellSize.side
        
        return LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(viewModel.cells) { cell in
                if cell.isOpen {
                    LessonCell(color: color, viewModel: cell)
                        .frame(width: a, height: a, alignment: .center)
                        .onTapGesture() {
                            viewModel.tap(id: cell.id)
                        }
                        .matchedGeometryEffect(id: cell.id, in: openGameNameSpace)
                } else {
                    Rectangle().frame(width: a, height: a, alignment: .center)
                }
            }
        }
    }
    
    private func logo(size: CGSize) -> some View {

        var w = 0.72 * size.height
        var h = 0.2 * size.height

        if w > 0.98 * size.width {
            w = ceil(0.98 * size.width)
            h = 0.25 * w
        }
        
        return LogoView(color: color, alpha: 0.5, animate: viewModel.isMain)
            .frame(width: w, height: h)
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
