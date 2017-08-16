//
//  Feed.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import ObjectMapper

class Feed: NSObject, Mappable {
  internal var _posts: [Post]?
  internal var _nextPage: String?

  required init?(map: Map) {
  }

  func mapping(map: Map) {
    self._posts <- map["docs"]
    self._nextPage <- map["nextPage"]
  }
}
