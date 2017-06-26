//
//  VideoService.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 26..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit
import Alamofire

struct VideoService {
  static func uploadVideo(videoUrl: URL, progress: Progress?, completion: @escaping (_ imageId: String) -> Void) {
    let headers = [
      "Content-Type": "multipart/form-data; charset=utf-8; boundary=__X_PAW_BOUNDARY__"
    ]
    Alamofire.upload(multipartFormData: { multipartFormData in
      var movieData: Data?
      do {
        movieData = try Data(contentsOf: videoUrl)
      } catch _ {
        movieData = nil
        return
      }
      multipartFormData.append(movieData!, withName: "video", fileName: "\(UUID().uuidString).mp4", mimeType: "video/mp4")
    }, to: Constants.BASE_URL + "/video/single", method: .post, headers: headers, encodingCompletion: { result in
      switch result {
      case .success(let upload, _, _):
        upload.responseJSON { response in
          switch response.result {
          case .success(let data):
            completion(data as! String)
          case .failure(let error):
            print(error)
          }
        }
      case .failure(let encodingError):
        print(encodingError)
      }
    })
  }

}
