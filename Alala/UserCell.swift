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
    label.sizeToFit()
    return label
  }()

  let moreButton: UIButton = {
    let button = UIButton(type: .custom)
    let image = UIImage(named: "more")?.resizeImage(scaledToFit: 15)
    button.setImage(image, for: .normal)
    return button
  }()

  let borderBottom = UIView().then {
    $0.backgroundColor = UIColor(red:0.86, green:0.86, blue:0.86, alpha:1.00)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(profilePhoto)
    contentView.addSubview(profileNameLabel)
    contentView.addSubview(moreButton)
    contentView.addSubview(borderBottom)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    profilePhoto.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.contentView)
      make.left.equalTo(10)
      make.height.equalTo(32)
      make.width.equalTo(32)
    }
    profileNameLabel.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.contentView)
      make.left.equalTo(profilePhoto.snp.right).offset(10)
    }
    moreButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.contentView)
      make.right.equalTo(self.contentView).offset(-15.5)
    }
    borderBottom.snp.makeConstraints { (make) in
      make.width.equalTo(self.contentView)
      make.height.equalTo(1)
      make.bottom.equalTo(self.contentView)
    }
  }
}
