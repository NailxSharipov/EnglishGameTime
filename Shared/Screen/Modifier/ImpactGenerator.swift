//
//  ImpactGenerator.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 23.05.2022.
//

#if os(iOS)

import UIKit

final class ImpactGenerator {
    
    static let share = ImpactGenerator()
    
    private var _generator: UINotificationFeedbackGenerator?
    private var generator: UINotificationFeedbackGenerator? {
        get {
            if _generator == nil {
                _generator = UINotificationFeedbackGenerator()
            }
            return _generator
        }
        set {
            if newValue == nil {
                _generator = nil
            }
        }
    }
    
    func prepare() {
        generator?.prepare()
    }
    
    func sendError() {
        generator?.notificationOccurred(.error)
    }
    
}
#else
final class ImpactGenerator {
    static let share = ImpactGenerator()
    func prepare() {}
    func sendError() {}
}
#endif


