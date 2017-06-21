//
//  PostService.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 20..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit
import Alamofire

struct PostService {

  static func postWithSingleImage(photo: UIImage, message: String?, progress: Progress?, completion: @escaping (_ success: Bool) -> Void) {

    guard let token = AuthService.instance.authToken else {
      return
    }
    ImageService.uploadImage(image: photo, progress: progress) { imageId in

      // Add Headers
      let headers = [
        "Authorization": "Bearer " + token,
        "Content-Type": "application/json; charset=utf-8"
        ]

      // JSON Body
      let body: [String : Any] = [
        "description": message,
        "photos": [
          imageId
        ]
      ]

      // Fetch Request
      Alamofire.request(Constants.BASE_URL + "post/add", method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers)
        .validate(statusCode: 200..<300)
        .responseJSON { response in
          if response.result.error == nil {
            debugPrint("HTTP Response Body: \(response.data)")
            completion(true)
          } else {
            debugPrint("HTTP Request failed: \(response.result.error)")
            completion(false)
          }
      }
    }
  }

}
