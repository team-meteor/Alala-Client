//
//  PersonalViewController.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class PersonalViewController: UIViewController {
  let logoutButton = UIButton().then {
    $0.setTitle("logout", for: .normal)
    $0.backgroundColor = $0.tintColor
    $0.layer.cornerRadius = 5
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    self.tabBarItem.image = UIImage(named: "personal")?.resizeImage(scaledTolength: 25)
    self.tabBarItem.selectedImage = UIImage(named: "personal-selected")?.resizeImage(scaledTolength: 25)
    self.tabBarItem.imageInsets.top = 5
    self.tabBarItem.imageInsets.bottom = -5
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.addSubview(logoutButton)
    self.logoutButton.snp.makeConstraints { (make) in
      make.center.equalTo(self.view)
    }
    self.logoutButton.addTarget(self, action: #selector(logoutButtonDidTap), for: .touchUpInside)
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
