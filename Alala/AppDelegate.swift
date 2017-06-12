//
//  AppDelegate.swift
//  Alala
//
//  Created by hoemoon on 04/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import Then
import Kingfisher
import SnapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    //앱 실행시 가장 먼저 setting되는 것들
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //네비게이션바, 탭바
        self.configureAppearance()
        
        //window의 rootview 설정
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
