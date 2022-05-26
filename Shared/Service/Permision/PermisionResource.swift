//
//  PermisionResource.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 18.05.2022.
//

import Foundation

final class PermisionResource {
    
    static let shared = PermisionResource()
    private static let freeLevelsCount = 2
    
    private let subscriptionResource: SubscriptionResource = .shared
    private let shareResource: ShareResource = .shared
    private let progressResource: ProgressResource = .shared

    func permissions() async -> Permission {
        guard !subscriptionResource.isSubscribed else {
            return .all
        }
        
        var set = Set<Int>(0...1)
        
        let anyWin = await progressResource.load().lessons.contains(where: { $0.lifeCount != nil })
        guard anyWin else {
            return .introduce(set)
        }
        
        if shareResource.isAnyFriendInvited {
            set.formUnion(2...3)
        }

        return .limit(set)
    }

    func isPermited(lessonId: Int) async -> Bool {
        switch await self.permissions() {
        case .all:
            return true
        case .introduce:
            return lessonId < Self.freeLevelsCount
        case .limit(let idSet):
            return idSet.contains(lessonId)
        }
        
    }
    
}
