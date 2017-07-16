//
//  VideoPlayerViewController.swift
//  Alala
//
//  Created by junwoo on 2017. 7. 15..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoPlayerViewController: AVPlayerViewController {

  fileprivate let playButton = UIButton().then {
    $0.setImage(UIImage(named: "pause"), for: .normal)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { _ in
      self.player?.seek(to: kCMTimeZero)
      self.player?.play()
    }

    self.showsPlaybackControls = false

    self.view.addSubview(playButton)

  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    playButton.snp.makeConstraints { make in
      make.height.width.equalTo(100)
      make.center.equalTo(self.view)
    }

  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    print("touch")
    if player?.rate == 0 {
      player!.play()

      playButton.setImage(UIImage(named: "pause"), for: .normal)
    } else {
      player!.pause()

      playButton.setImage(UIImage(named: "play"), for: .normal)
    }
  }

  func addVideoPlayer(videoUrl: URL, videoView: UIView) {
    player = AVPlayer(url: videoUrl)
    self.parent?.addChildViewController(self)
    DispatchQueue.main.async {
      videoView.addSubview(self.view)
      self.view.frame = videoView.frame
    }
    videoView.isUserInteractionEnabled = true
    player?.play()
  }

  func removeVideoPlayer() {
    player?.pause()
    self.view.removeFromSuperview()
    self.removeFromParentViewController()
  }

  func getThumbnailImage(videoUrl: URL) -> UIImage? {
    let asset = AVAsset(url: videoUrl)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true

    var time = asset.duration
    time.value = min(time.value, 2)

    do {
      let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
      return UIImage(cgImage: imageRef)
    } catch {
      return nil
    }
  }

}
