//
//  OptionsViewController.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 6. 28..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

/**
 * # 옵션 목록 화면
 *
 * **[PATH]** 내 프로필 화면 > '설정' 아이콘 탭
 */
class OptionsViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem.titleView = UILabel().then {
      $0.font = UIFont(name: "HelveticaNeue", size: 20)
      $0.text = "Options"
      $0.sizeToFit()
    }
  }

  func logoutButtonDidTap() {
    AuthService.instance.logout { (success) in
      if success {
        NotificationCenter.default.post(name: .presentLogin, object: nil, userInfo: nil)
      } else {

      }
    }
  }
}
