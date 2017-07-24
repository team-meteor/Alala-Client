//
//  Post.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import ObjectMapper
import IGListKit

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
  static var postDidLike: Notification.Name { return .init("postDidLike") }
  static var postDidUnlike: Notification.Name { return .init("postDidUnlike") }
  static var preparePosting: Notification.Name { return .init("preparePosting") }
  static var postDidCreate: Notification.Name { return .init("postDidCreate") }
}

extension Post {

  override func diffIdentifier() -> NSObjectProtocol {
    return id as NSObjectProtocol
  }

  override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    guard self !== object else { return true }
    guard let object = object as? Post else { return false }
    return id == object.id && multipartIds == object.multipartIds
  }

}
