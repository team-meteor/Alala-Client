//
//  PeoplesTableViewCell.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 7. 31..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import SnapKit

protocol PeoplesTableViewCellDelegate :class {
  func followingButtonDidTap(_ userInfo: User, _ sender: UIButton)
  func hideButtonDidTap(_ userInfo: User, _ sender: UIButton)
}

extension PeoplesTableViewCellDelegate {
  func followingButtonDidTap(_ userInfo: User, _ sender: UIButton) {}
  func hideButtonDidTap(_ userInfo: User, _ sender: UIButton) {}
}

class PeoplesTableViewCell: UITableViewCell {
  static let cellReuseIdentifier = "peoplesCell"
  static let cellSeparatorInsets = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)
  static let cellHeight = 75

  var userInfo: User! {
    didSet {
      userIDLabel.text = userInfo.profileName

      if (userInfo.displayName?.characters.count)! > 0 {
        userNameLabel.text = userInfo.displayName
      } else {
        userNameLabel.text = userIDLabel.text
      }

      if userInfo.profilePhotoId != nil {
        userPhotoImageView.setImage(with: userInfo.profilePhotoId, size: .medium)
      }
    }
  }

  weak var delegate: PeoplesTableViewCellDelegate?

  var isSetFollowButton = false {
    didSet {
      if isSetFollowButton == true {
        followingButton.setTitle(LS("button_follow"), for: .normal)
        followingButton.setButtonType(.buttonColorTypeBlue)   // Blue Button : '팔로우'
      } else {
        followingButton.setTitle(LS("button_following"), for: .normal)
        followingButton.setButtonType(.buttonColorTypeWhite)  // White Button : '팔로잉'
      }
    }
  }

  fileprivate let userPhotoImageView = CircleImageView().then {
    $0.layer.borderWidth = 1
    $0.layer.masksToBounds = false
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.clipsToBounds = true
    $0.isUserInteractionEnabled = true
  }

  fileprivate let userIDLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 14)
    $0.text = LS("id")
    $0.sizeToFit()
  }

  fileprivate let userNameLabel = UILabel().then {
    $0.font = UIFont(name: "HelveticaNeue", size: 14)
    $0.text = LS("name")
    $0.textColor = UIColor.lightGray
    $0.sizeToFit()
  }

  fileprivate let suggestionLabel = UILabel().then {
    $0.font = UIFont(name: "HelveticaNeue", size: 12)
    $0.text = LS("Instagram 신규가입")
    $0.textColor = UIColor.lightGray
    $0.sizeToFit()
  }

  fileprivate let followingButton = RoundCornerButton(.buttonColorTypeWhite).then {
    $0.setTitle(LS("button_following"), for: .normal)
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
  }

  fileprivate var followButtonWidthConstraint: Constraint?

  fileprivate var followingButtonWidthConstraint: Constraint?

  fileprivate let hideButton = RoundCornerButton(.buttonColorTypeWhite).then {
    $0.setTitle(LS("button_hide"), for: .normal)
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
  }
  fileprivate var hideButtonWidthConstraint: Constraint?

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.addSubview(userPhotoImageView)
    self.addSubview(userIDLabel)
    self.addSubview(userNameLabel)
    self.addSubview(suggestionLabel)
    self.addSubview(followingButton)
    self.addSubview(hideButton)

    userPhotoImageView.snp.makeConstraints { (make) in
      make.top.equalTo(self).offset(5)
      make.left.equalTo(self).offset(10)
      make.width.equalTo(50)
      make.height.equalTo(50)
    }

    userIDLabel.sizeToFit()
    userIDLabel.snp.makeConstraints { (make) in
      make.left.equalTo(userPhotoImageView.snp.right).offset(10)
      make.right.equalTo(followingButton.snp.left)
      make.bottom.equalTo(userPhotoImageView.snp.centerY)
      make.height.equalTo(userIDLabel.frame.height)
    }

    userNameLabel.sizeToFit()
    userNameLabel.snp.makeConstraints { (make) in
      make.top.equalTo(userIDLabel.snp.bottom)
      make.left.equalTo(userIDLabel)
      make.right.equalTo(userIDLabel)
      make.height.equalTo(userNameLabel.frame.height)
    }

    suggestionLabel.snp.makeConstraints { (make) in
      make.top.equalTo(userPhotoImageView.snp.bottom)
      make.left.equalTo(userIDLabel)
      make.right.equalTo(self)
      make.bottom.equalTo(self).offset(-5)
    }

    hideButton.addTarget(self, action: #selector(hideButtonDidTap), for: .touchUpInside)
    hideButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(userPhotoImageView)
      make.right.equalTo(self).offset(-10)
      make.height.equalTo(25)
      hideButtonWidthConstraint = make.width.equalTo(60).constraint
    }

    followingButton.addTarget(self, action: #selector(followingButtonDidTap), for: .touchUpInside)
    followingButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(userPhotoImageView)
      make.right.equalTo(hideButton.snp.left).offset(-5)
      make.height.equalTo(25)
      followingButtonWidthConstraint = make.width.equalTo(60).constraint
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func followingButtonDidTap() {
    guard delegate != nil, userInfo != nil else {return}

    delegate?.followingButtonDidTap(userInfo!, followingButton)
  }

  func hideButtonDidTap() {
    guard delegate != nil, userInfo != nil else {return}

    delegate?.hideButtonDidTap(userInfo!, hideButton)
  }
}
