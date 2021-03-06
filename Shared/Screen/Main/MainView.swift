//
//  MainView.swift
//  EnglishGameTime (iOS)
//
//  Created by Nail Sharipov on 12.05.2022.
//

import SwiftUI

struct MainView: View {
    
    @StateObject
    private var viewModel = ViewModel(
        resource: .shared,
        audioResource: .shared,
        progressResource: .shared,
        permisionResource: .shared,
        rateResource: .shared,
        shareResource: .shared,
        colorResource: .shared,
        subscriptionResource: .shared,
        trackingSystem: GoogleAnalytics.shared
    )
    
    @Namespace
    private var openGameNameSpace
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                ScrollView(.vertical) {
                    self.logo(size: proxy.size)
                        .padding(.top, 20)
                    Text(viewModel.name)
                        .font(.system(size: 52, weight: .semibold, design: .monospaced))
                        .foregroundColor(viewModel.color)
                        .padding(.top, 24)
                    
                    if viewModel.isProgress {
                        ProgressView().progressViewStyle(.circular)
                            .accentColor(viewModel.color)
                            .scaleEffect(x: 2, y: 2, anchor: .center)
                    } else {
                        grid(size: proxy.size)
                            .padding(.top, 24)
                    }
                    if !viewModel.isIntroduction {
                        Text("more coming soon")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(viewModel.color)
                            .padding(.top, 8)
                    }
                    Spacer(minLength: 60)
                }
            }
            
            if case let .opend(transaction) = viewModel.openGameState {
                GameView(color: viewModel.color, transaction: transaction)
                    .zIndex(1)
                    .matchedGeometryEffect(id: transaction.id, in: openGameNameSpace)
            }
            ZStack {
                ZStack(alignment: .center) {
                    Image(systemName: "star.bubble")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36, height: 36)
                        .foregroundColor(viewModel.color)
                }
                .frame(width: 60, height: 60)
                .background(.ultraThickMaterial)
                .cornerRadius(30)
                .gesture(TapGesture().onEnded() {
                    viewModel.pressStore()
                }).padding(12)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            VStack(alignment: .center) {
                Spacer()
                ColorGrid().frame(height: 30).padding(.bottom, 16)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            if viewModel.isShareTipVisible {
                InviteFriendPromtView(color: viewModel.color) { [weak viewModel] in
                    viewModel?.pressCloseInviteFriend()
                }.ignoresSafeArea()
            }
            ZStack {
                ZStack(alignment: .center) {
                    Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36, height: 36)
                        .foregroundColor(viewModel.color)
                }
                .frame(width: 60, height: 60)
                .background(.ultraThickMaterial)
                .cornerRadius(30)
                .gesture(TapGesture().onEnded() {
                    viewModel.pressShare()
                }).padding(12)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            ZStack {
                ZStack(alignment: .center) {
                    Image(systemName: "gearshape")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36, height: 36)
                        .foregroundColor(viewModel.color)
                }
                .frame(width: 60, height: 60)
                .background(.ultraThickMaterial)
                .cornerRadius(30)
                .gesture(TapGesture().onEnded() {
                    viewModel.pressSettings()
                }).padding(12)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
        .preferredColorScheme(.light)
#if os(iOS)
        .sheet(isPresented: $viewModel.isShareOpen, content: {
            ShareActivityView(shareLink: viewModel.shareLink) {
                viewModel.onSuccessShare()
            }
        })
        .sheet(isPresented: $viewModel.isSubscriptionOpen, content: {
            SubscriptionView()
        })
        .sheet(isPresented: $viewModel.isSettingsOpen, content: {
            SettingsView()
        })
#endif
        .background(.white)
        .environmentObject(viewModel)
        .task {
            await viewModel.onAppear()
        }
    }

    private func grid(size: CGSize) -> some View {
        let spacing: CGFloat = 24
        let cellSize = CellSize(size: CGSize(width: size.width - 2 * spacing, height: size.height), minSpace: spacing)
        let columns = cellSize.columns
        let a = cellSize.side
        
        return LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(viewModel.cells) { cell in
                ZStack {
                    if cell.isOpen {
                        LessonCell(color: viewModel.color, viewModel: cell)
                            .frame(width: a, height: a, alignment: .center)
                            .onTapGesture() {
                                viewModel.tap(id: cell.id)
                            }
                    }
                }
                .matchedGeometryEffect(id: cell.id, in: openGameNameSpace)
                .frame(width: a, height: a)
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
        
        return LogoView(color: viewModel.color, alpha: 0.5, animate: viewModel.isMain)
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
