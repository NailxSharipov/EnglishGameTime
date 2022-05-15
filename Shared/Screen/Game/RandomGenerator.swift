//
//  RandomGenerator.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 13.05.2022.
//

struct RandomGenerator {

    struct Round {
        let uniq: Int
        let list: [Int]
    }
    
    private var items: [Int]
    private var notUsed: Set<Int>
    
    init(size: Int) {
        items = [Int](repeating: 0, count: size)
        notUsed = Set<Int>(0..<size)
    }

    mutating func next(count: Int) -> Round {
        var list = [Int]()
        var set = Set(0..<items.count)
        
        let uniq = notUsed.removeRandom()

        list.append(uniq)
        set.remove(uniq)
        
        for _ in 1..<count {
            let index = self.next(set: set)
            set.remove(index)
            list.append(index)
        }
        
        self.decreaseWeight(indices: list)
        
        list.randomMix()
        
        return Round(uniq: uniq, list: list)
    }
    
    private func next(set: Set<Int>) -> Int {
        struct Element {
            let index: Int
            let weight: Double
        }
        
        let n = set.count
        assert(n > 0)
        guard n > 0 else { return 0 }

        let buffer = UnsafeMutablePointer<Element>.allocate(capacity: n)

        var sum: Double = 0
        var i = 0
        for index in set {
            let weight = 1 / Double(items[index])
            sum += weight
            buffer[i] = Element(index: index, weight: weight)
            i += 1
        }

        let random = Double.random(in: 0...1)
        let x = random / sum
        
        sum = 0
        i = 0
        repeat {
            sum += buffer[i].weight
            i += 1
        } while i < n && sum < x

        let randomIndex = buffer[i - 1].index
        
        buffer.deallocate()

        return randomIndex
    }

    private mutating func decreaseWeight(indices: [Int]) {
        for index in indices {
            items[index] += 1
        }
    }
    
}

private extension Array where Element == Int {
    
    mutating func randomMix() {
        let n = self.count
        let range = 0..<n
        for i in range {
            let j = Int.random(in: range)
            let a = self[i]
            self[i] = self[j]
            self[j] = a
        }
    }
    
}

private extension Set where Element == Int {
    
    mutating func removeRandom() -> Int {
        assert(!self.isEmpty)
        let item = self.randomElement() ?? 0
        self.remove(item)
        return item
    }

}
