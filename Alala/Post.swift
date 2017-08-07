//
//  Post.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import ObjectMapper
import IGListKit

class Post: NSObject, Mappable, NSCoding {
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

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(id, forKey: "id")
    aCoder.encode(multipartIds, forKey: "multipartIds")
    aCoder.encode(createdBy, forKey: "createdBy")
    aCoder.encode(likedUsers, forKey: "likedUsers")
    aCoder.encode(isLiked, forKey: "isLiked")
    aCoder.encode(likeCount, forKey: "likeCount")
    aCoder.encode(createdAt, forKey: "createdAt")
    aCoder.encode(comments, forKey: "comments")

  }
  public required init?(coder aDecoder: NSCoder) {
    id = aDecoder.decodeObject(forKey: "id") as! String
    multipartIds = aDecoder.decodeObject(forKey: "multipartIds") as! [String]
    createdBy = aDecoder.decodeObject(forKey: "createdBy") as! User
    likedUsers = aDecoder.decodeObject(forKey: "likedUsers") as! [User]?
    isLiked = aDecoder.decodeObject(forKey: "isLiked") as! Bool
    likeCount = aDecoder.decodeObject(forKey: "likeCount") as! Int
    createdAt = aDecoder.decodeObject(forKey: "createdAt") as! Date
    comments = aDecoder.decodeObject(forKey: "comments") as! [Comment]?
  }
}

extension Notification.Name {
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
    if let objectComments = object.comments, let comments = comments {
      return id == object.id && multipartIds == object.multipartIds && comments == objectComments
    }
    return id == object.id && multipartIds == object.multipartIds
  }
}
