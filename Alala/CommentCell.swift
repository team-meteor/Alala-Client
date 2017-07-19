//
//  CommentCell.swift
//  Alala
//
//  Created by hoemoon on 01/07/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
  override init(frame: CGRect) {
    super.init(frame: frame)
    print("override init")
  }

  required init?(coder aDecoder: NSCoder) {
    print("coder init")
    fatalError("init(coder:) has not been implemented")
  }

  func configure(comments: [Comment]) {
    print("configure")
    for comment in comments {
      print(comment)
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    print("layoutSubviews")
  }
}
