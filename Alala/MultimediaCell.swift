//
//  MultimediaCell.swift
//  Alala
//
//  Created by hoemoon on 29/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class MultimediaCell: UICollectionViewCell {

  let multimediaScrollView: UIScrollView = {
    let view = UIScrollView()
    view.backgroundColor = UIColor.yellow
    view.isPagingEnabled = true
    view.alwaysBounceHorizontal = true
    return view
  }()

  var imageViewArr = [UIImageView]()

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

  }

  func configure(multimediaCount: Int) {
    for _ in 0..<multimediaCount {
      let multimediaImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.blue
        imageView.contentMode = .scaleAspectFit
        return imageView
      }()
      imageViewArr.append(multimediaImageView)
    }

    for imageView in imageViewArr {
      multimediaScrollView.addSubview(imageView)
    }

    contentView.addSubview(multimediaScrollView)

    multimediaScrollView.snp.makeConstraints { (make) in
      make.size.equalTo(self.contentView)
      make.centerY.equalTo(self.contentView)
      make.centerX.equalTo(self.contentView)
    }

    print("arr", imageViewArr)
    multimediaScrollView.contentSize = CGSize(width: self.contentView.frame.width * CGFloat(multimediaCount), height: self.contentView.frame.height)

    print("size", multimediaScrollView.contentSize)
    for i in 0..<imageViewArr.count {
      imageViewArr[i].frame = CGRect(x: self.contentView.bounds.width * CGFloat(i), y: 0, width: self.contentView.bounds.width, height: self.contentView.bounds.height)

    }
  }
}
