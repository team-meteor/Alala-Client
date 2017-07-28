//
//  CommentCell.swift
//  Alala
//
//  Created by hoemoon on 03/07/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
  var comments = [Comment]()
  var labelContainer = [CommentLabel]()

  override func prepareForReuse() {
    super.prepareForReuse()
    comments = [Comment]()
    labelContainer = [CommentLabel]()
    for view in self.contentView.subviews {
      view.removeFromSuperview()
    }
  }

  func configure(post: Post) {
    guard let comments = post.comments else { return }
    self.comments = comments
    for comment in self.comments {
      if let creator = comment.createdBy, let profileName = creator.profileName, profileName.characters.count > 0 && comment.content.characters.count > 0 {
        let label = CommentLabel()
        label.attributedText = NSMutableAttributedString(string: "@@" + profileName + " " + comment.content)
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        labelContainer.append(label)
        self.contentView.addSubview(label)
      }
    }
    self.setNeedsLayout()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    var preHeight: CGFloat = 0
    for label in labelContainer {
      if let text = label.text {
        let textHeight = TextSize.size(text, font: UIFont.systemFont(ofSize: 17), width: self.contentView.frame.width, insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)).height
        label.snp.makeConstraints({ (make) in
          make.top.equalTo(self.contentView).offset(preHeight)
          make.left.equalTo(self.contentView).offset(10)
          make.right.equalTo(self.contentView).offset(-10)
          make.height.equalTo(textHeight)
        })
        preHeight += textHeight
      }
    }
  }
}
