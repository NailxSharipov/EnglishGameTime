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
                .fill(.white)
                .cornerRadius(8)
            viewModel.image.resizable().blur(radius: viewModel.blur)
            CheckView(visible: $viewModel.isCheck)
            CrossView(visible: $viewModel.isCross)
        }
        .scaleEffect(viewModel.scale)
        .padding(10)
        .modifier(PressAction(onUpdate: viewModel.onPress))
    }

}
