//
//  GoogleAnalytics.swift
//  BigBanEng
//
//  Created by Nail Sharipov on 01.06.2022.
//

import FirebaseAnalytics

final class GoogleAnalytics: TrackingSystem {
    
    static let shared = GoogleAnalytics()
    
    func track(event: TrackingSystemEvent, parameters: [String: Any]?) {
        Analytics.logEvent(event.rawValue, parameters: parameters)
    }
    
    func track(event: TrackingSystemEvent) {
        Analytics.logEvent(event.rawValue, parameters: nil)
    }
}
