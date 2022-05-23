//
//  MainView+ViewModel.swift
//  EnglishGameTime (iOS)
//
//  Created by Nail Sharipov on 12.05.2022.
//

import SwiftUI

extension MainView {
    
    final class ViewModel: ObservableObject {

        var isShareOpen: Bool = false
        var isMain: Bool {
            switch openGameState {
            case .closed:
                return true
            case .opend:
                return false
            }
        }
        
        private (set) var shareLink: URL = Bundle.main.bundleURL
        private let lessonResource: LessonResource
        private let audioResource: AudioResource
        private let progressResource: ProgressResource
        private let permisionResource: PermisionResource
        private let rateResource: RateResource
        private let shareResource: ShareResource
        private (set) var openGameState: OpenGameState = .closed
        private (set) var cells: [LessonCell.ViewModel] = []
        
        init(resource: LessonResource, audioResource: AudioResource, progressResource: ProgressResource, permisionResource: PermisionResource, rateResource: RateResource, shareResource: ShareResource) {
            self.lessonResource = resource
            self.audioResource = audioResource
            self.progressResource = progressResource
            self.permisionResource = permisionResource
            self.rateResource = rateResource
            self.shareResource = shareResource
        }
    }
    
}

extension MainView.ViewModel {

    func tap(id: Int) {
        guard let cell = cells.first(where: { $0.id == id }) else { return }
        
        let transaction = OpenGameTransaction(id: id) { [weak self] success in
            self?.close(id: id, success: success)
        }
        
        self.audioResource.play(sound: .start)
        
        withAnimation() { [weak self, weak cell] in
            cell?.isOpen = false
            self?.openGameState = .opend(transaction)
            self?.objectWillChange.send()
        }
    }
    
    private func close(id: Int, success: Bool) {
        guard let cell = cells.first(where: { $0.id == id }) else { return }
        withAnimation() { [weak self, weak cell] in
            cell?.isOpen = true
            self?.openGameState = .closed
            self?.objectWillChange.send()
        }

        Task { [weak self] in
            await self?.load()
        }
        
        if success {
            rateResource.rate()
        }
    }
    
    func load() async {
        await self.reloadCells()
        await self.audioResource.play(music: .main)
    }
    
    private func reloadCells() async {
        let list = await lessonResource.readMeta()
        let progressMap = await progressResource.allLesson()
        let permisionMap = await permisionResource.permissions()
        
        var cells = [LessonCell.ViewModel]()
        
        for lesson in list {
            let permision = permisionMap[lesson.id] ?? .coming
            let style: LessonCell.ViewModel.Style
            switch permision {
            case .opened:
                let lifeCount = progressMap[lesson.id]?.lifeCount
                style = .opened(.init(title: lesson.name, lifeCount: lifeCount))
            case .closed:
                style = .closed
            case .more:
                style = .more
            case .coming:
                style = .coming
            case .hidden:
                continue
            }

            let cell = LessonCell.ViewModel(
                id: lesson.id,
                style: style
            )
            
            cells.append(cell)
        }

        await self.set(cells: cells)
    }
    
    @MainActor
    private func set(cells: [LessonCell.ViewModel]) async {
        self.cells = cells
        self.objectWillChange.send()
    }
    
    func pressShare() {
        guard let url = Self.storeLink, !isShareOpen else { return }
        self.shareLink = url
        self.isShareOpen = true
        self.objectWillChange.send()
    }
    
    func onSuccessShare() {
        if shareResource.didInviteFriend() {
            Task { [weak self] in
                await self?.reloadCells()
            }
        }
    }
    
    private static var storeLink: URL? {
        let locale = Locale.current
        guard let country = locale.regionCode else { return nil }
        let appName = ""
        let appId = ""
        let string = "https://apps.apple.com/\(country)/app/\(appName)/id\(appId)"
        
        return URL(string: string)
    }
    
}
