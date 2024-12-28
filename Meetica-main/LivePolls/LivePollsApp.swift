//
//  LivePollsApp.swift
//  LivePolls
//
//  Created by Efe Koç on 09/07/23.
//

import FirebaseCore
import FirebaseFirestore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        let settings = Firestore.firestore().settings
        
        settings.cacheSettings = MemoryCacheSettings()
        Firestore.firestore().settings = settings
        
        return true
    }
    
}

@main
struct LivePollsApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SignupView()
            }
        }
    }
}
