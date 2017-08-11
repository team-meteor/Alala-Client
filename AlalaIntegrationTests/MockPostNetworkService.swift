//
//  MockPostNetworkService.swift
//  Alala
//
//  Created by hoemoon on 08/08/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

@testable import Alala

public class MockPostNetworkService: PostNetworkService {

  public lazy var somepost: Post = {
    var result = Post()
    let bundle = Bundle(for: type(of: self))
    if let path = bundle.path(forResource: "somepost", ofType: "json"),
      let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped),
      let string = String(data: data, encoding: .utf8),
      let post = Mapper<Post>().map(JSONString: string) {
      result = post
    }
    return result
  }()

  public lazy var someuser: User = {
    var result = User()
    let bundle = Bundle(for: type(of: self))
    if let path = bundle.path(forResource: "someuser", ofType: "json"),
      let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped),
      let string = String(data: data, encoding: .utf8),
      let user = Mapper<User>().map(JSONString: string) {
      result = user
    }
    return result
  }()

  public func postWithMultipart(
    multipartIDArray: [String],
    message: String?,
    progress: Progress?,
    completion: @escaping (DataResponse<Post>) -> Void) {

    self.somepost.multipartIds.append(contentsOf: multipartIDArray)
    let response = DataResponse(
      request: nil,
      response: nil,
      data: nil,
      result: Result.success(self.somepost))
    completion(response)
  }

  public func like(post: Post, completion: @escaping (DataResponse<Post>) -> Void) {

  }

  public func createComment(post: Post, content: String, completion: @escaping (DataResponse<Comment>) -> Void) {
  }
}
