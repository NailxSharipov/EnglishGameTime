//
//  GameView+ViewModel.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 12.05.2022.
//

import SwiftUI

extension GameView {
    
    final class ViewModel: ObservableObject {

        var isEndViewShown = false
        
        private (set) var word: String = ""
        private (set) var time: String = ""
        private (set) var lifeCount: Int = 0
        private (set) var progress: Game.Progress = .init(value: 0, step: 0)
        private (set) var lessonId: Int = 0
        private (set) var statistic: Game.Statistic = .init(failWords: [], time: 0, success: 0, isWin: false)
        private (set) var cells: [WordCell.ViewModel] = []
        
        private var isRound: Bool = true
        private var game: Game?
        private let resource: LessonResource

        init(resource: LessonResource) {
            self.resource = resource
        }
    }
    
}

extension GameView.ViewModel {

    func start(lessonId: Int) async {
        self.lessonId = lessonId
        let lesson = await resource.read(lessonId: lessonId)

        let game = Game(
            words: lesson.words,
            countToWin: lesson.words.count.winCount,
            countToLose: 3,
            timeForWord: 5,
            countMaxLevel: .x12,
            onUpdateTime: { [weak self] time in
                self?.update(time: time)
            },
            onGameEnd: { [weak self] statistic in
                self?.endGame(statistic: statistic)
            }
        )
        
        await self.start(game: game)
    }

    @MainActor
    func repeatGame() {
        guard let game = game else { return }
        game.reset()
        self.start(game: game)
    }
    
    @MainActor
    private func start(game newGame: Game) {
        self.game = newGame
        newGame.start()
        self.nextWord()
    }

    private func nextWord() {
        guard let game = self.game, !game.isGameOver else { return }
        game.nextRound()
        
        var cells = [WordCell.ViewModel]()
        for word in game.nextWords {
            let image = word.images.randomElement()!
            let cell = WordCell.ViewModel(id: word.id, name: word.name, image: image) { [weak self] in
                self?.tap(wordId: word.id)
            }
            cells.append(cell)
        }
        
        withAnimation(.easeIn(duration: 0.4)) {
            self.word = game.nextWord
            self.cells = cells
            self.objectWillChange.send()
        }
        
        isRound = true
    }
    
    private func tap(wordId: Int) {
        guard
            let game = self.game,
            let cell = cells.first(where: { $0.id == wordId }),
            isRound else { return }
        let result = game.put(wordId: wordId)
        
        lifeCount = game.lifeCount
        progress = game.progress

        cell.set(status: result ? .success : .fail)
        
        if result {
            isRound = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.nextWord()
            }
        }
    }
    
    private func update(time: String) {
        self.time = time
        self.objectWillChange.send()
    }
    
    private func endGame(statistic: Game.Statistic) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) { [weak self] in
            guard let self = self else { return }
            self.statistic = statistic
            self.isEndViewShown = true
            self.objectWillChange.send()
        }
    }

}


private extension Int {
    
    var winCount: Int {
        let a = Int((0.2 * Double(self) / 5).rounded() * 5)
        return a < self ? a : self
    }
    
}
