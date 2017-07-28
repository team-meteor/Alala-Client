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
  static private var token: String {
    get {
      if let token = AuthService.instance.authToken {
        return token
      } else {
        return ""
      }
    }
  }
  static private var headers = [
    "Authorization": "Bearer " + token,
    "Content-Type": "application/json; charset=utf-8"
  ]

  static func postWithMultipart(idArr: [String], message: String?, progress: Progress?, completion: @escaping (DataResponse<Post>) -> Void) {
    let body: [String : Any] = [
      "content": message as Any,
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

  static func like(post: Post, completion: @escaping (DataResponse<Post>) -> Void) {
    let body: [String : Any] = ["id": post.id!]
    var url = ""
    if post.isLiked {
      url = "like"
    } else {
      url = "unlike"
    }
    Alamofire.request(Constants.BASE_URL + "post/" + url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers)
      .validate(statusCode: 200..<300)
      .responseJSON { response in
        if let post = Mapper<Post>().map(JSONObject: response.result.value) {
          let response = DataResponse(request: response.request, response: response.response, data: response.data, result: Result.success(post))
          completion(response)
        }
    }
  }

  static func createComment(post: Post, content: String, completion: @escaping (DataResponse<Comment>) -> Void) {
    let body: [String : Any] = ["id": post.id!, "content": content]
    Alamofire.request(Constants.BASE_URL + "post/comment/add/", method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers)
      .validate(statusCode: 200..<300)
      .responseJSON { response in
        if let comment = Mapper<Comment>().map(JSONObject: response.result.value) {
          let response = DataResponse(request: response.request, response: response.response, data: response.data, result: Result.success(comment))
          completion(response)
        }
    }
  }
}
