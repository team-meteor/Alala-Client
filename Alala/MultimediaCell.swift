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
  var post: Post!
  weak var delegate: VideoPlayButtonDelegate?
  var viewContainer = [UIView]()
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
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    viewContainer = [UIView]()
    for view in self.multimediaScrollView.subviews {
      view.removeFromSuperview()
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(post: Post) {

    self.post = post
    for item in post.multipartIds {
      if item.contains("_") {
        let imageView = UIImageView()
        imageView.setImage(with: item, size: .large)
        multimediaScrollView.addSubview(imageView)
        viewContainer.append(imageView)
      } else { // video
        let url = URL(string: "https://s3.ap-northeast-2.amazonaws.com/alala-static/\(item)")
        let videoView = VideoPlayerView(videoURL: url!)
        videoView.delegate = self.delegate
        multimediaScrollView.addSubview(videoView)
        viewContainer.append(videoView)
      }
    }

    self.setNeedsLayout()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    print("layoutSubviews")
    self.multimediaScrollView.frame = self.contentView.frame
    let frame = self.multimediaScrollView.frame
    multimediaScrollView.contentSize = CGSize(
      width: frame.width * CGFloat(post.multipartIds.count),
      height: frame.height
    )
    for (index, view) in viewContainer.enumerated() {
      view.frame = CGRect(
        x: frame.width * CGFloat(index),
        y: 0,
        width: frame.width,
        height: frame.height
      )
      if let video = view as? VideoPlayerView {
        video.addPlayerLayer()
        video.playPlayer()
      }
    }
    self.contentView.isUserInteractionEnabled = true
  }
}
