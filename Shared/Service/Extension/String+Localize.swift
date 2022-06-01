//
//  String+Localize.swift
//  BigBanEng
//
//  Created by Nail Sharipov on 30.05.2022.
//

import Foundation

extension String {
    
    var locolize: String {
        let translate = NSLocalizedString(self, comment: "")
        return translate
    }
}

