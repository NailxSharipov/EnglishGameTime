//
//  GameView+ViewModel.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 12.05.2022.
//

import SwiftUI

extension GameView {
    
    final class ViewModel: ObservableObject {

        private (set) var word: String = ""
        private (set) var time: String = ""
        private (set) var lifeCount: Int = 0
        private (set) var progress: Game.Progress = .init(value: 0, step: 0)
        
        private let resource: LessonResource
        private (set) var lessonId: Int = 0
        private (set) var cells: [WordCell.Item] = []
        private var game: Game?

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
    private func start(game newGame: Game) {
        self.game = newGame
        newGame.start()
        self.nextWord()
    }

    private func nextWord() {
        guard let game = self.game, !game.isGameOver else { return }
        game.nextCircle()
        
        var cells = [WordCell.Item]()
        for word in game.nextWords {
            let image = word.images.randomElement()!
            let cell = WordCell.Item(name: word.name, image: image, state: .none)
            cells.append(cell)
        }
        
        self.word = game.nextWord
        self.cells = cells
        self.objectWillChange.send()
    }
    
    func tap(word: String) {
        guard let game = self.game else { return }
        let result = game.put(word: word)
        
        lifeCount = game.lifeCount
        progress = game.progress
        
        self.animate(word: word, result: result) { [weak self] in
            self?.nextWord()
        }
    }
    
    private func update(time: String) {
        self.time = time
        self.objectWillChange.send()
    }
    
    private func endGame(statistic: Game.Statistic) {
        print(statistic)
    }
    
    private func animate(word: String, result: Bool, completion: @escaping () -> ()) {
        guard let index = cells.firstIndex(where: { $0.name == word }) else {
            assertionFailure("can not find cell")
            completion()
            return
        }
        withAnimation(.easeIn(duration: 0.3)) { [weak self] in
            guard let self = self else { return }
            cells[index].state = result ? .success : .fail
            self.objectWillChange.send()
        }

        
        completion()
    }
    
}


private extension Int {
    
    var winCount: Int {
        let a = Int((0.8 * Double(self) / 5).rounded() * 5)
        return a < self ? a : self
    }
    
}
