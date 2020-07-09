//
//  AppDelegate.swift
//  Pollen Diary
//
//  Created by Wolfgang Sigel on 10.06.20.
//  Copyright © 2020 Wolfgang Sigel. All rights reserved.
//

import UIKit
import Network

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Network Availability
    let monitor = NWPathMonitor()
    static var networkAvailable = false
    let queue = DispatchQueue.global(qos: .background)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                AppDelegate.networkAvailable = true
            } else {
                AppDelegate.networkAvailable = false
            }
        }
        monitor.start(queue: self.queue)
        return true
    }
    
    class func isNetworkAvailable() -> Bool {
        return AppDelegate.networkAvailable
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        monitor.cancel()
    }
}

