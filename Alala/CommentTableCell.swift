//
//  CommentTableCell.swift
//  Alala
//
//  Created by hoemoon on 21/07/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class CommentTableCell: UITableViewCell {
  let profilePhoto: CircleImageView = {
    let view = CircleImageView()
    view.layer.borderWidth = 1
    view.layer.masksToBounds = false
    view.layer.borderColor = UIColor.lightGray.cgColor
    view.clipsToBounds = true
    view.isUserInteractionEnabled = true
    return view
  }()

  let commentLabel = CommentLabel()

  func configure(comment: Comment) {
    guard let profileName = comment.createdBy.profileName else { return }
    self.commentLabel.text = profileName + " " + comment.content
    self.commentLabel.font = UIFont.systemFont(ofSize: 15)
    self.commentLabel.sizeToFit()
    self.profilePhoto.setImage(with: comment.createdBy.profilePhotoId, size: .thumbnail)
    self.contentView.addSubview(profilePhoto)
    self.contentView.addSubview(commentLabel)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    commentLabel.snp.makeConstraints({ (make) in
      make.left.equalTo(self.profilePhoto.snp.right).offset(5)
      make.right.equalTo(self.contentView.snp.right).offset(-10)
      make.centerY.equalTo(self.contentView)
//      make.top.bottom.equalTo(self.contentView)
    })
    profilePhoto.snp.makeConstraints { (make) in
      make.top.equalTo(self.commentLabel)
      make.left.equalTo(self.contentView).offset(10)
      make.width.height.equalTo(30)
    }
  }
}
