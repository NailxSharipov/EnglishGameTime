//
//  LessonCell.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 12.05.2022.
//

import SwiftUI

struct LessonCell: View {
    
    final class ViewModel: Identifiable, ObservableObject {
        
        struct OpenData {
            let title: String
            var lifeCount: Int?
        }
        
        enum Style {
            case opened(OpenData)       // can play
            case closed                 // locked
            case more                   // subdcribe
            case coming                 // coming soon
        }
        
        let id: Int
        var style: Style
        var isOpen: Bool = true
        
        init(id: Int, style: Style) {
            self.id = id
            self.style = style
        }
        
    }

    let color: Color
    let viewModel: ViewModel
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                switch viewModel.style {
                case .opened(let data):
                    Rectangle().fill(color).cornerRadius(8)
                    VStack {
                        Spacer()
                        if let lifeCount = data.lifeCount {
                            HStack {
                                Spacer()
                                self.heart(index: 0, lifeCount: lifeCount, size: proxy.size)
                                Spacer()
                                self.heart(index: 1, lifeCount: lifeCount, size: proxy.size)
                                Spacer()
                                self.heart(index: 2, lifeCount: lifeCount, size: proxy.size)
                                Spacer()
                            }
                            Spacer()
                        }
                        
                        Text(data.title)
                            .font(.system(size: 20, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white)
                        Spacer()
                    }
                case .closed:
                    Rectangle().fill(Color(white: 0, opacity: 0.5)).border(.gray, width: 4)
                        .cornerRadius(8)
                case .more:
                    Rectangle().fill(Color(red: 1, green: 1, blue: 0, opacity: 0.5)).border(.yellow, width: 4)
                        .cornerRadius(8)
                case .coming:
                    Rectangle().fill(Color(white: 0, opacity: 0.1)).border(.green, width: 4)
                        .cornerRadius(8)
                }
            }
        }
    }

    private func heart(index: Int, lifeCount: Int, size: CGSize) -> some View {
        let name = index < lifeCount ? "heart.fill" : "heart"
        let a = ceil(0.18 * size.width)
        return Image(systemName: name)
            .resizable()
            .frame(width: a, height: a, alignment: .center)
            .foregroundColor(.white)
    }
}
