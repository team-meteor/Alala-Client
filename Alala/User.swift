//
//  User.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import ObjectMapper

class User: NSObject, Mappable {
  var id: String!
  var email: String!
  var createdAt: Date!
  var profileName: String?
  var profilePhotoId: String?
  var following: [User]?
  var followers: [User]?

  required init?(map: Map) {
  }

  func mapping(map: Map) {
    id <- map["_id"]
    email <- map["username"]
    createdAt <- (map["createdAt"], DateTransform())
    profileName <- map["profileName"]
    profilePhotoId <- map["multipartId"]
    following <- map["following"]
    followers <- map["followers"]
  }
}
