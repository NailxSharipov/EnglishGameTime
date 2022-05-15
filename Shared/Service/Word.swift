//
//  Word.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 12.05.2022.
//

import Foundation
import SwiftUI

struct WordData: Decodable {

    let name: String
    let audio: String
    let images: [String]
    
}

struct Word {

    let id: Int
    let name: String
    let audio: String
    let images: [Image]
    
    init?(index: Int, root: URL, data: WordData) {
        var images = [Image]()
        for name in data.images {
            let path = root.add(name: name).path
            if let image = Image(file: path) {
                images.append(image)
            } else {
                assertionFailure("bad file \(name) at \(path)")
            }
        }
        guard !images.isEmpty else { return nil }
        audio = data.audio //root.add(name: data.audio)
        self.images = images
        name = data.name
        id = index
    }
    
}

private extension URL {
    
    func add(name: String) -> URL {
        self.appendingPathComponent(name, isDirectory: false)
    }
}
