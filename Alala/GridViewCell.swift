//
//  GridViewCell.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 21..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit

class GridViewCell: UITableViewCell {

  fileprivate let photoView = UIImageView()
  fileprivate let titleLabel = UILabel()
  fileprivate let countLabel = UILabel()

  var representedAssetIdentifier: String!

  var thumbnailImage: UIImage! {
    didSet {
      photoView.image = thumbnailImage
    }
  }

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.selectionStyle = .none
    self.contentView.addSubview(self.photoView)
    self.contentView.addSubview(self.titleLabel)
    self.contentView.addSubview(self.countLabel)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(image: UIImage, title: String, count: Int) {
    self.photoView.image = image
    self.titleLabel.text = title
    self.countLabel.text = String(count)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.photoView.snp.makeConstraints { make in
      make.left.top.equalTo(self.contentView).offset(5)
      make.bottom.equalTo(self.contentView).offset(-5)
      make.height.equalTo(self.photoView.snp.width)
    }

    self.titleLabel.snp.makeConstraints { make in
      make.top.right.equalTo(self.contentView)
      make.left.equalTo(self.photoView.snp.right).offset(10)
      make.bottom.equalTo(self.countLabel.snp.top)
      make.height.equalTo(50)
    }

    self.countLabel.snp.makeConstraints { make in
      make.left.equalTo(self.photoView.snp.right).offset(10)
      make.bottom.right.equalTo(self.contentView)
    }
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    thumbnailImage = nil
  }
}
