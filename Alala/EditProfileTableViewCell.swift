//
//  EditProfileTableViewCell.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 6. 29..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

/**
 * 내 프로필 편집 화면에서 출력하는 테이블뷰 셀
 */
class EditProfileTableViewCell: UITableViewCell {

  static let cellReuseIdentifier = "editProfileCell"
  static let cellSeparatorInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)

  var rightButtonWidthConstraint: NSLayoutConstraint?

  let iconImageView = UIImageView().then {
    $0.image = UIImage(named: "personal")?.resizeImage(scaledTolength: 25)
  }

  let textView = UITextView().then {
    $0.text = "test"
  }

  let textField = UITextField().then {
    $0.placeholder = ""
  }

  let rightImageView = UIImageView()

  let rightButton = UIButton().then {
    $0.backgroundColor = UIColor.white
  }

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.addSubview(iconImageView)
    self.addSubview(textField)
    //self.addSubview(rightImageView)
    self.addSubview(rightButton)

    iconImageView.snp.makeConstraints { (make) in
      make.centerY.equalTo(self)
      make.left.equalTo(10)
      make.width.equalTo(30)
      make.height.equalTo(30)
    }

    textField.snp.makeConstraints { (make) in
      make.top.equalTo(self).offset(5)
      make.bottom.equalTo(self).offset(-5)
      make.left.equalTo(iconImageView.snp.right).offset(10)
      make.right.equalTo(rightButton.snp.left)
    }

    rightButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self)
      make.right.equalTo(self).offset(-5)
      make.top.equalTo(self).offset(5)
      make.bottom.equalTo(self).offset(-5)
    }
    rightButtonWidthConstraint = NSLayoutConstraint(item: rightButton,
                                                    attribute: NSLayoutAttribute.width,
                                                    relatedBy: NSLayoutRelation.equal,
                                                    toItem: nil,
                                                    attribute: NSLayoutAttribute.notAnAttribute,
                                                    multiplier: 1,
                                                    constant: 0)
    rightButtonWidthConstraint!.isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code

//    self.addSubview(iconImageView)
//    self.addSubview(textView)
    //self.addSubview(rightImageView)
    //self.addSubview(rightButton)

//    iconImageView.snp.makeConstraints { (make) in
//      make.centerY.equalTo(self)
//      make.left.equalTo(10)
//      make.width.equalTo(20)
//      make.height.equalTo(20)
//    }
//
//    textView.snp.makeConstraints { (make) in
//      make.top.equalTo(self).offset(5)
//      make.bottom.equalTo(self).offset(-5)
//      make.left.equalTo(iconImageView.snp.right).offset(20)
//      //make.right.equalTo(rightButton.snp.left)
//      make.right.equalTo(self)
//    }

//    rightImageView.snp.makeConstraints { (make) in
//      make.centerY.equalTo(self)
//      make.left.equalTo(iconImageView.snp.right).offset(20)
//    }

//    rightButton.snp.makeConstraints { (make) in
//      make.centerY.equalTo(self)
//      make.left.equalTo(textView.snp.right)
//      make.right.equalTo(self).offset(-10)
//      make.width.equalTo(30)
//      make.height.equalTo(self.frame.size.height-10)
//    }
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)

      // Configure the view for the selected state
  }

}
