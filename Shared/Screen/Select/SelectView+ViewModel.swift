//
//  SelectView+ViewModel.swift
//  EnglishGameTime (iOS)
//
//  Created by Nail Sharipov on 12.05.2022.
//

import SwiftUI

extension SelectView {
    
    final class ViewModel: ObservableObject {
        
        var isOpenGame: Bool = false
        private let resource: LessonResource
        private (set) var selectedLessonId: Int = 0
        
        private (set) var cells: [LessonCell.Item] = []
        
        init(resource: LessonResource) {
            self.resource = resource
        }
    }
    
}

extension SelectView.ViewModel {

    private struct Design {
        static let coverImage = Image("lesson-cover")
    }
    
    func tap(id: Int) {
        selectedLessonId = id
        isOpenGame = true
        objectWillChange.send()
    }
    
    func load() async {
        let list = await resource.readMeta()
        
        var items = [LessonCell.Item]()

        for lesson in list {
            let item = LessonCell.Item(
                id: lesson.id,
                image: Design.coverImage,
                title: lesson.name,
                result: 0
            )
            
            items.append(item)
        }

        await self.set(cells: items)
    }
    
    @MainActor
    private func set(cells: [LessonCell.Item]) async {
        self.cells = cells
        self.objectWillChange.send()
    }
    
}
