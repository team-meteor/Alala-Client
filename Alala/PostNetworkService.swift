//
//  PostNetworkService.swift
//  Alala
//
//  Created by hoemoon on 08/08/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import Foundation
import Alamofire

protocol PostNetworkService {
  func postWithMultipart(multipartIDArray: [String], message: String?, progress: Progress?, completion: (DataResponse<Post>) -> Void)

  func like(post: Post, completion: (DataResponse<Post>) -> Void)

  func createComment(post: Post, content: String, completion: (DataResponse<Comment>) -> Void)

}
