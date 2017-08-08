//
//  PostDataManager.swift
//  Alala
//
//  Created by hoemoon on 07/08/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import Foundation
import Alamofire

class PostDataManager {
  static private let _postNetworkManager: PostNetworkService = PostNetworkManager()

  static func postWithMultiPartCloud(
    multipartIDArray: [String],
    message: String?,
    progress: Progress?,
    completion: @escaping (DataResponse<Post>) -> Void) {

    _postNetworkManager.postWithMultipart(
      multipartIDArray: multipartIDArray,
      message: message,
      progress: progress) {
      response in
        completion(response)
    }
  }

  static func likePostWithCloud(
    post: Post,
    completion: @escaping (DataResponse<Post>) -> Void) {

    _postNetworkManager.like(post: post) {
      response in
      completion(response)
    }
  }

  static func createCommentWithCloud(
    post: Post,
    content: String,
    completion: @escaping (DataResponse<Comment>) -> Void) {

    _postNetworkManager.createComment(post: post, content: content) {
      response in
        completion(response)
    }
  }
}
