//
//  User.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import ObjectMapper

struct User: Mappable {
  var id: String!
  var email: String!
  var createdAt: Date!
  var profileName: String?
  var photoId: String?
  var following: [User]?
  var followers: [User]?

  init?(map: Map) {
  }
  mutating func mapping(map: Map) {
    id <- map["_id"]
    email <- map["username"]
    createdAt <- (map["createdAt"], DateTransform())
    profileName <- map["profileName"]
    photoId <- map["photoId"]
    following <- map["following"]
    followers <- map["followers"]
  }
}
