//
//  GeometryProxy.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 23.05.2022.
//

import SwiftUI

extension GeometryProxy {
    
    var isIPad: Bool {
        min(size.width, size.height) > 400
    }
    
}
