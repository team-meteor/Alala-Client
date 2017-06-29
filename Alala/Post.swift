//
//  Post.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import ObjectMapper

struct Post: Mappable {
  var id: String!
  var photoIds: [String]!
  var createdBy: User!
  var description: String?
  var likedUsers: [User]?
  var isLiked: Bool!
  var createdAt: Date!
  var comments: [Comment]?

  init?(map: Map) {
  }

  mutating func mapping(map: Map) {
    id <- map["_id"]
    photoIds <- map["photos"]
    createdBy <- map["createdBy"]
    description <- map["description"]
    likedUsers <- map["likedUsers"]
    isLiked <- map["isLiked"]
    createdAt <- (map["createdAt"], ISO8601DateTransform())
    comments <- map["comments"]
  }
}
