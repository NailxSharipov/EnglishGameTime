//
//  ReplicaSource.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 27.05.2022.
//

import SwiftUI

final class ReplicaSource {

    static let shared = ReplicaSource()
    
    private static let saveKey = "replicaIndex"
    
    private var index: Int {
        get {
            UserDefaults.standard.integer(forKey: Self.saveKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.saveKey)
        }
    }
    
    private let buffer: [Replica]

    init() {
        guard let url = Bundle.main.url(forResource: "replicas", withExtension: "json") else {
            buffer = []
            return
        }
        
        let decoder = JSONDecoder()
        guard let data = FileManager.default.contents(atPath: url.path) else {
            buffer = []
            return
        }
        
        do {
            buffer = try decoder.decode([Replica].self, from: data)
        } catch {
            debugPrint(error)
            assertionFailure("JSON error")
            buffer = []
        }
    }
    
    func next() -> Replica {
        guard !buffer.isEmpty else { return Replica(text: "You lose!", author: "Game") }
        let i = (self.index + 1) % buffer.count
        self.index = i

        return buffer[i]
    }
    
}
