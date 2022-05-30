//
//  LessonCell.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 12.05.2022.
//

import SwiftUI

struct LessonCell: View {
    
    final class ViewModel: Identifiable, ObservableObject {
        
        struct Lesson {
            let title: String
            var lifeCount: Int
        }
        
        enum Style {
            case won
            case open
            case pay
        }
        
        let id: Int
        let lesson: Lesson
        var style: Style
        var isOpen: Bool = true
        
        init(id: Int, lesson: Lesson, style: Style) {
            self.id = id
            self.lesson = lesson
            self.style = style
        }
        
    }

    let color: Color
    let viewModel: ViewModel
    
    var body: some View {
        GeometryReader { proxy in
            switch viewModel.style {
            case .won:
                ZStack(alignment: .center) {
                    Rectangle().fill(color).cornerRadius(8)
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            self.heart(index: 0, lifeCount: viewModel.lesson.lifeCount, size: proxy.size)
                            Spacer()
                            self.heart(index: 1, lifeCount: viewModel.lesson.lifeCount, size: proxy.size)
                            Spacer()
                            self.heart(index: 2, lifeCount: viewModel.lesson.lifeCount, size: proxy.size)
                            Spacer()
                        }
                        Spacer()
                        Text(viewModel.lesson.title)
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Spacer()
                    }
                }
            case .open:
                ZStack(alignment: .center) {
                    Rectangle().fill(color).cornerRadius(8)
                    Text(viewModel.lesson.title)
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                        .opacity(0.6)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            case .pay:
                ZStack(alignment: .center) {
                    Text(viewModel.lesson.title)
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundColor(color)
                        .padding(4)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(style: .init(lineWidth: 4, lineCap: .round, lineJoin: .round, dash: [16, 16]))
                        .foregroundColor(color).background(.white)
                }.opacity(0.5)
            }
        }
    }

    private func heart(index: Int, lifeCount: Int, size: CGSize) -> some View {
        let name = index < lifeCount ? "heart.fill" : "heart"
        let a = ceil(0.18 * size.width)
        return Image(systemName: name)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: a, height: a, alignment: .center)
            .foregroundColor(.white)
    }
}
