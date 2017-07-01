//
//  LikeCountCell.swift
//  Alala
//
//  Created by hoemoon on 01/07/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class LikeCountCell: UICollectionViewCell {
  let likeCount: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()
  let likesLabel: UILabel = {
    let label = UILabel()
    label.text = "likes"
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.contentView.addSubview(likeCount)
    self.contentView.addSubview(likesLabel)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    likeCount.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.contentView)
      make.left.equalTo(self.contentView).offset(10)
    }
    likesLabel.snp.makeConstraints { (make) in
      make.centerY.equalTo(likeCount)
      make.left.equalTo(self.likeCount.snp.right).offset(2)
    }
  }
}
