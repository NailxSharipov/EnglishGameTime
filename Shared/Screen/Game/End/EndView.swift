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
                    RoundButton(name: "list.bullet") {
                        withAnimation(.easeIn) {
                            viewModel.isEndViewShown.toggle()
                        }
                    }
                    RoundButton(name: "repeat") {
                        withAnimation(.easeIn) {
                            viewModel.isEndViewShown.toggle()
                        }
                        viewModel.repeatGame()
                    }
                    RoundButton(name: "repeat") {
                        withAnimation(.easeIn) {
                            viewModel.isEndViewShown.toggle()
                        }
                        viewModel.repeatGame()
                    }
                }.frame(height: 100, alignment: .center).padding(8)
            }
        }
    }
}

private struct RoundButton: View {
    
    let name: String
    let action: () -> ()
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Circle().fill(.yellow)
                Image(systemName: name)
            }
        }.gesture(TapGesture().onEnded(action))
    }
}
