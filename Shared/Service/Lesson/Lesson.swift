//
//  Lesson.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 12.05.2022.
//

import Foundation

struct Lesson {
    
    struct Meta {
        
        let id: Int
        let name: String
        
        init(data: LessonData) {
            id = data.id
            name = data.name
        }
        
    }

    let meta: Meta
    let words: [Word]
    
    init(data: LessonData) {
        meta = Meta(data: data)
        let n = data.words.count
        var list = [Word]()
        list.reserveCapacity(n)
        var i = 0
        for item in data.words {
            if let word = Word(index: i, root: data.root, data: item) {
                list.append(word)
                i += 1
            }
        }
        words = list
    }
    
}

struct LessonData {
    
    let id: Int
    let name: String
    let root: URL
    let words: [WordData]
    
    struct Data: Decodable {
        let id: Int
        let name: String
        let words: [WordData]
    }

    init(root: URL, data: Data) {
        self.root = root
        self.id = data.id
        self.name = data.name
        self.words = data.words
    }
    
}
