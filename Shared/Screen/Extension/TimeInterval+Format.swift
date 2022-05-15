//
//  TimeInterval+Format.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 13.05.2022.
//

import Foundation

extension TimeInterval {
    
    var cleanFormat: String {
        let time = Int(max(0, self))
        
        let min = time / 60
        let sec = time % 60
        
        return "\(min.cleanFormat):\(sec.cleanFormat)"
    }
    
}

extension Int {
    
    var cleanFormat: String {
        self < 10 ? "0\(self)" : String(self)
    }
    
}
