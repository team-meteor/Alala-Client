//
//  Post.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import ObjectMapper

struct Post: Mappable {
    
    var id: Int!
    var user: User!
    var photoID: String!
    var message: String?
    var createdAt: Date!
    var isLiked: Bool!
    var likeCount: Int!
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.user <- map["user"]
        self.photoID <- map["photo.id"]
        self.message <- map["message"]
        self.createdAt <- (map["created_at"], ISO8601DateTransform())
        self.isLiked <- map["is_liked"]
        self.likeCount <- map["like_count"]
    }
}
