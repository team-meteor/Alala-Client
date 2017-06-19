//
//  ImageService.swift
//  Alala
//
//  Created by hoemoon on 19/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import Alamofire

struct ImageService {
  static func uploadImage(image: UIImage, progress: Progress?, completion: @escaping (_ imageId: String) -> Void) {
    let headers = [
      "Content-Type": "multipart/form-data; charset=utf-8; boundary=__X_PAW_BOUNDARY__"
      ]
    Alamofire.upload(multipartFormData: { multipartFormData in
      let imageData = UIImageJPEGRepresentation(image, 0.6)!
      multipartFormData.append(imageData, withName: "photo", fileName: "file.jpg", mimeType: "image/jpg")
    }, to: Constants.BASE_URL + "/photo/single", method: .post, headers: headers, encodingCompletion: { result in
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
  
  static func uploadMultiImages(images: [UIImage], progress: Progress, completion: @escaping (_ success: Bool) -> Void) {
    
  }
}
