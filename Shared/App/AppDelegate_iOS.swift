//
//  AppDelegate_iOS.swift
//  EnglishGameTime (iOS)
//
//  Created by Nail Sharipov on 13.05.2022.
//

import UIKit
import SwiftUI

final class AppDelegate_iOS: NSObject, UIApplicationDelegate, ObservableObject {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        debugPrint("didFinishLaunch")
        return true
    }
}
