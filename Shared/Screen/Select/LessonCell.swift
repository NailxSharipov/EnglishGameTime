//
//  LessonCell.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 12.05.2022.
//

import SwiftUI

struct LessonCell: View {
    
    struct Item: Identifiable {
        let id: Int
        let image: Image
        let title: String
        let result: Int
    }

    let item: Item
    
    var body: some View {
        ZStack {
            item
                .image
                .resizable(
                ).cornerRadius(8)
            Text(item.title)
        }
    }
  
}
