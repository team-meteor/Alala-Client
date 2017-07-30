//
//  UserService.swift
//  Alala
//
//  Created by junwoo on 2017. 7. 29..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import Alamofire
import ObjectMapper

class UserService {
  static let instance = UserService()
  let defaults = UserDefaults.standard
  var authToken: String? {
    get {
      return defaults.value(forKey: Constants.DEFAULTS_TOKEN) as? String
    }
    set {
      defaults.set(newValue, forKey: Constants.DEFAULTS_TOKEN)
    }
  }

  //전체 회원가입자 불러오기
  func getAllRegisterdUsers(completion: @escaping (_ users: [User?]?) -> Void) {

    guard let token = self.authToken else { return }

    let headers = [
      "Authorization": "Bearer " + token
    ]

    Alamofire.request(Constants.BASE_URL + "/user/all", method: .get, headers: headers)
      .validate(statusCode: 200..<300)
      .responseJSON { response in
        if response.result.error == nil {
          var allUsers = [User]()
          if let rawUsers = response.result.value as! [Any]? {
            for rawUser in rawUsers {
              let user = Mapper<User>().map(JSONObject: rawUser)
              allUsers.append(user!)
              if allUsers.count == rawUsers.count {
                completion(allUsers)
              }
            }
          }
          completion(allUsers)
        } else {
          print("HTTP Request failed: \(String(describing: response.result.error))")
          completion(nil)
        }
    }
  }

  //follow
  func followUser(id: String, completion: @escaping (_ success: Bool) -> Void) {

    guard let token = self.authToken else { return }
    let headers = [
      "Authorization": "Bearer " + token,
      "Content-Type": "application/json; charset=utf-8"
      ]

    // JSON Body
    let body: [String : String] = [
      "id": id
    ]
    print("id", id)
    // Fetch Request
    Alamofire.request(Constants.BASE_URL + "/user/follow", method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers)
      .validate(statusCode: 200..<300)
      .responseString { response in
        if (response.result.error == nil) {
          completion(true)
        } else {
          completion(false)
        }
    }
  }

  func unfollowUser(id: String, completion: @escaping (_ success: Bool) -> Void) {
    guard let token = self.authToken else { return }
    let headers = [
      "Authorization": "Bearer " + token,
      "Content-Type": "application/json; charset=utf-8",
      ]

    // JSON Body
    let body: [String : String] = [
      "id": id
    ]
    print("id", id)
    // Fetch Request
    Alamofire.request(Constants.BASE_URL + "/user/unfollow", method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers)
      .validate(statusCode: 200..<300)
      .responseString { response in
        if (response.result.error == nil) {
          completion(true)
        } else {
          completion(false)
        }

    }
  }
}
