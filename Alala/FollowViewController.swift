//
//  FollowViewController.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 6. 27..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class FollowViewController: UIViewController {

  enum FollowType: String {
    case follower  = "follower"
    case following = "following"
  }

  var currentType: String

  // MARK: - Initialize
  convenience init() {
    self.init(type:.follower)
  }

  init(type: FollowType) {
    currentType = type.rawValue

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    if(FollowType.follower.rawValue==currentType) {
      setupUIForFollowerType()
    } else {
      setupUIForFollowingType()
    }
  }

  func setupUIForFollowerType() {
    self.navigationItem.titleView = UILabel().then {
      $0.font = UIFont(name: "HelveticaNeue", size: 20)
      $0.text = "Followers"
      $0.sizeToFit()
    }
  }

  func setupUIForFollowingType() {
    self.navigationItem.titleView = UILabel().then {
      $0.font = UIFont(name: "HelveticaNeue", size: 20)
      $0.text = "Following"
      $0.sizeToFit()
    }
  }
}
