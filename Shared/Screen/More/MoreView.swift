//
//  MoreView.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 18.05.2022.
//

import SwiftUI

struct MoreView: View {

    @StateObject
    var viewModel: MoreView.ViewModel
    
    var body: some View {
        ZStack {
            Rectangle().fill(.green).cornerRadius(8)
            VStack {
                Button("Subscribe") {
                    
                }
                Button("Invite Friend") {
                    
                }
                Button("Close") {
                    
                }
            }.frame(height: 100, alignment: .center).padding(8)
        }
    }
}
