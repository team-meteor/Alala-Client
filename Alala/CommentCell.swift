//
//  CommentCell.swift
//  Alala
//
//  Created by hoemoon on 03/07/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
  typealias CommentLabelDict = [UILabel: UILabel]
  var commentsContainer = CommentLabelDict()
  override init(frame: CGRect) {
    super.init(frame: frame)
    print("override init")
  }

  required init?(coder aDecoder: NSCoder) {
    print("coder init")
    fatalError("init(coder:) has not been implemented")
  }

  func configure(comments: [Comment]) {
    for comment in comments {
      let createdByLabel = UILabel()
      createdByLabel.text = comment.createdBy.profileName
      let commentContentLabel = UILabel()
      commentContentLabel.text = comment.content
      commentsContainer[createdByLabel] = commentContentLabel
      addSubview(createdByLabel)
      addSubview(commentContentLabel)
    }
  }

  override func layoutSubviews() {
    print("layoutSubviews")
    super.layoutSubviews()
    var commentSize = 0
    for (createdByLabel, commentContentLabel) in commentsContainer {
      createdByLabel.sizeToFit()
      createdByLabel.snp.makeConstraints({ (make) in
        make.left.equalTo(self.contentView).offset(10)
        make.right.equalTo(self.contentView).offset(-10)
        make.centerY.equalTo(self.contentView.snp.centerY).offset(commentSize)
        // TODO : dynamic comment size
      })
//      let exclusionPath = createdByLabel 
      commentContentLabel.sizeToFit()
      commentContentLabel.snp.makeConstraints({ (make) in
        make.left.equalTo(self.contentView).offset(10)
        make.right.equalTo(self.contentView).offset(-10)
        make.centerY.equalTo(self.contentView.snp.centerY).offset(commentSize)
      })
      commentSize += 20
      print(commentSize)
    }
  }
}
