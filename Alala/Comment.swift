//
//  Comment.swift
//  Alala
//
//  Created by hoemoon on 21/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import ObjectMapper
import IGListKit

class Comment: NSObject, Mappable, NSCoding {
  var id: String!
  var content: String!
  var createdBy: User!
  var likedUsers: [User]?
  var isLiked: Bool!
  var createdAt: Date!

  required init?(map: Map) {
  }

  func mapping(map: Map) {
    id <- map["_id"]
    content <- map["content"]
    createdBy <- map["createdBy"]
    likedUsers <- map["likedUsers"]
    isLiked <- map["isLiked"]
    createdAt <- (map["createdAt"], DateTransform())
  }
  public func encode(with aCoder: NSCoder) {
    aCoder.encode(id, forKey: "id")
    aCoder.encode(content, forKey: "content")
    aCoder.encode(createdBy, forKey: "createdBy")
    aCoder.encode(likedUsers, forKey: "likedUsers")
    aCoder.encode(isLiked, forKey: "isLiked")
    aCoder.encode(createdAt, forKey: "createdAt")
  }
  public required init?(coder aDecoder: NSCoder) {
    id = aDecoder.decodeObject(forKey: "id") as! String
    content = aDecoder.decodeObject(forKey: "content") as! String
    createdBy = aDecoder.decodeObject(forKey: "createdBy") as! User
    likedUsers = aDecoder.decodeObject(forKey: "likedUsers") as! [User]?
    isLiked = aDecoder.decodeObject(forKey: "isLiked") as! Bool
    createdAt = aDecoder.decodeObject(forKey: "createdAt") as! Date
  }

}

extension Comment {
  override func diffIdentifier() -> NSObjectProtocol {
    return id as NSObjectProtocol
  }

  override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    guard self !== object else { return true }
    guard let object = object as? Comment else { return false }
    return id == object.id && content == object.content
  }
}
