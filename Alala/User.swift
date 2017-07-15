//
//  User.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import ObjectMapper

class User: NSObject, Mappable, NSCoding {
  var id: String!
  var email: String!
  var createdAt: Date!
  var profileName: String?
  var profilePhotoId: String?
  var displayName: String?
  var website: String?
  var bio: String?
  var Phone: String?
  var gender: String?
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

    displayName <- map["displayName"]
    website <- map["website"]
    bio <- map["bio"]
    Phone <- map["Phone"]
    gender <- map["gender"]
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(id, forKey: "id")
    aCoder.encode(email, forKey: "email")
    aCoder.encode(createdAt, forKey: "createdAt")
    aCoder.encode(profileName, forKey: "profileName")
    aCoder.encode(profilePhotoId, forKey: "profilePhotoId")
    aCoder.encode(following, forKey: "following")
    aCoder.encode(followers, forKey: "followers")

    aCoder.encode(displayName, forKey: "displayName")
    aCoder.encode(website, forKey: "website")
    aCoder.encode(bio, forKey: "bio")
    aCoder.encode(Phone, forKey: "Phone")
    aCoder.encode(gender, forKey: "gender")
  }

  public required init?(coder aDecoder: NSCoder) {
    id = aDecoder.decodeObject(forKey: "id") as! String
    email = aDecoder.decodeObject(forKey: "email") as! String
    createdAt = aDecoder.decodeObject(forKey: "createdAt") as! Date
    profileName = aDecoder.decodeObject(forKey: "profileName") as? String
    profilePhotoId = aDecoder.decodeObject(forKey: "profilePhotoId") as? String
    following = aDecoder.decodeObject(forKey: "following") as! [User]?
    followers = aDecoder.decodeObject(forKey: "followers") as! [User]?

    displayName = aDecoder.decodeObject(forKey: "displayName") as? String
    website = aDecoder.decodeObject(forKey: "website") as? String
    bio = aDecoder.decodeObject(forKey: "bio") as? String
    Phone = aDecoder.decodeObject(forKey: "Phone") as? String
    gender = aDecoder.decodeObject(forKey: "gender") as? String
  }

  public static func isEqual(l: User, r: User) -> Bool {
    return
      l.email == r.email &&
      l.createdAt == r.createdAt &&
      l.email == r.email &&
      l.profileName == r.profileName &&
      l.profilePhotoId == r.profilePhotoId &&
      l.displayName == r.displayName &&
      l.website == r.website &&
      l.bio == r.bio &&
      l.Phone == r.Phone &&
      l.gender == r.gender
  }
}
