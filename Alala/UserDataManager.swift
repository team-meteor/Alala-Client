//
//  AuthDataManager.swift
//  Alala
//
//  Created by hoemoon on 07/08/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import Foundation
import Alamofire

public class UserDataManager {
  static var shared = UserDataManager()
  private(set) var currentUser: User? {
    willSet {
      if let bookmarks = newValue?.bookMarks {
        _bookmarkMeta = [:]
        for post in bookmarks {
          _bookmarkMeta[post.id] = post
        }
      }
      if let followings = newValue?.following {
        _followingMeta = [:]
        for user in followings {
          _followingMeta[user.id] = user
        }
      }
    }
  }
  private let _defaults = UserDefaults.standard
  private(set) var authToken: String? {
    get {
      return _defaults.value(forKey: Constants.DEFAULTS_TOKEN) as? String
    }
    set {
      _defaults.set(newValue, forKey: Constants.DEFAULTS_TOKEN)
    }
  }
  internal var headers: [String: String] {
    get {
      var headers = ["Content-Type": "application/json; charset=utf-8"]
      guard let token = self.authToken else { return headers }
      headers["Authorization"] = "Bearer " + token
      return headers
    }
  }
  private var _bookmarkMeta = [String: Post]()
  private var _followingMeta = [String: User]()
  internal var _userNetworkManager = UserNetworkManager() // 이름 바꾸기

  public func registerWithCloud(
    email: String,
    password: String,
    completion: @escaping (_ isSuccess: Bool) -> Void) {

    _userNetworkManager.register(email: email, password: password) {
      (success, message) in
      if success {
        completion(true)
      } else {
        completion(false)
        print(message)
      }
    }
  }

  public func loginWithCloud(
    email: String,
    password: String,
    completion: @escaping (_ isSuccess: Bool) -> Void) {

    _userNetworkManager.login(email: email, password: password) {
      (isSuccess, token) in
      if isSuccess {
        self.authToken = token
        completion(true)
      } else {
        self.authToken = nil
        completion(false)
      }
    }
  }

  public func logoutWithCloud(
    completion: @escaping (_ success: Bool) -> Void) {
    _userNetworkManager.logout(headers: self.headers) { isSuccess in
      if isSuccess {
        self.authToken = nil
        completion(true)
      } else {
        completion(false)
      }
    }
  }

  public func checkProfileNameUniqueWithCloud(
    profilename: String,
    completion: @escaping (_ isUnique: Bool) -> Void) {

    _userNetworkManager.checkProfileNameUnique(
      headers: self.headers,
      profilename: profilename) { isUnique in
      if isUnique {
        completion(true)
      } else {
        completion(false)
      }
    }
  }

  internal func updateProfileWithCloud(
    profileName: String?,
    imageID: String?,
    userInfo: User?,
    completion: @escaping (_ isSuccess: Bool) -> Void) {

    if let user = userInfo {
      _userNetworkManager.updateProfile(
        headers: headers,
        userInfo: user) {
          isUpdateSuccess in
          if isUpdateSuccess {
            completion(true)
          } else {
            completion(false)
          }
      }
    } else if let name = profileName, let id = imageID {
      _userNetworkManager.updateProfile(
        headers: headers,
        profileName: name,
        profileImageId: id) {

        isUpdated in
        if isUpdated {
          completion(true)
        } else {
          completion(true)
        }
      }
    }
  }

  internal func getMeWithCloud(
    completion: @escaping (_ user: User?) -> Void) {

    _userNetworkManager.me(headers: headers) { user in
      guard let user = user else {
        self.currentUser = nil
        completion(nil)
        return
      }
      self.currentUser = user
      completion(user)
    }
  }

  public func isBookmarked(with id: String) -> Bool {
    if let _ = _bookmarkMeta[id] {
      return true
    } else {
      return false
    }
  }

  public func isFollowing(with id: String) -> Bool {
    if let _ = _followingMeta[id] {
      return true
    } else {
      return false
    }
  }

  internal func getAllUsersWithCloud(completion: @escaping ([User]) -> Void) {
    _userNetworkManager.getAllRegisterdUsers(headers: headers) { users in
      if let users = users {
        completion(users as! [User])
      } else {
        completion([])
      }
    }
  }

  internal func followWithCloud(
    id: String,
    completion: @escaping (DataResponse<User>) -> Void) {

    var url = ""
    if self.isFollowing(with: id) {
      url = "unfollow"
    } else {
      url = "follow"
    }
    _userNetworkManager.follow(headers: headers, id: id, url: url) {
      response, user in
      self.currentUser = user
      completion(response)
    }
  }

  internal func getUserWithCloud(
    id: String,
    completion: @escaping (DataResponse<User>) -> Void ) {

    _userNetworkManager.getUser(headers: headers, id: id) { response in
      completion(response)
    }
  }

  internal func bookmarkPostWithCloud(
    post: Post,
    completion: @escaping (DataResponse<User>) -> Void
    ) {

    var url = ""
    if self.isBookmarked(with: post.id) {
      url = "bookmark/remove"
    } else {
      url = "bookmark/add"
    }
    _userNetworkManager.bookmarkPost(
      headers: headers,
      post: post,
      url: url) {

      user, response in
        self.currentUser = user
        completion(response)
    }
  }
}
