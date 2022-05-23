//
//  PermisionResource.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 18.05.2022.
//

import Foundation

final class PermisionResource {
    
    static let shared = PermisionResource()
    
    private let subscriptionResource: SubscriptionResource = .shared
    private let progressResource: ProgressResource = .shared
    private let lessonResource: LessonResource = .shared
    private let shareResource: ShareResource = .shared

    
    func permissions() async -> [Int: Permision] {
        let lessons = await lessonResource.readMeta()
        let progressMap = await progressResource.allLesson()
        
        let isShareBonus = shareResource.isAnyFriendInvited
        let isSubscribed = subscriptionResource.isSubscribed
        
        let lessonsCount = lessons.count
        let totalWin = progressMap.count
        var map = [Int: Permision]()

        for lesson in lessons {
            let permission = self.permission(
                id: lesson.id,
                lessonsCount: lessonsCount,
                totalWin: totalWin,
                isSubscribed: isSubscribed,
                isShareBonus: isShareBonus
            )
            map[lesson.id] = permission
        }

        return map
    }
    
    func permissions(id: Int) async -> Permision {
        let lessons = await lessonResource.readMeta()
        let progressMap = await progressResource.allLesson()
        
        let isShareBonus = shareResource.isAnyFriendInvited
        let isSubscribed = subscriptionResource.isSubscribed
        
        let lessonsCount = lessons.count
        let totalWin = progressMap.count
        
        let permission = self.permission(
            id: id,
            lessonsCount: lessonsCount,
            totalWin: totalWin,
            isSubscribed: isSubscribed,
            isShareBonus: isShareBonus
        )
        
        return permission
    }

    private func permission(id: Int, lessonsCount: Int, totalWin: Int, isSubscribed: Bool, isShareBonus: Bool) -> Permision {
        let permission: Permision

        if isSubscribed {
            let lastOpenIndex = totalWin + 3

            if id >= lessonsCount {
                permission = .coming
            } else if id < lastOpenIndex {
                permission = .opened
            } else {
                permission = .closed
            }
            
        } else {
            let avalibleCount = isShareBonus ? 6 : 3
            let lastOpenIndex = totalWin + 2

            if id == avalibleCount {
                permission = .more
            } else if id > avalibleCount {
                permission = .hidden
            } else if id < lastOpenIndex {
                permission = .opened
            } else {
                permission = .closed
            }
        }
        
        return permission
    }
    
    
}
