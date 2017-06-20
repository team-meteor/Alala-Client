//
//  Post.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import ObjectMapper

struct Post {

  var photoID: String!
  var description: String!

  mutating func setPost(id: String, message: String) {
    self.photoID = id
    self.description = message
  }
}
