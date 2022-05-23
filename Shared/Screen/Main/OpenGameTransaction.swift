//
//  OpenGameTransaction.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 16.05.2022.
//

import SwiftUI

extension MainView {
    
    enum OpenGameState {
        case closed
        case opend(OpenGameTransaction)
    }

}

struct OpenGameTransaction {
    
    let id: Int
    let onClose: (Bool) -> ()
}
