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
  var postDescription: String?
  var likedUsers: [User]?
  var isLiked: Bool!
  var createdAt: Date!
  var comments: [Comment]?

  required init?(map: Map) {
  }

  func mapping(map: Map) {
    id <- map["_id"]
    multipartIds <- map["multiparts"]
    createdBy <- map["createdBy"]
    postDescription <- map["description"]
    likedUsers <- map["likedUsers"]
    isLiked <- map["isLiked"]
    createdAt <- (map["createdAt"], DateTransform())
    comments <- map["comments"]
  }
}
