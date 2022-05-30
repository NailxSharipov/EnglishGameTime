//
//  MainView+ViewModel.swift
//  EnglishGameTime (iOS)
//
//  Created by Nail Sharipov on 12.05.2022.
//

#if os(iOS)
import UIKit
#endif
import SwiftUI

extension MainView {
    
    final class ViewModel: ObservableObject {

        var isShareTipVisible: Bool = false
        var isSubscriptionOpen: Bool = false
        var isShareOpen: Bool = false
        var isMain: Bool {
            switch openGameState {
            case .closed:
                return true
            case .opend:
                return false
            }
        }
        
        var name: String { "Big Ban English" }
        var isIntroduction: Bool { cells.count < 3 }
        
        private (set) var color: Color
        private (set) var colorIndex: Int
        var colors: [Color] { colorResource.colors }

        private (set) var shareLink: URL = Bundle.main.bundleURL
        private let lessonResource: LessonResource
        private let audioResource: AudioResource
        private let progressResource: ProgressResource
        private let permisionResource: PermisionResource
        private let rateResource: RateResource
        private let shareResource: ShareResource
        private let colorResource: ColorResource
        private let subscriptionResource: SubscriptionResource
        private (set) var openGameState: OpenGameState = .closed
        private (set) var cells: [LessonCell.ViewModel] = []
        
        init(resource: LessonResource, audioResource: AudioResource, progressResource: ProgressResource, permisionResource: PermisionResource, rateResource: RateResource, shareResource: ShareResource, colorResource: ColorResource, subscriptionResource: SubscriptionResource) {
            self.lessonResource = resource
            self.audioResource = audioResource
            self.progressResource = progressResource
            self.permisionResource = permisionResource
            self.rateResource = rateResource
            self.shareResource = shareResource
            self.colorResource = colorResource
            self.subscriptionResource = subscriptionResource
            color = colorResource.color
            colorIndex = colorResource.colorIndex
        }
    }
    
}

extension MainView.ViewModel {

    func tap(id: Int) {
        guard let cell = cells.first(where: { $0.id == id }) else { return }
        
        guard self.permisionResource.isPermited(lessonId: id) else {
            isSubscriptionOpen = true
            objectWillChange.send()
            return
        }

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
            guard let self = self else { return }
            await self.load()
            let winCounts = await self.progressResource.winCounts()
            
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                if success {
                    let isRated = self.rateResource.isRated
                    let isShared = self.shareResource.isAnyFriendInvited
                    
                    let askRate = !isRated && winCounts > 5
                    let askShare = !isShared && !self.subscriptionResource.isSubscribed
                    
                    if askRate && askShare {
                        if Bool.random() {
                            self.rateResource.rate()
                        } else {
                            self.isShareTipVisible = true
                            self.objectWillChange.send()
                        }
                    } else if askRate {
                        rateResource.rate()
                    } else if askShare {
                        isShareTipVisible = true
                        self.objectWillChange.send()
                    }
                }
            }
        }
    }
    
    func load() async {
        await self.reloadCells()
        await self.audioResource.play(music: .main)
    }
    
    private func reloadCells() async {
        let list = await lessonResource.readMeta()
        let progressMap = await progressResource.allLesson()
        let permision = await permisionResource.permissions()
        
        var cells = [LessonCell.ViewModel]()
        
        switch permision {
        case .all:
            for lesson in list {
                let lifeCount = progressMap[lesson.id]?.lifeCount

                let cell = LessonCell.ViewModel(
                    id: lesson.id,
                    lesson: .init(title: lesson.name, lifeCount: lifeCount ?? 0),
                    style: lifeCount != nil ? .won : .open
                )
                
                cells.append(cell)
            }
        case .introduce(let idSet):
            for lesson in list where idSet.contains(lesson.id) {
                let lifeCount = progressMap[lesson.id]?.lifeCount

                let cell = LessonCell.ViewModel(
                    id: lesson.id,
                    lesson: .init(title: lesson.name, lifeCount: lifeCount ?? 0),
                    style: lifeCount != nil ? .won : .open
                )
                cells.append(cell)
            }
        case .limit(let idSet):
            for lesson in list {
                let lifeCount = progressMap[lesson.id]?.lifeCount

                let style: LessonCell.ViewModel.Style
                if !idSet.contains(lesson.id) {
                    style = .pay
                } else if lifeCount != nil {
                    style = .won
                } else {
                    style = .open
                }
                
                let cell = LessonCell.ViewModel(
                    id: lesson.id,
                    lesson: .init(title: lesson.name, lifeCount: lifeCount ?? 0),
                    style: style
                )
                
                cells.append(cell)
            }
        }

        await self.set(cells: cells)
    }
    
    @MainActor
    private func set(cells: [LessonCell.ViewModel]) async {
        self.cells = cells
        self.objectWillChange.send()
    }
    
    func pressShare() {
        guard let url = rateResource.storeLink, !isShareOpen else { return }
        self.shareLink = url
        self.isShareOpen = true
        self.objectWillChange.send()
    }
    
    func pressStore() {
#if os(iOS)
        guard let url = rateResource.storeLink else { return }
        UIApplication.shared.open(url)
#endif
    }
    
    func pressCloseInviteFriend() {
        isShareTipVisible = false
        self.objectWillChange.send()
    }
    
    func onSuccessShare() {
        if shareResource.didInviteFriend() {
            Task { [weak self] in
                await self?.reloadCells()
            }
        }
    }

    
    func setColor(index: Int) {
        colorResource.set(index: index)
        withAnimation(.linear(duration: 0.5)) { [weak self] in
            guard let self = self else { return }
            self.color = colorResource.color
            self.colorIndex = colorResource.colorIndex
            self.objectWillChange.send()
        }
    }
}
