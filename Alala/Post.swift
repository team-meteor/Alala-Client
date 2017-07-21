//
//  Post.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import ObjectMapper

class Post: NSObject, Mappable {
  var id: String!
  var multipartIds: [String]!
  var createdBy: User!
  var likedUsers: [User]?
  var isLiked: Bool!
  var likeCount: Int!
  var createdAt: Date!
  var comments: [Comment]?
  var expanded = false

  required init?(map: Map) {
  }

  func mapping(map: Map) {
    id <- map["_id"]
    multipartIds <- map["multiparts"]
    createdBy <- map["createdBy"]
    likedUsers <- map["likedUsers"]
    isLiked <- map["isLiked"]
    createdAt <- (map["createdAt"], DateTransform())
    comments <- map["comments"]
    likeCount = likedUsers?.count
  }
}

extension Notification.Name {
  /// 좋아요를 할 경우 발생하는 노티피케이션입니다. `userInfo`에 `postID`가 전달됩니다.
  static var postDidLike: Notification.Name { return .init("postDidLike") }

  /// 좋아요를 취소할 경우 발생하는 노티피케이션입니다. `userInfo`에 `postID`가 전달됩니다.
  static var postDidUnlike: Notification.Name { return .init("postDidUnlike") }

  /// 새로운 `Post`의 업로드가 시작될 때 발생하는 노티피케이션입니다.
  static var preparePosting: Notification.Name { return .init("preparePosting") }

  /// 새로운 `Post`가 생성되었을 경우 발생하는 노티피케이션입니다. `userInfo`에 `post: Post`가 전달됩니다.
  static var postDidCreate: Notification.Name { return .init("postDidCreate") }
}
