//
//  PostGridCell.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 7. 5..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

/**
 * Post를 grid형태로 3열 출력할 때 사용하는 콜렉션뷰 셀
 *
 * - Note : Use 1. 프로필뷰 Post Grid Mode
 */
class PostGridCell: UICollectionViewCell {

  static let cellReuseIdentifier = "gridCell"

  let thumbnailImageView = UIImageView().then {
    $0.backgroundColor = .lightGray
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
  }

  let rightTopIconView = UIImageView()

  override init(frame: CGRect) {
    isVideo = false
    isMultiPhotos = false

    super.init(frame: frame)

    self.contentView.addSubview(thumbnailImageView)
    self.contentView.addSubview(rightTopIconView)

    thumbnailImageView.snp.makeConstraints { (make) in
      make.top.equalTo(self.contentView)
      make.left.equalTo(self.contentView)
      make.right.equalTo(self.contentView)
      make.bottom.equalTo(self.contentView)
    }

    rightTopIconView.snp.makeConstraints { (make) in
      make.top.equalTo(thumbnailImageView).offset(5)
      make.right.equalTo(thumbnailImageView).offset(-5)
      make.width.equalTo(20)
      make.height.equalTo(20)
    }
  }

  var isVideo: Bool {
    didSet {
      switch isVideo {
      case true:
        rightTopIconView.isHidden = false
        rightTopIconView.image = UIImage(named: "video")?.resizeImage(scaledTolength: 20)
      case false:
        rightTopIconView.isHidden = true
      }
    }
  }

  var isMultiPhotos: Bool {
    didSet {
      switch isMultiPhotos {
      case true:
        rightTopIconView.isHidden = false
        rightTopIconView.image = UIImage(named: "photos_stack")?.resizeImage(scaledTolength: 20)
      case false:
        rightTopIconView.isHidden = true
      }
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
