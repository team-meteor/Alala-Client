//
//  Feed.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import ObjectMapper

struct Feed: Mappable {
  var posts: [Post]?
  var nextPage: Int?

  init?(map: Map) {
  }

  mutating func mapping(map: Map) {
    self.posts <- map["docs"]
    self.nextPage <- map["nextPage"]
  }
}
