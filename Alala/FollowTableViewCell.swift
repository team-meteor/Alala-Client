//
//  FollowTableViewCell.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 7. 29..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit
import SnapKit

protocol FollowTableViewCellDelegate :class {
  func followButtonDidTap(_ userInfo: User, _ sender: UIButton)
  func followingButtonDidTap(_ userInfo: User, _ sender: UIButton)
  func hideButtonDidTap(_ userInfo: User, _ sender: UIButton)
  func deleteButtonDidTap(_ userInfo: User, _ sender: UIButton)
}

extension FollowTableViewCellDelegate {
  func followButtonDidTap(_ userInfo: User, _ sender: UIButton) {}
  func followingButtonDidTap(_ userInfo: User, _ sender: UIButton) {}
  func hideButtonDidTap(_ userInfo: User, _ sender: UIButton) {}
  func deleteButtonDidTap(_ userInfo: User, _ sender: UIButton) {}
}

class FollowTableViewCell: UITableViewCell {
  static let cellReuseIdentifier = "followCell"
  static let cellSeparatorInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)

  var userInfo: User! {
    didSet {
      userIDLabel.text = userInfo.profileName
      userNameLabel.text = userInfo.displayName
      if userInfo.profilePhotoId != nil {
        userPhotoImageView.setImage(with: userInfo.profilePhotoId, size: .small)
      }
    }
  }

  weak var delegate: FollowTableViewCellDelegate?

  var isShowFollowButton = false {
    didSet {
      if isShowFollowButton == true {
        followButtonWidthConstraint?.update(offset: 80)
      } else {
        followButtonWidthConstraint?.update(offset: 0)
      }
    }
  }

  var isShowFollowingButton = false {
    didSet {
      if isShowFollowingButton == true {
        followingButtonWidthConstraint?.update(offset: 80)
      } else {
        followingButtonWidthConstraint?.update(offset: 0)
      }
    }
  }

  var isShowHideButton = false {
    didSet {
      if isShowHideButton == true {
        hideButtonWidthConstraint?.update(offset: 80)
      } else {
        hideButtonWidthConstraint?.update(offset: 0)
      }
    }
  }

  var isShowDeleteButton = false {
    didSet {
      if isShowDeleteButton == true {
        deleteButtonWidthConstraint?.update(offset: 20)
      } else {
        deleteButtonWidthConstraint?.update(offset: 0)
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
    $0.font = UIFont.boldSystemFont(ofSize: 12.0)
    $0.text = LS("id")
    $0.sizeToFit()
  }

  fileprivate let userNameLabel = UILabel().then {
    $0.font = UIFont(name: "HelveticaNeue", size: 12)
    $0.text = LS("name")
    $0.textColor = UIColor.lightGray
    $0.sizeToFit()
  }

  fileprivate let followButton = RoundCornerButton(type: .buttonColorTypeBlue).then {
    $0.setTitle(LS("button_follow"), for: .normal)
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
  }
  fileprivate var followButtonWidthConstraint: Constraint?

  fileprivate let followingButton = RoundCornerButton(type: .buttonColorTypeWhite).then {
    $0.setTitle(LS("button_following"), for: .normal)
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
  }
  fileprivate var followingButtonWidthConstraint: Constraint?

  fileprivate let hideButton = RoundCornerButton(type: .buttonColorTypeWhite).then {
    $0.setTitle(LS("button_hide"), for: .normal)
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
  }
  fileprivate var hideButtonWidthConstraint: Constraint?

  fileprivate let deleteButton = UIButton().then {
    $0.setImage(UIImage(named: "more")?.resizeImage(scaledTolength: 10), for: .normal)
  }
  fileprivate var deleteButtonWidthConstraint: Constraint?

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.addSubview(userPhotoImageView)
    self.addSubview(userIDLabel)
    self.addSubview(userNameLabel)
    self.addSubview(followButton)
    self.addSubview(followingButton)
    self.addSubview(hideButton)
    self.addSubview(deleteButton)

    userPhotoImageView.snp.makeConstraints { (make) in
      make.centerY.equalTo(self)
      make.left.equalTo(self).offset(10)
      make.width.equalTo(30)
      make.height.equalTo(30)
    }

    userIDLabel.snp.makeConstraints { (make) in
      make.top.equalTo(self).offset(8)
      make.left.equalTo(userPhotoImageView.snp.right).offset(8)
      make.right.equalTo(followButton.snp.left)
      make.bottom.equalTo(userNameLabel.snp.top)
    }

    userNameLabel.snp.makeConstraints { (make) in
      make.top.equalTo(userIDLabel.snp.bottom)
      make.left.equalTo(userIDLabel)
      make.right.equalTo(userIDLabel)
      make.bottom.equalTo(self).offset(-8)
    }

    followButton.addTarget(self, action: #selector(followButtonDidTap), for: .touchUpInside)
    followButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self)
      make.right.equalTo(hideButton.snp.left).offset(-5)
      make.height.equalTo(25)
      followButtonWidthConstraint = make.width.equalTo(0).constraint
    }

    followingButton.addTarget(self, action: #selector(followingButtonDidTap), for: .touchUpInside)
    followingButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self)
      make.right.equalTo(hideButton.snp.left).offset(-5)
      make.height.equalTo(25)
      followingButtonWidthConstraint = make.width.equalTo(0).constraint
    }

    hideButton.addTarget(self, action: #selector(hideButtonDidTap), for: .touchUpInside)
    hideButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self)
      make.right.equalTo(deleteButton.snp.left).offset(-5)
      make.height.equalTo(25)
      hideButtonWidthConstraint = make.width.equalTo(0).constraint
    }

    deleteButton.addTarget(self, action: #selector(deleteButtonDidTap), for: .touchUpInside)
    deleteButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self)
      make.right.equalTo(self).offset(-5)
      make.height.equalTo(25)
      deleteButtonWidthConstraint = make.width.equalTo(0).constraint
    }

//    if (AuthService.instance.currentUser?.following?.contains(userInfo))! {
//      followButton.snp.updateConstraints { make in
//        make.width.equalTo(0)
//      }
//      followingButton.snp.updateConstraints { make in
//        make.width.equalTo(80)
//      }
//    }

  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func followButtonDidTap() {
    guard delegate != nil, userInfo != nil else {return}

    delegate?.followButtonDidTap(userInfo!, followButton)
  }

  func followingButtonDidTap() {
    guard delegate != nil, userInfo != nil else {return}

    delegate?.followingButtonDidTap(userInfo!, followingButton)
  }

  func hideButtonDidTap() {
    guard delegate != nil, userInfo != nil else {return}

    delegate?.hideButtonDidTap(userInfo!, hideButton)
  }

  func deleteButtonDidTap() {
    guard delegate != nil, userInfo != nil else {return}

    delegate?.deleteButtonDidTap(userInfo!, deleteButton)
  }

}
