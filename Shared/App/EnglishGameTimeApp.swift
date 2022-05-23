//
//  EnglishGameTimeApp.swift
//  Shared
//
//  Created by Nail Sharipov on 12.05.2022.
//

import SwiftUI

@main
struct EnglishGameTimeApp: App {
    
#if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate_iOS.self) var appDelegate
#elseif os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate_macOS.self) var appDelegate
#endif
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
