//
//  AppDelegate_iOS.swift
//  EnglishGameTime (iOS)
//
//  Created by Nail Sharipov on 13.05.2022.
//

import UIKit
import SwiftUI
import FirebaseCore

final class AppDelegate_iOS: NSObject, UIApplicationDelegate, ObservableObject {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        debugPrint("didFinishLaunch")
        
        FirebaseApp.configure()
        
        return true
    }
}
