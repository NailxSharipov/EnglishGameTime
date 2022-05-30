//
//  GameView+ViewModel.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 12.05.2022.
//

import SwiftUI

extension GameView {
    
    final class ViewModel: ObservableObject {

        private (set) var isGameEnd = false

        private (set) var loseReplica: Replica = Replica(text: "", author: "")
        private (set) var word: String = ""
        private (set) var time: String = ""
        private (set) var lifeCount: Int = 3
        private (set) var progress: Game.Progress = .init(value: 0, step: 0)
        private (set) var lessonId: Int = 0
        private (set) var nextPermision: Bool = false
        private (set) var statistic: Game.Statistic = .init(failWords: [], time: 0, success: 0, isWin: false, isTimeEnd: false)
        private (set) var cells: [WordCell.ViewModel] = []
        private (set) var onClose: ((Bool) -> ())?

        private var isRound: Bool = true
        private var game: Game?
        private let lessonResource: LessonResource
        private let permisionResource: PermisionResource
        private let progressResource: ProgressResource
        private let audioResource: AudioResource
        private let replicaSource: ReplicaSource

        init(lessonResource: LessonResource, permisionResource: PermisionResource, progressResource: ProgressResource, audioResource: AudioResource, replicaSource: ReplicaSource) {
            self.lessonResource = lessonResource
            self.permisionResource = permisionResource
            self.progressResource = progressResource
            self.audioResource = audioResource
            self.replicaSource = replicaSource
        }
    }
    
}

extension GameView.ViewModel {

    func start(transaction: OpenGameTransaction) async {
        self.onClose = transaction.onClose
        await self.start(lessonId: transaction.id)
    }
    
    func start(lessonId: Int) async {
        self.lessonId = lessonId
        
        let lesson = await lessonResource.read(lessonId: lessonId)
        let nextPermision = permisionResource.isPermited(lessonId: lessonId + 1)
        
        let game = Game(
            words: lesson.words,
//            countToWin: 3,
            countToWin: lesson.words.count.winCount,
            countToLose: 3,
            timeForWord: 3,
            beforeTimeEnding: 8.5,
            countMaxLevel: .x12,
            onUpdateTime: { [weak self] time in
                self?.update(time: time)
            },
            onGameEnd: { [weak self] statistic in
                self?.endGame(statistic: statistic)
            },
            onTimeIsEnding: { [weak self] in
                self?.timeEnding()
            }
        )

        await self.start(game: game, nextPermision: nextPermision)
    }

    @MainActor
    func repeatGame() {
        guard let game = game else { return }
        game.reset()
        self.start(game: game, nextPermision: nextPermision)
    }
    
    @MainActor
    private func start(game newGame: Game, nextPermision: Bool) {
        audioResource.play(music: .gameFast)
        self.game = newGame
        self.lifeCount = newGame.lifeCount
        self.nextPermision = nextPermision
        self.progress = newGame.progress
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self = self else { return }
            newGame.start()
            self.nextWord()
        }
    }

    private func nextWord() {
        guard let game = self.game, !game.isGameOver else { return }
        game.nextRound()
        
        var cells = [WordCell.ViewModel]()
        for word in game.nextWords {
            let image = word.images.randomElement()!
            let cell = WordCell.ViewModel(id: word.id, name: word.name, image: image) { [weak self] in
                self?.press()
            } onTap: { [weak self] in
                self?.tap(wordId: word.id)
            }
            cells.append(cell)
        }
        
        withAnimation(.easeIn(duration: 0.4)) { [weak self] in
            guard let self = self else { return }
            self.word = game.nextWord.name
            self.cells = cells
            self.objectWillChange.send()
        }
        
        game.nextWord.audio?.play()
        
        isRound = true
    }
    
    private func tap(wordId: Int) {
        guard
            let game = self.game,
            let cell = cells.first(where: { $0.id == wordId }),
            isRound else { return }

        let result = game.put(wordId: wordId)

        withAnimation(.linear(duration: 0.5)) { [weak self, lifeCount = game.lifeCount, progress = game.progress] in
            guard let self = self else { return }
            self.lifeCount = lifeCount
            self.progress = progress
        }

        if !result {
            ImpactGenerator.share.sendError()
        }
        
        cell.set(status: result ? .success : .fail)
        
        if result {
            isRound = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                self?.nextWord()
            }
            self.audioResource.play(sound: .success)
        } else {
            self.audioResource.play(sound: .incorrect)
        }
    }
    
    private func press() {
        self.audioResource.play(sound: .click)
        ImpactGenerator.share.prepare()
    }
    
    private func update(time: String) {
        self.time = time
        self.objectWillChange.send()
    }
    
    private func timeEnding() {
        self.audioResource.play(sound: .timeIsRunnigOut)
    }
    
    private func endGame(statistic: Game.Statistic) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            guard let self = self else { return }
            self.audioResource.stopMusic()
            
            if statistic.isWin {
                self.audioResource.stop(sound: .timeIsRunnigOut)
                self.audioResource.play(sound: .win)
            } else if !statistic.isTimeEnd {
                self.audioResource.play(sound: .fail)
            }

            self.statistic = statistic
            
            Task {
                if let progress = Progress.Lesson(id: self.lessonId, statistic: statistic) {
                    await self.progressResource.save(progress)
                }
                await MainActor.run { [weak self] in
                    self?.showEnd(statistic: statistic)
                }
            }
        }
    }
    
    @MainActor
    private func showEnd(statistic: Game.Statistic) {
        withAnimation(.easeIn(duration: 0.5)) { [weak self] in
            guard let self = self else { return }
            self.word = ""
            self.cells = []
            self.time = ""
            self.loseReplica = self.replicaSource.next()
            self.isGameEnd = true
            self.objectWillChange.send()
        }
    }
    
    @MainActor
    func tapClose() {
        game?.stop()
        self.onClose?(false)
    }

    func nextLesson() async {
        guard nextPermision else { return }
        let nextId = self.lessonId + 1
        await self.start(lessonId: nextId)
    }
    
    func pressHome() {
        self.audioResource.stopMusic()
        self.audioResource.stop(sound: .timeIsRunnigOut)
        self.game?.stop()
        
        let isSuccess = (game?.isGameOver ?? false) && self.statistic.isWin

        self.onClose?(isSuccess)
    }
    
}

// EndView
extension GameView.ViewModel {
    
    func pressLeaderBoard() {
        guard isGameEnd else { return }
        debugPrint("pressLeaderBoard")
        audioResource.play(sound: .click)
    }

    func pressRepeat() {
        guard isGameEnd else { return }
        self.lifeCount = 3
        self.progress = .init(value: 0, step: 0)
        self.time = ""
        
        withAnimation(.easeIn) { [weak self] in
            guard let self = self else { return }
            self.isGameEnd.toggle()
            self.objectWillChange.send()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.repeatGame()
        }
        audioResource.play(sound: .click)
    }
    
    func pressNext() {
        guard isGameEnd else { return }
        withAnimation(.easeIn) { [weak self] in
            guard let self = self else { return }
            self.isGameEnd.toggle()
            self.objectWillChange.send()
        }
        
        Task { [weak self] in
            await self?.nextLesson()
        }

        audioResource.play(sound: .click)
    }
}


private extension Int {
    
    var winCount: Int {
        let a = Int((0.8 * Double(self) / 5).rounded() * 5)
        return a < self ? a : self
    }
    
}
