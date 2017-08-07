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

class PostNetworkManager {
  private var headers: [String: String] {
    get {
      let userDataManager = UserDataManager.shared
      return userDataManager.headers
    }
  }

  public func postWithMultipart(
    multipartIDArray: [String],
    message: String?,
    progress: Progress?,
    completion: @escaping (DataResponse<Post>) -> Void) {

    let body: [String : Any] = [
      "content": message as Any,
      "multiparts": multipartIDArray
    ]
    Alamofire.request(
      Constants.BASE_URL + "post/add",
      method: .post,
      parameters: body,
      encoding: JSONEncoding.default,
      headers: headers)
      .validate(statusCode: 200..<300)
      .responseJSON { (response) in
        if let post = Mapper<Post>().map(JSONObject: response.result.value) {
          let response = DataResponse(request: response.request, response: response.response, data: response.data, result: Result.success(post))
          completion(response)
        }
    }
  }

  public func like(post: Post, completion: @escaping (DataResponse<Post>) -> Void) {
    let body: [String : Any] = ["id": post.id!]
    var url = ""
    if post.isLiked {
      url = "like"
    } else {
      url = "unlike"
    }
    Alamofire.request(
      Constants.BASE_URL + "post/" + url,
      method: .post,
      parameters: body,
      encoding: JSONEncoding.default,
      headers: headers)
      .validate(statusCode: 200..<300)
      .responseJSON { response in
        if let post = Mapper<Post>().map(JSONObject: response.result.value) {
          let response = DataResponse(request: response.request, response: response.response, data: response.data, result: Result.success(post))
          completion(response)
        }
    }
  }

  public func createComment(post: Post, content: String, completion: @escaping (DataResponse<Comment>) -> Void) {
    guard let id = post.id else { return }
    let body: [String : Any] = ["id": id, "content": content]
    Alamofire.request(
      Constants.BASE_URL + "post/comment/add/",
      method: .post,
      parameters: body,
      encoding: JSONEncoding.default,
      headers: headers)
      .validate(statusCode: 200..<300)
      .responseJSON { response in
        if let comment = Mapper<Comment>().map(JSONObject: response.result.value) {
          let response = DataResponse(request: response.request, response: response.response, data: response.data, result: Result.success(comment))
          completion(response)
        }
    }
  }
}
