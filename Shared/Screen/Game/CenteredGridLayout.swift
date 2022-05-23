//
//  CenteredGridLayout.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 14.05.2022.
//

import SwiftUI

struct CenteredGridLayout {
    
    let side: CGFloat
    let size: CGSize
    private let count: Int
    private let spacing: CGFloat
    
    var columns: [GridItem] {
        let grid = GridItem(.fixed(side), spacing: spacing)
        return Array<GridItem>(repeating: grid, count: count)
    }
    
    init(size: CGSize, count n: Int, minSpace s: CGFloat) {
        guard size.width > 0 && size.height > 0 && n > 0 else {
            side = 1
            count = 0
            spacing = 0
            self.size = .zero
            return
        }
        
        let pair = Self.bestPair(size: size, count: n)
        
        let n0 = Double(pair.a)
        let n1 = Double(pair.b)
        
        let a0 = ((size.width - s * (n0 - 1)) / n0).rounded(.toNearestOrAwayFromZero)
        let a1 = ((size.height - s * (n1 - 1)) / n1).rounded(.toNearestOrAwayFromZero)

        side = min(a0, a1)
        count = pair.a
        spacing = s
        
        let width = n0 * side + (n0 - 1) * s
        let height = n1 * side + (n1 - 1) * s
        
        self.size = CGSize(width: width, height: height)
    }
    
    private static func bestPair(size: CGSize, count n: Int) -> Pair {
        let pairs = n.allPairs

        var bestPair = pairs[0]
        var bestDelta: Double = .infinity
        
        let ratio = size.width / size.height
        
        for pair in pairs {
            let delta = abs(pair.ratio - ratio)
            if delta < bestDelta {
                bestDelta = delta
                bestPair = pair
            }
        }
        
        return bestPair
    }
    
}

private struct Pair {
    let a: Int
    let b: Int
    
    var ratio: Double { Double(a) / Double(b) }
}

private extension Int {
    
    var allPairs: [Pair] {
        let root = Int(Double(self).squareRoot())
        var result = [Pair]()
        
        for a in 1...root where self % a == 0 {
            let b = self / a
            result.append(Pair(a: a, b: b))
            result.append(Pair(a: b, b: a))
        }

        return result
    }

}
