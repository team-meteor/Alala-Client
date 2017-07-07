//
//  MultipartService.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 28..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit
import Alamofire

struct MultipartService {
  static func uploadMultipart(image: UIImage?, videoData: Data?, progress: Progress?, completion: @escaping (_ multipartId: String) -> Void) {
    let headers = [
      "Content-Type": "multipart/form-data; charset=utf-8; boundary=__X_PAW_BOUNDARY__"
    ]
    Alamofire.upload(multipartFormData: { multipartFormData in
      if videoData != nil {
        multipartFormData.append(videoData!, withName: "multipart", fileName: "\(UUID().uuidString).mp4", mimeType: "video/mp4")
      } else {
        if let image = image, let imageData = UIImagePNGRepresentation(image) {
          multipartFormData.append(imageData, withName: "multipart", fileName: "\(UUID().uuidString).png", mimeType: "image/png")
        }
      }
    }, to: Constants.BASE_URL + "/multipart", method: .post, headers: headers, encodingCompletion: { result in
      switch result {
      case .success(let upload, _, _):

        upload.responseJSON { response in
          switch response.result {
          case .success(let multipartId):
            print("multipart it", multipartId)
            completion(multipartId as! String)
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
