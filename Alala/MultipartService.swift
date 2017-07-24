//
//  MultipartService.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 28..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit
import Photos
import Alamofire

struct MultipartService {
  static func uploadMultipart(
    multiPartDataArray: [Any],
    progressCompletion: ((_ percent: Float) -> Void)?,
    uploadCompletion: @escaping (_ multipartIdArray: [String]) -> Void) {
    let headers = [
      "Content-Type": "multipart/form-data; charset=utf-8;"
    ]
    Alamofire.upload(multipartFormData: { multipartFormData in
      for multipartData in multiPartDataArray {
        if let videoData = multipartData as? Data {
          multipartFormData.append(videoData, withName: "multiparts", fileName: "\(UUID().uuidString).mp4", mimeType: "video/mp4")
        } else if let image = multipartData as? UIImage, let imageData = UIImagePNGRepresentation(image) {
          multipartFormData.append(imageData, withName: "multiparts", fileName: "\(UUID().uuidString).png", mimeType: "image/png")
        }
      }
    }, to: Constants.BASE_URL + "/multipart", method: .post, headers: headers, encodingCompletion: { result in
      switch result {
      case .success(let upload, _, _):
        upload.uploadProgress { progress in
          if let completion = progressCompletion {
            completion(Float(progress.fractionCompleted))
          }
        }
        upload.responseJSON { response in
          switch response.result {
          case .success(let multipartIdArray):
            print("multipart it", multipartIdArray)
            uploadCompletion(multipartIdArray as! [String])
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
