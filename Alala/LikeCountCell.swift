//
//  LikeCountCell.swift
//  Alala
//
//  Created by hoemoon on 01/07/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class LikeCountCell: UICollectionViewCell {
  let likeCountLabel: UILabel = {
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
    self.contentView.addSubview(likeCountLabel)
    self.contentView.addSubview(likesLabel)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    likeCountLabel.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.contentView)
      make.left.equalTo(self.contentView).offset(10)
    }
    likesLabel.snp.makeConstraints { (make) in
      make.centerY.equalTo(likeCountLabel)
      make.left.equalTo(self.likeCountLabel.snp.right).offset(2)
    }
  }

  func configureLikeCountLabel(post: Post) {
    let likeCount = post.likeCount
    if likeCount! > 0 {
      self.likeCountLabel.text = "\(likeCount!)명이 좋아합니다."
    }
  }
}
