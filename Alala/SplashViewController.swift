//
//  SplashViewController.swift
//  Alala
//
//  Created by hoemoon on 15/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
  let userDataManager = UserDataManager.shared
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .blue
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    userDataManager.getMeWithCloud { (user) in
      if user != nil {
        NotificationCenter.default.post(name: .presentMainTabBar, object: nil, userInfo: nil)
      } else {
        NotificationCenter.default.post(name: .presentLogin, object: nil, userInfo: nil)
      }
    }
  }
}
