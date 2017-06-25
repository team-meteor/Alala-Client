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
  static var instance: AppDelegate? {
    return UIApplication.shared.delegate as? AppDelegate
  }

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    NotificationCenter.default.addObserver(self, selector: #selector(presentMainTabBarController), name: .presentMainTabBar, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(presentLoginViewController), name: .presentLogin, object: nil)
    self.configureAppearance()

    //window의 rootview 설정
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.backgroundColor = .white
    window.makeKeyAndVisible()
    window.rootViewController = SplashViewController()
    //window.rootViewController = WrapperViewController()
    self.window = window
    return true
  }

  func configureAppearance() {
    UINavigationBar.appearance().tintColor = .black
    UIBarButtonItem.appearance().tintColor = .black
    UITabBar.appearance().tintColor = .black
  }

  func presentLoginViewController() {
    let navigation = UINavigationController(rootViewController: LoginViewController())
    self.window?.rootViewController = navigation
  }

  func presentMainTabBarController() {
    DispatchQueue.main.async {
      let tabBarController = MainTabBarController()
      self.window?.rootViewController = tabBarController
    }
  }

}

extension Notification.Name {
  static var presentMainTabBar: Notification.Name { return .init("presentMainTabBar") }
  static var presentLogin: Notification.Name { return .init("presentLogin") }
}
