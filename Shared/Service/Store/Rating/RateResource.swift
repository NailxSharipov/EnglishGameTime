//
//  RateResource.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 23.05.2022.
//

import Foundation
import StoreKit

#if os(iOS)
import SwiftUI
#endif

//https://www.raywenderlich.com/9009-requesting-app-ratings-and-reviews-tutorial-for-ios
final class RateResource {

    static let shared = RateResource()

    private static let saveKey = "isRated"

    private let progressResource: ProgressResource = .shared
    private (set) var isRated: Bool {
        get {
            UserDefaults.standard.bool(forKey: Self.saveKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.saveKey)
        }
    }
    
    func rate() {
        guard !isRated else { return }
        
        Task {
            let lessons = await progressResource.allLesson()
            var count = 0
            for lesson in lessons {
                count += lesson.value.lifeCount ?? 0
            }
            
            if count >= 5 {
                await self.requestReview()
            }
        }
    }
    
    @MainActor
    private func requestReview() async {
#if os(iOS)
        let scenes = UIApplication.shared.connectedScenes
        let scene = scenes.filter { $0.activationState == .foregroundActive }.first(where: { $0 is UIWindowScene })
        guard let windowScene = scene as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: windowScene)
        isRated = true
#endif
    }
    
}
