//
//  VideoPlayerView.swift
//  Alala
//
//  Created by junwoo on 2017. 7. 21..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit
import AVFoundation

protocol VideoPlayButtonDelegate: class {
  func playButtonDidTap(sender: UIButton, player: AVPlayer)
}

extension VideoPlayButtonDelegate {
  func playButtonDidTap(sender: UIButton, player: AVPlayer) {}
}

class VideoPlayerView: UIView {
  weak var delegate: VideoPlayButtonDelegate?
  fileprivate var player = AVPlayer()
  fileprivate var playerLayer = AVPlayerLayer()

  fileprivate let playButton = UIButton()

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  init(videoURL: URL) {
    super.init(frame: CGRect.zero)
    self.player = AVPlayer(url: videoURL)
    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { _ in
      if self.player.rate != 0 {
        self.player.seek(to: kCMTimeZero)
        self.player.play()
        print("endtime")
      }
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  func playPlayer() {
    player.play()
  }
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if player.rate == 0 {
      player.play()
      playButton.setImage(nil, for: .normal)
    } else {
      player.pause()
      playButton.setImage(UIImage(named: "play"), for: .normal)
    }
  }

  func addPlayerLayer() {
    playerLayer = AVPlayerLayer(player: player)
    playerLayer.frame = self.bounds
    self.layer.addSublayer(playerLayer)
    self.addSubview(self.playButton)
    self.playButton.snp.makeConstraints { make in
      make.height.width.equalTo(100)
      make.center.equalTo(self)
    }
    self.playButton.addTarget(self, action: #selector(playButtonDidTap), for: .touchUpInside)
  }

  func playButtonDidTap() {
    print("play tap")
    self.delegate?.playButtonDidTap(sender: playButton, player: player)
  }

}
