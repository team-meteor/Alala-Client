//
//  UIImage.swift
//  Alala
//
//  Created by hoemoon on 19/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import Alamofire

extension UIImageView {
  func setImage(with photoId: String?, placeholder: UIImage? = nil, size: PhotoSize) {
    guard let photoId = photoId else {
      self.image = placeholder
      return
    }
    let url = URL(string: "https://s3.ap-northeast-2.amazonaws.com/alala-static/\(size.pixel)_\(photoId)")
    self.kf.setImage(with: url, placeholder: placeholder)
  }

  func setVideo(videoId: String) {
    let url = URL(string: "https://s3.ap-northeast-2.amazonaws.com/alala-static/\(videoId)")

    let destination = DownloadRequest.suggestedDownloadDestination()
    print("des", destination)

    Alamofire.download(url!, to: destination).downloadProgress(queue: DispatchQueue.global(qos: .utility)) { (progress) in
      print("Progress: \(progress.fractionCompleted)")
      } .validate().responseData { ( response ) in
        print("response", response)
        print(response.destinationURL!.lastPathComponent)
    }
  }
}
