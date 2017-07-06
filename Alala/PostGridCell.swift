//
//  PostGridCell.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 7. 5..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class PostGridCell: UICollectionViewCell {

  let thumbnailImageView = UIImageView().then {
    $0.backgroundColor = .lightGray
  }

  let videoIconView = UIImageView().then {
    $0.image = UIImage(named: "video")?.resizeImage(scaledTolength: 20)
  }

  let photosIconView = UIImageView().then {
    $0.image = UIImage(named: "personal")?.resizeImage(scaledTolength: 20)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.contentView.addSubview(thumbnailImageView)
    self.contentView.addSubview(videoIconView)
    //self.contentView.addSubview(photosIconView)

    thumbnailImageView.snp.makeConstraints { (make) in
      make.top.equalTo(self.contentView)
      make.left.equalTo(self.contentView)
      make.right.equalTo(self.contentView)
      make.bottom.equalTo(self.contentView)
    }
    videoIconView.snp.makeConstraints { (make) in
      make.top.equalTo(thumbnailImageView).offset(5)
      make.right.equalTo(thumbnailImageView).offset(-5)
      make.width.equalTo(20)
      make.height.equalTo(20)
    }
  }

//  var isVideo: Bool {
//
//  }
//
//  var isMultiPhotos: Bool {
//
//  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
