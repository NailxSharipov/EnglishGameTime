//
//  ShareResource.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 18.05.2022.
//

import Foundation

final class ShareResource {
    
    static let shared = ShareResource()
    
    private static let saveKey = "isAnyFriendInvited"

    private (set) var isAnyFriendInvited: Bool {
        get {
            UserDefaults.standard.bool(forKey: Self.saveKey)
        }
        set {
            UserDefaults.standard.set(true, forKey: Self.saveKey)
        }
    }
    
    func didInviteFriend() -> Bool {
        guard isAnyFriendInvited else { return false }
        isAnyFriendInvited = true
        return true
    }

}
