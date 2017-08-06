//
//  FollowTableViewCell.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 7. 29..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import SnapKit

protocol FollowTableViewCellDelegate :class {
  func followingButtonDidTap(_ userInfo: User, _ sender: UIButton)
  func deleteButtonDidTap(_ userInfo: User, _ sender: UIButton)
}

extension FollowTableViewCellDelegate {
  func followingButtonDidTap(_ userInfo: User, _ sender: UIButton) {}
  func deleteButtonDidTap(_ userInfo: User, _ sender: UIButton) {}
}

class FollowTableViewCell: UITableViewCell {
  static let cellReuseIdentifier = "followCell"
  static let cellSeparatorInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
  static let cellHeight = 60

  var userInfo: User! {
    didSet {
      userIDLabel.text = userInfo.profileName

      if (userInfo.displayName?.characters.count)! > 0 {
        userNameLabel.text = userInfo.displayName
      } else {
        userNameLabel.text = userIDLabel.text
      }

      if userInfo.profilePhotoId != nil {
        userPhotoImageView.setImage(with: userInfo.profilePhotoId, size: .small)
      }
    }
  }

  weak var delegate: FollowTableViewCellDelegate?

  var isShowDeleteButton = false {
    didSet {
      if isShowDeleteButton == true {
        deleteButtonWidthConstraint?.update(offset: 30)
      } else {
        deleteButtonWidthConstraint?.update(offset: 0)
      }
    }
  }

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
    $0.font = UIFont.boldSystemFont(ofSize: 14.0)
    $0.text = "ID" // Label 높이 계산을 위한 DummyText
    $0.sizeToFit()
  }

  fileprivate let userNameLabel = UILabel().then {
    $0.font = UIFont(name: "HelveticaNeue", size: 14)
    $0.text = "Name" // Label 높이 계산을 위한 DummyText
    $0.textColor = UIColor.lightGray
    $0.sizeToFit()
  }

  fileprivate let followingButton = RoundCornerButton(.buttonColorTypeWhite).then {
    $0.setTitle(LS("button_following"), for: .normal)
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
  }
  fileprivate var followingButtonWidthConstraint: Constraint?

  fileprivate let deleteButton = UIButton().then {
    $0.setImage(UIImage(named: "more")?.resizeImage(scaledTolength: 10), for: .normal)
  }
  fileprivate var deleteButtonWidthConstraint: Constraint?

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.addSubview(userPhotoImageView)
    self.addSubview(userIDLabel)
    self.addSubview(userNameLabel)
    self.addSubview(followingButton)
    self.addSubview(deleteButton)

    self.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)

    userPhotoImageView.snp.makeConstraints { (make) in
      make.centerY.equalTo(self)
      make.left.equalTo(self).offset(10)
      make.width.equalTo(35)
      make.height.equalTo(35)
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

    followingButton.addTarget(self, action: #selector(followingButtonDidTap), for: .touchUpInside)
    followingButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self)
      make.right.equalTo(deleteButton.snp.left)
      make.height.equalTo(25)
      followingButtonWidthConstraint = make.width.equalTo(80).constraint
    }

    deleteButton.addTarget(self, action: #selector(deleteButtonDidTap), for: .touchUpInside)
    deleteButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self)
      make.right.equalTo(self).offset(-10)
      make.height.equalTo(25)
      deleteButtonWidthConstraint = make.width.equalTo(0).constraint
    }

  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func followingButtonDidTap() {
    guard delegate != nil, userInfo != nil else {return}

    delegate?.followingButtonDidTap(userInfo!, followingButton)
  }

  func deleteButtonDidTap() {
    guard delegate != nil, userInfo != nil else {return}

    delegate?.deleteButtonDidTap(userInfo!, deleteButton)
  }

}
