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
            case fail
            case success
            case none
        }
        
        let id: Int
        let name: String
        let image: Image
        
        @Published
        private (set) var color: Color = .white
        
        @Published
        private (set) var scale: CGFloat = 1

        private let onTap: () -> ()
        
        init(id: Int, name: String, image: Image, onTap: @escaping () -> ()) {
            self.id = id
            self.name = name
            self.image = image
            self.onTap = onTap
        }
        
        func set(status: Status) {
            let newColor: Color
            switch status {
            case .none:
                newColor = .white
            case .success:
                newColor = .green
            case .fail:
                newColor = .red
            }
            
            withAnimation(.easeOut(duration: 0.1)) {
                color = newColor
            }
        }
        
        func onPress(event: PressAction.Event) {
            let newScale: CGFloat
            switch event {
            case .press:
                newScale = 1.03
            case .release:
                onTap()
                newScale = 1
            case .cancel:
                newScale = 1
            }

            withAnimation(.easeOut(duration: 0.08)) {
                scale = newScale
            }
        }
        
    }
}
