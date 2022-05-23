//
//  Game.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 13.05.2022.
//

import Foundation

final class Game {
    
    struct Progress {
        let value: Double
        let step: Double
    }
    
    struct Statistic {
        let failWords: [Word]
        let time: TimeInterval
        let success: Int
        let isWin: Bool
        let isTimeEnd: Bool
    }

    enum CountLevel: Int {
        case x2 = 2
        case x4 = 4
        case x9 = 9
        case x12 = 12
    }
    
    private var startTime: Date?
    private var endTime: Date?
    private let gameLength: TimeInterval
    private let beforeTimeEnding: TimeInterval
    
    private let words: [Word]
    private var randomGenerator: RandomGenerator
    
    private var lastTime: Int?
    private var timer: Timer?
    private var isTimeEnding: Bool = false
    
    private let onGameEnd: (Statistic) -> ()
    private let onUpdateTime: (String) -> ()
    private let onTimeIsEnding: () -> ()
    
    private let countToWin: Int
    private let countToLose: Int
    private let countMaxLevel: CountLevel
    private (set) var failWords = Set<Int>()
    private (set) var successWords = Set<Int>()
    private (set) var nextWordId: Int = .min
    private (set) var nextWords: [Word] = []

    var isGameOver: Bool {
        timer == nil
    }

    var lifeCount: Int {
        countToLose - failWords.count
    }
    
    var progress: Progress {
        let value =  Double(successWords.count) / Double(countToWin)
        let step = 1 / Double(countToWin)
        return Progress(value: value, step: step)
    }
    
    var leftTime: TimeInterval {
        guard let startTime = startTime else {
            return 0
        }

        let duration = Date().timeIntervalSince(startTime)
        return gameLength - duration
    }
    
    var nextWord: Word { words[nextWordId] }
    
    func timeText(leftTime: TimeInterval) -> String {
        leftTime.cleanFormat
    }
    
    init(
        words: [Word],
        countToWin: Int,
        countToLose: Int,
        timeForWord: TimeInterval,
        beforeTimeEnding: TimeInterval,
        countMaxLevel: CountLevel,
        onUpdateTime: @escaping (String) -> (),
        onGameEnd: @escaping (Statistic) -> (),
        onTimeIsEnding: @escaping () -> ()
    ) {
        self.words = words
        self.countToWin = countToWin
//        self.countToWin = 4
        self.countToLose = countToLose
        self.countMaxLevel = countMaxLevel

        gameLength = timeForWord * Double(countToWin)
        self.beforeTimeEnding = beforeTimeEnding
        randomGenerator = RandomGenerator(size: words.count)

        self.onUpdateTime = onUpdateTime
        self.onGameEnd = onGameEnd
        self.onTimeIsEnding = onTimeIsEnding
    }

    func start() {
        startTime = Date()
        isTimeEnding = false

        if timer?.isValid ?? false {
            assertionFailure("timer is not canceled properly")
            timer?.invalidate()
        }
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.update()
        }
        timer.fire()
        self.timer = timer
        RunLoop.main.add(timer, forMode: .default)
    }
    
    func reset() {
        self.failWords = Set<Int>()
        self.successWords = Set<Int>()
        self.nextWordId = .min
        self.randomGenerator = RandomGenerator(size: words.count)
    }
    
    func nextRound() {
        let count = self.nextCount()
        let round = randomGenerator.next(count: count)
        var list = [Word]()
        for index in round.list {
            list.append(words[index])
        }

        nextWordId = words[round.uniq].id
        
        nextWords = list
    }
    
    func put(wordId: Int) -> Bool {
        let success = nextWordId == wordId
        if success {
            self.addSuccess(wordId: wordId)
        } else {
            self.addFail(wordId: wordId)
        }
        return success
    }
    
    func stop() {
        endTime = Date()
        timer?.invalidate()
        timer = nil
    }
    
    private func addSuccess(wordId: Int) {
        successWords.insert(wordId)
        if successWords.count >= countToWin {
            self.endGame(isWin: true, isTimeEnd: false)
        }
    }
    
    private func addFail(wordId: Int) {
        failWords.insert(wordId)
        if failWords.count >= countToLose {
            self.endGame(isWin: false, isTimeEnd: false)
        }
    }
    
    private func update() {
        let time = self.leftTime
        guard time > 0 else {
            self.endGame(isWin: false, isTimeEnd: true)
            return
        }
        
        let seconds = Int(time)
        if seconds != lastTime {
            lastTime = seconds
            onUpdateTime(time.cleanFormat)
        }
        
        if !isTimeEnding && time < beforeTimeEnding {
            isTimeEnding = true
            self.onTimeIsEnding()
        }
    }
    
    private func nextCount() -> Int {
        let factor = successWords.count - failWords.count

        let level: CountLevel
        
        switch factor {
        case 2...3:
            level = .x4
        case 4...5:
            level = .x9
        case 6...:
            level = .x12
        default:
            level = .x2
        }

        return min(countMaxLevel.rawValue, level.rawValue)
    }
    
    private func endGame(isWin: Bool, isTimeEnd: Bool) {
        self.stop()
        
        let time = gameLength - self.leftTime

        let statistic = Statistic(
            failWords: failWords.map({ words[$0] }),
            time: time,
            success: successWords.count,
            isWin: isWin,
            isTimeEnd: isTimeEnd
        )
        
        self.onGameEnd(statistic)
    }
    
}
