//
//  WordCell.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 13.05.2022.
//

import SwiftUI

struct WordCell: View {

    @ObservedObject
    var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            Rectangle()
                .background(viewModel.color)
                .cornerRadius(8)
            viewModel.image
                .resizable()
        }
        .scaleEffect(viewModel.scale)
        .padding(10)
        .modifier(PressAction(onUpdate: viewModel.onPress))
    }
  
}
