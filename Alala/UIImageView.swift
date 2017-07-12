//
//  UIImage.swift
//  Alala
//
//  Created by hoemoon on 19/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import Photos
import AVKit

extension UIImageView {
  func setImage(with photoId: String?, placeholder: UIImage? = nil, size: PhotoSize) {
    guard let photoId = photoId else {
      self.image = placeholder
      return
    }
    let url = URL(string: "https://s3.ap-northeast-2.amazonaws.com/alala-static/\(size.pixel)_\(photoId)")
    DispatchQueue.main.async {
      self.kf.setImage(with: url, placeholder: placeholder)
    }
    
  }
  
  func setVideo(videoId: String, completion: @escaping (_ success: Bool) -> Void) {
    let url = URL(string: "https://s3.ap-northeast-2.amazonaws.com/alala-static/\(videoId)")
    let playerItem = AVPlayerItem(url: url!)
    let player = AVPlayer(playerItem: playerItem)
    let playerLayer = AVPlayerLayer(player: player)
    DispatchQueue.main.async {
      self.layer.addSublayer(playerLayer)
      playerLayer.frame = self.frame
      print("playerframe", playerLayer.frame)
    }
    
    player.play()
    completion(true)
  }
  
  func imageFrame() -> CGRect {
    let imageViewSize = self.frame.size
    guard let imageSize = self.image?.size else{return CGRect.zero}
    let imageRatio = imageSize.width / imageSize.height
    let imageViewRatio = imageViewSize.width / imageViewSize.height
    if imageRatio < imageViewRatio {
      let scaleFactor = imageViewSize.height / imageSize.height
      let width = imageSize.width * scaleFactor
      let topLeftX = (imageViewSize.width - width) * 0.5
      return CGRect(x: topLeftX, y: 0, width: width, height: imageViewSize.height)
    }else{
      let scalFactor = imageViewSize.width / imageSize.width
      let height = imageSize.height * scalFactor
      let topLeftY = (imageViewSize.height - height) * 0.5
      return CGRect(x: 0, y: topLeftY, width: imageViewSize.width, height: height)
    }
  }
  
}
