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
    }

    enum CountLevel: Int {
        case x2 = 2
        case x4 = 4
        case x9 = 9
        case x12 = 12
    }
    
    private var startTime: Date = Date()
    private var endTime: Date = Date()
    private let gameLength: TimeInterval
    
    private let words: [Word]
    private var randomGenerator: RandomGenerator
    
    private var lastTime: Int?
    private var timer: Timer?
    
    private let onGameEnd: (Statistic) -> ()
    private let onUpdateTime: (String) -> ()
    
    private let countToWin: Int
    private let countToLose: Int
    private let countMaxLevel: CountLevel
    private (set) var failWords = Set<Int>()
    private (set) var successWords = Set<Int>()
    private (set) var nextWord: String = ""
    private (set) var nextWords: [Word] = []
    private (set) var isGameOver: Bool = false

    var lifeCount: Int {
        countToLose - failWords.count
    }
    
    var progress: Progress {
        let value =  Double(successWords.count) / Double(countToWin)
        let step = 1 / Double(countToWin)
        return Progress(value: value, step: step)
    }
    
    var leftTime: TimeInterval {
        let duration = Date().timeIntervalSince(startTime)
        return gameLength - duration
    }
    
    func timeText(leftTime: TimeInterval) -> String {
        leftTime.cleanFormat
    }
    
    init(
        words: [Word],
        countToWin: Int,
        countToLose: Int,
        timeForWord: TimeInterval,
        countMaxLevel: CountLevel,
        onUpdateTime: @escaping (String) -> (),
        onGameEnd: @escaping (Statistic) -> ()
    ) {
        self.words = words
        self.countToWin = countToWin
        self.countToLose = countToLose
        self.countMaxLevel = countMaxLevel

        gameLength = timeForWord * Double(countToWin)
        randomGenerator = RandomGenerator(size: words.count)

        self.onUpdateTime = onUpdateTime
        self.onGameEnd = onGameEnd
    }

    func start() {
        isGameOver = false
        startTime = Date()
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.update()
        }
        timer.fire()
        self.timer = timer
        RunLoop.main.add(timer, forMode: .default)
    }
    
    func nextCircle() {
        let count = self.nextCount()
        let indices = randomGenerator.getNext(count: count)
        var list = [Word]()
        for index in indices {
            list.append(words[index])
        }
            
        let rest = Set(indices).subtracting(successWords)
        let nextIndex: Int
        if let index = rest.randomElement() {
            nextIndex = index
        } else {
            assertionFailure("index problem")
            nextIndex = indices[0]
        }
        nextWord = words[nextIndex].name
        
        nextWords = list
    }
    
    func put(word: String) -> Bool {
        let success = nextWord == word
        if success {
            self.addSuccess(word: word)
        } else {
            self.addFail(word: word)
        }
        nextWord = ""
        
        return success
    }
    
    private func stop() {
        endTime = Date()
        timer?.invalidate()
        timer = nil
        isGameOver = true
    }
    
    private func addSuccess(word: String) {
        if let index = words.firstIndex(where: { $0.name == word }) {
            randomGenerator.addCount(index: index, value: words.count)
            successWords.insert(index)
        }
        if successWords.count >= countToWin {
            self.endGame(isWin: true)
        }
    }
    
    private func addFail(word: String) {
        guard let index = words.firstIndex(where: { $0.name == word }) else { return }
        failWords.insert(index)
        if failWords.count >= countToLose {
            self.endGame(isWin: false)
        }
    }
    
    private func update() {
        let time = self.leftTime
        guard time > 0 else {
            self.endGame(isWin: false)
            return
        }
        
        let seconds = Int(time)
        if seconds != lastTime {
            lastTime = seconds
            onUpdateTime(time.cleanFormat)
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
    
    private func endGame(isWin: Bool) {
        self.stop()
        
        let time = gameLength - self.leftTime

        let statistic = Statistic(
            failWords: failWords.map({ words[$0] }),
            time: time,
            success: successWords.count,
            isWin: isWin
        )
        
        self.onGameEnd(statistic)
    }
    
}
