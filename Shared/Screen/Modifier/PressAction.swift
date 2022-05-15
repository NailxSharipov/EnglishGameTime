//
//  PressAction.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 15.05.2022.
//

import SwiftUI

struct PressAction: ViewModifier {

    enum Event {
        case press
        case release
        case cancel
    }
    
    private let onUpdate: (Event) -> Void
    @State private var firstPress: Bool = true
    
    init(onUpdate: @escaping (Event) -> Void) {
        self.onUpdate = onUpdate
    }
    
    func body(content: Content) -> some View {
        GeometryReader() { proxy in
            content
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged({ data in
                            if firstPress {
                                onUpdate(.press)
                                firstPress = false
                            }
                        })
                        .onEnded({ data in
                            let inside = CGRect(origin: .zero, size: proxy.size).contains(data.location)
                            if inside {
                                onUpdate(.release)
                            } else {
                                onUpdate(.cancel)
                            }
                            firstPress = true
                        })
                )
        }
    }
}
