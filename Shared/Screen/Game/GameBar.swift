//
//  GameBar.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 13.05.2022.
//

import SwiftUI

struct GameBar: View {

    private let time: String
    private let progress: Game.Progress
    private let lifeCount: Int
    
    init(time: String, progress: Game.Progress, lifeCount: Int) {
        self.time = time
        self.progress = progress
        self.lifeCount = lifeCount
    }
    
    var body: some View {
        ZStack {
            Color.yellow.frame(maxWidth: .infinity, maxHeight: 100, alignment: .topLeading)
            HStack {
                Spacer(minLength: 30)
                Text(time).monospacedDigit()
                Color.orange.frame(height: 20, alignment: .center)
                Spacer(minLength: 30)
                HeartSlotView().frame(width: 50, height: 50, alignment: .center)
                HeartSlotView().frame(width: 50, height: 50, alignment: .center)
                HeartSlotView().frame(width: 50, height: 50, alignment: .center)
                Spacer(minLength: 30)
            }
        }
    }
    
}
