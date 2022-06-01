//
//  TrackingSystem.swift
//  BigBanEng
//
//  Created by Nail Sharipov on 01.06.2022.
//

enum TrackingSystemEvent: String {
    case subscription_open
    case subscription_try
    case subscription_user_cancel
    case subscription_system_fail
    case subscription_success
    case store_open
    case share_open
    case share_success
    case lesson_start
    case lesson_win
    case lesson_lose_timeEnd
    case lesson_lose_lifeEnd
}

protocol TrackingSystem {
    
    func track(event: TrackingSystemEvent, parameters: [String: Any]?)
    
    func track(event: TrackingSystemEvent)
    
}


extension TrackingSystem {
    
    func start(lesson: Lesson?) {
        guard let lesson = lesson else { return }
        self.track(event: .lesson_start, parameters: lesson.parameters)
    }
    
    func win(lesson: Lesson?) {
        guard let lesson = lesson else { return }
        self.track(event: .lesson_win, parameters: lesson.parameters)
    }

    func timeEnd(lesson: Lesson?) {
        guard let lesson = lesson else { return }
        self.track(event: .lesson_lose_timeEnd, parameters: lesson.parameters)
    }
    
    func lifeEnd(lesson: Lesson?) {
        guard let lesson = lesson else { return }
        self.track(event: .lesson_lose_lifeEnd, parameters: lesson.parameters)
    }
}


private extension Lesson {
    
    var parameters: [String: Any] {
        return [
            "id": meta.id,
            "name": meta.name
        ]
    }
}
