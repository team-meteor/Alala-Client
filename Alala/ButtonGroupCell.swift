//
//  ButtonGroupCell.swift
//  Alala
//
//  Created by hoemoon on 29/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class ButtonGroupCell: UICollectionViewCell {
  let heartButton: UIButton = {
    let button = UIButton()
    let image = UIImage(named: "heart")?.resizeImage(scaledToFit: 30)
    button.setImage(image, for: .normal)
    return button
  }()
  let commentButton: UIButton = {
    let button = UIButton()
    let image = UIImage(named: "comment")?.resizeImage(scaledToFit: 25)
    button.setImage(image, for: .normal)
    return button
  }()
  let sendButton: UIButton = {
    let button = UIButton()
    let image = UIImage(named: "send")?.resizeImage(scaledToFit: 25)
    button.setImage(image, for: .normal)
    return button
  }()
  let saveButton: UIButton = {
    let button = UIButton()
    let image = UIImage(named: "save")?.resizeImage(scaledToFit: 25)
    button.setImage(image, for: .normal)
    return button
  }()
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(heartButton)
    contentView.addSubview(commentButton)
    contentView.addSubview(sendButton)
    contentView.addSubview(saveButton)
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    heartButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.contentView)
      make.left.equalTo(self.contentView).offset(10)
    }
    commentButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.heartButton)
      make.left.equalTo(self.heartButton.snp.right).offset(15)
    }
    sendButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.commentButton)
      make.left.equalTo(self.commentButton.snp.right).offset(15)
    }
    saveButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.sendButton)
      make.right.equalTo(self.contentView).offset(-10)
    }
  }
}
