//
//  WordCell.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 13.05.2022.
//

import SwiftUI

struct WordCell: View {
    
    enum State {
        case fail
        case success
        case none
    }
    
    struct Item: Identifiable {
        var id: String { name }
        let name: String
        let image: Image
        var state: State
    }

    let item: Item
    
    var body: some View {
        ZStack {
            Rectangle().background(Color(state: item.state))
            item
                .image
                .resizable()
        }.cornerRadius(8)
    }
  
}

private extension Color {
    
    init(state: WordCell.State) {
        switch state {
        case .none:
            self = .white
        case .success:
            self = .green
        case .fail:
            self = .red
        }
    }
    
}
