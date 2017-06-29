//
//  UserInfoCell.swift
//  Alala
//
//  Created by hoemoon on 29/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class UserCell: UICollectionViewCell {
  let profilePhoto = CircleImageView().then {
    $0.layer.borderWidth = 1
    $0.layer.masksToBounds = false
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.clipsToBounds = true
    $0.isUserInteractionEnabled = true
  }

  let profileNameLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = UIColor.clear
    label.textColor = UIColor.black
    return label
  }()

  let moreButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "more"), for: .normal)
    return button
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(profilePhoto)
    contentView.addSubview(profileNameLabel)
    contentView.addSubview(moreButton)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    // 배치하기
  }
}
