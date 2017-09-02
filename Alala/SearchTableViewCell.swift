//
//  SearchTableViewCell.swift
//  Alala
//
//  Created by lee on 2017. 8. 1..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

  static let cellReuseIdentifier = "searchCell"
  static let cellSeparatorInsets = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)
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
        userPhotoImageView.setImage(with: userInfo.profilePhotoId, size: .medium)
      }

    }
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

  fileprivate let userPhotoImageView = CircleImageView().then {
    $0.layer.borderWidth = 1
    $0.layer.masksToBounds = false
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.isUserInteractionEnabled = true
  }

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.addSubview(userIDLabel)
    self.addSubview(userNameLabel)
    self.addSubview(userPhotoImageView)

    userPhotoImageView.snp.makeConstraints { make in
      make.top.equalTo(self).offset(5)
      make.left.equalTo(self).offset(10)
      make.width.equalTo(50)
      make.height.equalTo(50)
    }

    userIDLabel.snp.makeConstraints { make in
      make.left.equalTo(userPhotoImageView.snp.right).offset(10)
      make.bottom.equalTo(userPhotoImageView.snp.centerY)
      make.height.equalTo(userIDLabel.frame.height)
    }

    userNameLabel.snp.makeConstraints { make in
      make.top.equalTo(userIDLabel.snp.bottom)
      make.left.equalTo(userIDLabel)
      make.right.equalTo(userIDLabel)
      make.height.equalTo(userNameLabel.frame.height)
    }

  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
