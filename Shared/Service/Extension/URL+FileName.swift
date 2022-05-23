//
//  URL+FileName.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 16.05.2022.
//

import Foundation

extension URL {
    
    func add(name: String) -> URL {
        self.appendingPathComponent(name, isDirectory: false)
    }
}
