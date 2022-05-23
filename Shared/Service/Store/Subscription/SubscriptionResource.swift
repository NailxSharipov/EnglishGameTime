//
//  SubscriptionResource.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 18.05.2022.
//

import Foundation

final class SubscriptionResource {

    static let shared = SubscriptionResource()
    
    private static let saveKey = "isSubscribed"
    
    private (set) var isSubscribed: Bool {
        get {
            UserDefaults.standard.bool(forKey: Self.saveKey)
        }
        set {
            UserDefaults.standard.set(true, forKey: Self.saveKey)
        }
    }

}
