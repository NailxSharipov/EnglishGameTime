//
//  SkyScraperView.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 22.05.2022.
//

import SwiftUI

struct SkyScraperView: View {

    private static let ratio: CGFloat = 74 / 278
    
    let color: Color
    
    var body: some View {
        GeometryReader { proxy in
            self.layout(size: proxy.size)
        }
    }
    
    private func layout(size: CGSize) -> some View {
        return ZStack(alignment: .center) {
            Image("sky_scraper")
                .renderingMode(.template)
                .resizable()
                .foregroundColor(color)
                .frame(width: size.height * Self.ratio, height: size.height)
        }
    }
}
