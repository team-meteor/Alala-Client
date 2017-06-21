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
  var profileName: String?
  var photoID: String?
  var following: [String]?
  var followers: [String]?
  var createdAt: String!

  init?(map: Map) {
  }

  mutating func mapping(map: Map) {

  }
}
