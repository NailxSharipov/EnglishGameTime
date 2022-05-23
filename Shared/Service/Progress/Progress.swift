//
//  Progress.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 18.05.2022.
//

import Foundation

struct Progress: Codable {
    
    struct Lesson: Codable, Equatable {
        let id: Int
        let time: TimeInterval?
        let lifeCount: Int?
    }

    var lessons: [Lesson]
    
}

extension Progress.Lesson {
    
    init?(id: Int, statistic: Game.Statistic) {
        guard statistic.isWin else { return nil }
        let time = statistic.time
        let lifeCount = 3 - statistic.failWords.count
        self.init(id: id, time: time, lifeCount: lifeCount)
    }
    
}
