//
//  AppDelegate.swift
//  Alala
//
//  Created by hoemoon on 04/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import Then

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.configureAppearance()
        // Override point for customization after application launch.
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        window.rootViewController = MainTabBarController()
        
        self.window = window
        return true
    }
    
    func configureAppearance() {
        UINavigationBar.appearance().tintColor = .black
        UIBarButtonItem.appearance().tintColor = .black
        UITabBar.appearance().tintColor = .black
    }
}
