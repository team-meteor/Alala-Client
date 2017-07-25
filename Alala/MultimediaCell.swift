//
//  MultimediaCell.swift
//  Alala
//
//  Created by hoemoon on 29/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import AVFoundation

class MultimediaCell: UICollectionViewCell {
  weak var delegate: VideoPlayButtonDelegate?
  let multimediaScrollView: UIScrollView = {
    let view = UIScrollView()
    view.backgroundColor = UIColor.yellow
    view.isPagingEnabled = true
    view.bounces = false
    return view
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.contentView.addSubview(multimediaScrollView)
    multimediaScrollView.snp.makeConstraints { (make) in
      make.size.equalTo(self.contentView)
      make.centerY.equalTo(self.contentView)
      make.centerX.equalTo(self.contentView)
    }
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    for view in self.multimediaScrollView.subviews {
      view.removeFromSuperview()
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(post: Post) {
    var counter = 0
    //scrollview 초기화
    multimediaScrollView.subviews.forEach({$0.removeFromSuperview()})
    multimediaScrollView.contentSize = CGSize(
      width: self.contentView.frame.width * CGFloat(post.multipartIds.count),
      height: self.contentView.frame.height
    )
    print(post.multipartIds)
    for item in post.multipartIds {

      if item.contains("_") {
        let imageView = UIImageView()
        imageView.setImage(with: item, size: .hd)
        imageView.frame = CGRect(
          x: self.contentView.bounds.width * CGFloat(counter),
          y: 0,
          width: self.contentView.bounds.width,
          height: self.contentView.bounds.height)
        multimediaScrollView.addSubview(imageView)

      } else { // video
        let url = URL(string: "https://s3.ap-northeast-2.amazonaws.com/alala-static/\(item)")

        let videoView = VideoPlayerView(videoURL: url!)
        videoView.frame = CGRect(
          x: self.contentView.bounds.width * CGFloat(counter),
          y: 0,
          width: self.contentView.bounds.width,
          height: self.contentView.bounds.height)
        videoView.addPlayerLayer()
        multimediaScrollView.addSubview(videoView)
        videoView.playPlayer()
        videoView.delegate = self.delegate
        self.contentView.isUserInteractionEnabled = true
      }
      counter += 1
    }
//    self.setNeedsLayout()
    self.setNeedsDisplay()
  }
}
