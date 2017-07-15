//
//  VideoPlayer.swift
//  Alala
//
//  Created by junwoo on 2017. 7. 15..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit
import AVKit
import Photos

struct VideoPlayer {
  var player: AVPlayer
  var playerLayer: AVPlayerLayer
  var videoURL: URL!
  var imageView: UIImageView!

  init(videoUrl: URL, imageView: UIImageView) {
    self.videoURL = videoUrl
    self.imageView = imageView
    let playerItem = AVPlayerItem(url: videoURL)
    player = AVPlayer(playerItem: playerItem)
    playerLayer = AVPlayerLayer(player: player)
  }

  fileprivate let playButton = UIButton().then {
    $0.backgroundColor = UIColor.blue
    $0.setTitle("Pause", for: UIControlState.normal)
  }

  func addAVPlayer() {

    DispatchQueue.main.async {
      self.imageView.layer.addSublayer(self.playerLayer)
      self.playerLayer.frame = self.imageView.frame
    }
    player.play()
  }

  func getThumbnailFromVideo() -> UIImage? {
    let asset = AVAsset(url: videoURL!)
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
