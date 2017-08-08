//
//  UserNetworkService.swift
//  Alala
//
//  Created by hoemoon on 08/08/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import Foundation
import Alamofire

protocol UserNetworkService {
  func register(email: String, password: String, completion: @escaping (_ success: Bool, _ message: String) -> Void)

  func me(headers: [String : String], completion: @escaping (_ user: User?) -> Void)

  func login(email: String, password: String, completion: @escaping (_ success: Bool, _ token: String?) -> Void)

  func logout(headers: [String : String], completion: @escaping (_ success: Bool) -> Void)

  func checkProfileNameUnique(headers: [String : String], profilename: String, completion: @escaping (_ isUnique: Bool) -> Void)

  func updateProfile(headers: [String : String], profileName: String, profileImageId: String, completion: @escaping (_ success: Bool) -> Void)

  func updateProfile(headers: [String : String], userInfo: User, completion: @escaping (_ success: Bool) -> Void)

  func getAllRegisterdUsers(headers: [String : String], completion: @escaping (_ users: [User?]?) -> Void)

  func follow(headers: [String : String], id: String, url: String, completion: @escaping (_ response: DataResponse<User>, _ user: User) -> Void)

  func getUser(headers: [String : String], id: String, completion: @escaping (DataResponse<User>) -> Void)

  func bookmarkPost(headers: [String : String], post: Post, url: String, completion: @escaping (User, DataResponse<User>) -> Void)

}
