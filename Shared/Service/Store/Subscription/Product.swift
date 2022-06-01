//
//  Product.swift
//  BigBanEng
//
//  Created by Nail Sharipov on 01.06.2022.
//

import StoreKit

extension Product {
    
    enum SubscriptionId: String {
        case monthly = "BigBanPerMonthId"
        case yearly = "BigBanPerYearId"
    }
    
    static var all: [String] {
        [SubscriptionId.monthly.rawValue, SubscriptionId.yearly.rawValue]
    }
    
    static var popularId: String {
        SubscriptionId.yearly.rawValue
    }
}
