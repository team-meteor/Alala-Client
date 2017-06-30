//
//  MultimediaCell.swift
//  Alala
//
//  Created by hoemoon on 29/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class MultimediaCell: UICollectionViewCell {
  let multimediaImageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(multimediaImageView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    multimediaImageView.snp.makeConstraints { (make) in
      make.width.equalTo(self.contentView)
      make.centerY.equalTo(self.contentView)
      make.centerX.equalTo(self.contentView)
    }
  }
}
