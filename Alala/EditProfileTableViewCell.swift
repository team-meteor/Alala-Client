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
  static let textFieldCell = "textFieldCell"
  static let textViewCell  = "textViewCell"
  static let cellSeparatorInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)

  var cellIdentifier: String = textFieldCell

  var rightButtonWidthConstraint: NSLayoutConstraint?

  let iconImageView = UIImageView().then {
    $0.image = UIImage(named: "personal")?.resizeImage(scaledTolength: 20)
  }

  let textView = UIPlaceholderTextView().then {
    $0.font = UIFont(.medium)
  }

  let textField = UITextField().then {
    $0.clearButtonMode = .whileEditing
    $0.font = UIFont(.medium)
  }

  let rightImageView = UIImageView()

  let rightButton = UIButton().then {
    $0.backgroundColor = UIColor.white
  }

  var isEnable: Bool {
    didSet {
      switch cellIdentifier {
      case EditProfileTableViewCell.textViewCell:
        self.textView.isEditable = isEnable
      default: //EditProfileTableViewCell.textFieldCell
        textField.isEnabled = isEnable
      }
    }
  }

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    isEnable = true
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.addSubview(iconImageView)
    self.addSubview(rightButton)

    iconImageView.snp.makeConstraints { (make) in
      make.centerY.equalTo(self)
      make.left.equalTo(10)
      make.width.equalTo(20)
      make.height.equalTo(20)
    }

    cellIdentifier = reuseIdentifier!
    switch cellIdentifier {
    case EditProfileTableViewCell.textViewCell:
      self.addSubview(textView)
      textView.snp.makeConstraints { (make) in
        make.top.equalTo(self).offset(5)
        make.bottom.equalTo(self).offset(-5)
        make.left.equalTo(iconImageView.snp.right).offset(5)
        make.right.equalTo(rightButton.snp.left)
      }
    default: //EditProfileTableViewCell.textFieldCell
      self.addSubview(textField)
      textField.snp.makeConstraints { (make) in
        make.top.equalTo(self).offset(5)
        make.bottom.equalTo(self).offset(-5)
        make.left.equalTo(iconImageView.snp.right).offset(10)
        make.right.equalTo(rightButton.snp.left)
      }
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

  func setText(text: String?) {
    if text == nil {
      return
    }

    switch cellIdentifier {
    case EditProfileTableViewCell.textViewCell:
      self.textView.text = text
    default: //EditProfileTableViewCell.textFieldCell
      textField.text = text
    }
  }

  func getText() -> String {
    switch cellIdentifier {
    case EditProfileTableViewCell.textViewCell:
      return self.textView.text
    default: //EditProfileTableViewCell.textFieldCell
      return self.textField.text!
    }
  }

  func setPlaceholder(text: String) {
    switch cellIdentifier {
    case EditProfileTableViewCell.textViewCell:
      self.textView.placeholder = text
    default: //EditProfileTableViewCell.textFieldCell
      textField.placeholder = text
    }
  }
//  override func setSelected(_ selected: Bool, animated: Bool) {
//      super.setSelected(selected, animated: animated)
//
//      // Configure the view for the selected state
//  }
}
