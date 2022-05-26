//
//  ColorResource.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 24.05.2022.
//

import SwiftUI

final class ColorResource {

    static let shared = ColorResource()
    
    private static let saveKey = "colorIndex"
    
    private var index: Int {
        get {
            UserDefaults.standard.integer(forKey: Self.saveKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.saveKey)
        }
    }
    
    private (set) var color: Color
    private (set) var colorIndex: Int
    
    let colors: [Color] = [
        .pink,
        .purple,
        .indigo,
        .gray
    ]
    
    func set(index: Int) {
        let i = index % colors.count
        colorIndex = i
        color = colors[i]
        self.index = index
    }
    
    
    init() {
        color = .black
        colorIndex = 0
        colorIndex = index % colors.count
        color = colors[colorIndex]
    }
}
