//
//  WordCell+ViewModel.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 15.05.2022.
//

import SwiftUI

extension WordCell {

    final class ViewModel: Identifiable, ObservableObject {
        
        enum Status {
            case none
            case success
            case fail
        }
        
        let id: Int
        let name: String
        let image: Image
        
        @Published
        var isCheck: Bool = false
        @Published
        var isCross: Bool = false
        @Published
        private (set) var blur: CGFloat = 0
        @Published
        private (set) var scale: CGFloat = 1

        private let onTap: () -> ()
        private let onPress: () -> ()
        
        init(id: Int, name: String, image: Image, onPress: @escaping () -> (), onTap: @escaping () -> ()) {
            self.id = id
            self.name = name
            self.image = image
            self.onPress = onPress
            self.onTap = onTap
        }
        
        func set(status: Status) {
            withAnimation(.easeOut(duration: 0.1)) { [weak self] in
                guard let self = self else { return }
                switch status {
                case .none:
                    self.blur = 0
                case .success:
                    self.blur = 8
                case .fail:
                    self.blur = 8
                }
            }
            
            withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) { [weak self] in
                guard let self = self else { return }
                switch status {
                case .none:
                    self.isCheck = false
                    self.isCheck = false
                case .success:
                    self.isCheck = true
                    self.isCross = false
                case .fail:
                    self.isCheck = false
                    self.isCross = true
                }
            }
        }
        
        func onPress(event: PressAction.Event) {
            let newScale: CGFloat
            switch event {
            case .press:
                onPress()
                newScale = 1.08
            case .release:
                onTap()
                newScale = 1
            case .cancel:
                newScale = 1
            }

            withAnimation(.easeOut(duration: 0.08)) { [weak self] in
                self?.scale = newScale
            }
        }
        
    }
}
