//
//  User.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import ObjectMapper

struct User: Mappable {
  var id: Int!
  var username: String!
  var photoID: String?
  
  init?(map: Map) {
  }
  
  mutating func mapping(map: Map) {
    self.id <- map["id"]
    self.username <- map["username"]
    self.photoID <- map["photo.id"]
  }
}
