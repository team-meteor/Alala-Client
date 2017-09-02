//
//  CommentTableCell.swift
//  Alala
//
//  Created by hoemoon on 21/07/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import ActiveLabel

class CommentTableCell: UITableViewCell {
  weak var delegate: ActiveLabelDelegate?
  let profilePhoto: CircleImageView = {
    let view = CircleImageView()
    view.layer.borderWidth = 1
    view.layer.masksToBounds = false
    view.layer.borderColor = UIColor.lightGray.cgColor
    view.isUserInteractionEnabled = true
    return view
  }()

  let commentLabel = CommentLabel()

  override func prepareForReuse() {
    super.prepareForReuse()
    for view in self.subviews {
      view.removeFromSuperview()
    }
  }

  func configure(comment: Comment) {
    guard let profileName = comment.createdBy.profileName else { return }
    self.commentLabel.attributedText = NSMutableAttributedString(string:
      profileName + " " + comment.content
    )
    self.commentLabel.font = UIFont.systemFont(ofSize: 15)
    self.commentLabel.delegate = delegate
//    self.commentLabel.sizeToFit()
    self.profilePhoto.setImage(with: comment.createdBy.profilePhotoId, size: .thumbnail)
    self.contentView.addSubview(profilePhoto)
    self.contentView.addSubview(commentLabel)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    profilePhoto.snp.makeConstraints { (make) in
      make.top.equalTo(self.contentView).offset(10)
      make.left.equalTo(self.contentView).offset(10)
      make.width.height.equalTo(30)
    }

    commentLabel.snp.makeConstraints({ (make) in
      make.left.equalTo(self.profilePhoto.snp.right).offset(10)
      make.right.equalTo(self.contentView.snp.right).offset(-10)
      make.top.equalTo(self.profilePhoto)
    })
  }
}
