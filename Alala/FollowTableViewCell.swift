//
//  FollowTableViewCell.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 7. 29..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit
import SnapKit

protocol FollowTableViewCellDelegate {
  func followButtonDidTap(_ userInfo: User, _ sender: UIButton)
  func followingButtonDidTap(_ userInfo: User, _ sender: UIButton)
  func hideButtonDidTap(_ userInfo: User, _ sender: UIButton)
  func deleteButtonDidTap(_ userInfo: User, _ sender: UIButton)
}

//프로토콜 중 옵셔널메소드를 extension에 넣는다
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

  var delegate: FollowTableViewCellDelegate?

  let userPhotoImageView = CircleImageView().then {
    $0.layer.borderWidth = 1
    $0.layer.masksToBounds = false
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.clipsToBounds = true
    $0.isUserInteractionEnabled = true
  }

  let userIDLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 12.0)
    $0.text = LS("id")
    $0.sizeToFit()
  }

  let userNameLabel = UILabel().then {
    $0.font = UIFont(name: "HelveticaNeue", size: 12)
    $0.text = LS("name")
    $0.textColor = UIColor.lightGray
    $0.sizeToFit()
  }

  let followButton = RoundCornerButton(type: .buttonColorTypeBlue).then {
    $0.setTitle(LS("button_follow"), for: .normal)
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
  }
  var followButtonWidthConstraint: Constraint?

  let followingButton = RoundCornerButton(type: .buttonColorTypeWhite).then {
    $0.setTitle(LS("button_following"), for: .normal)
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
  }
  var followingButtonWidthConstraint: Constraint?

  let hideButton = RoundCornerButton(type: .buttonColorTypeWhite).then {
    $0.setTitle(LS("button_hide"), for: .normal)
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
  }
  var hideButtonWidthConstraint: Constraint?

  let deleteButton = UIButton().then {
    $0.setImage(UIImage(named: "more")?.resizeImage(scaledTolength: 10), for: .normal)
  }
  var deleteButtonWidthConstraint: Constraint?

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
      followButtonWidthConstraint = make.width.equalTo(80).constraint
    }

    followingButton.addTarget(self, action: #selector(followingButtonDidTap), for: .touchUpInside)
    followingButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self)
      make.right.equalTo(hideButton.snp.left).offset(-5)
      make.height.equalTo(25)
      followingButtonWidthConstraint = make.width.equalTo(80).constraint
    }

    hideButton.addTarget(self, action: #selector(hideButtonDidTap), for: .touchUpInside)
    hideButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self)
      make.right.equalTo(deleteButton.snp.left).offset(-5)
      make.height.equalTo(25)
      hideButtonWidthConstraint = make.width.equalTo(80).constraint
    }

    deleteButton.addTarget(self, action: #selector(deleteButtonDidTap), for: .touchUpInside)
    deleteButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self)
      make.right.equalTo(self).offset(-5)
      make.height.equalTo(25)
      deleteButtonWidthConstraint = make.width.equalTo(20).constraint
    }

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
