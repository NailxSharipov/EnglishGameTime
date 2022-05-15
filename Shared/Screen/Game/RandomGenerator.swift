//
//  RandomGenerator.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 13.05.2022.
//

struct RandomGenerator {
    
    struct Item {
        let index: Int
        var count: Int
    }
    
    private var items: [Item]
    
    init(size: Int) {
        var items = [Item](repeating: Item(index: 0, count: 0), count: size)

        let range = 0..<size
        
        for i in range {
            items[i] = Item(index: i, count: 0)
        }
        
        for _ in 0..<3 * size {
            let i0 = Int.random(in: range)
            let i1 = Int.random(in: range)
            
            if i0 != i1 {
                let it = items[i0]
                items[i0] = items[i1]
                items[i1] = it
            }
        }
        
        self.items = items
    }

    mutating func getNext(count: Int) -> [Int] {
        items.sort(by: { $0.count < $1.count })
        var indices = [Int](repeating: 0, count: count)
        for i in 0..<count {
            indices[i] = items[i].index
            items[i].count += 1
        }
        return indices
    }
    
    mutating func addCount(index: Int, value: Int) {
        guard let i = items.firstIndex(where: { $0.index == index }) else { return }
        items[i].count += value
    }

}
