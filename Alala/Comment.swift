//
//  Comment.swift
//  Alala
//
//  Created by hoemoon on 21/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import ObjectMapper

class Comment: NSObject, Mappable {
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
}
