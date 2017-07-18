//
//  PostService.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 20..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

struct PostService {
  static let instance = PostService()
  let defaults = UserDefaults.standard

  static func postWithMultipart(idArr: [String], message: String?, progress: Progress?, completion: @escaping (DataResponse<Post>) -> Void) {

    guard let token = AuthService.instance.authToken else {
      return
    }
    let headers = [
      "Authorization": "Bearer " + token,
      "Content-Type": "application/json; charset=utf-8"
    ]

    let body: [String : Any] = [
      "description": message as Any,
      "multiparts": idArr
    ]

    Alamofire.request(Constants.BASE_URL + "post/add", method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers)
      .validate(statusCode: 200..<300)
      .responseJSON { (response) in
        if let post = Mapper<Post>().map(JSONObject: response.result.value) {

          let response = DataResponse(request: response.request, response: response.response, data: response.data, result: Result.success(post))
          completion(response)
        }
    }
  }

  static func like(postID: String, completion: @escaping (DataResponse<Post>) -> Void) {
    guard let token = AuthService.instance.authToken else {
      return
    }

    let headers = [
      "Authorization": "Bearer " + token,
      "Content-Type": "application/json; charset=utf-8"
    ]

    let body: [String : Any] = [
      "id": postID
    ]

    Alamofire.request(Constants.BASE_URL + "post/like", method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers)
      .validate(statusCode: 200..<300)
      .responseJSON { response in
        if let post = Mapper<Post>().map(JSONObject: response.result.value) {

          let response = DataResponse(request: response.request, response: response.response, data: response.data, result: Result.success(post))
          completion(response)
        }
    }
  }

  static func unlike(postID: String, completion: @escaping (DataResponse<Post>) -> Void) {
    guard let token = AuthService.instance.authToken else {
      return
    }

    let headers = [
      "Authorization": "Bearer " + token,
      "Content-Type": "application/json; charset=utf-8"
    ]

    let body: [String : Any] = [
      "id": postID
    ]

    Alamofire.request(Constants.BASE_URL + "post/unlike", method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers)
      .validate(statusCode: 200..<300)
      .responseJSON { response in
        if let post = Mapper<Post>().map(JSONObject: response.result.value) {

          let response = DataResponse(request: response.request, response: response.response, data: response.data, result: Result.success(post))
          completion(response)
        }
    }
  }
}
