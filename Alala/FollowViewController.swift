//
//  FollowViewController.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 6. 27..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

/**
 * # 팔로워/팔로잉 목록 화면
 *
 * **[PATH]** 프로필 화면 > 팔로워/팔로잉 텍스트 터치 시 진입
 *
 * * 팔로워/팔로잉 두 화면의 UI가 동일하므로 FollowViewController에서 공통으로 지원하되
 * ViewController생성시 'FollowType'을 지정하여 구분하도록 한다.
 *
 */
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
