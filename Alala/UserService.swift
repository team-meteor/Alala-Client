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
  private var token: String {
    get {
      if let token = AuthService.instance.authToken {
        return token
      } else {
        return ""
      }
    }
  }
  private var headers: [String: String] {
    get {
      return [
        "Authorization": "Bearer " + token,
        "Content-Type": "application/json; charset=utf-8"
      ]
    }
  }

  //전체 회원가입자 불러오기
  func getAllRegisterdUsers(completion: @escaping (_ users: [User?]?) -> Void) {
    Alamofire.request(Constants.BASE_URL + "/user/all", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
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
        } else {
          completion(nil)
        }
    }
  }

  func follow(id: String, completion: @escaping (DataResponse<User>) -> Void) {
    let body: [String : String] = ["id": id]
    var url = ""
    if let _ = AuthService.instance.follwingMeta[id] {
      url = "unfollow"
    } else {
      url = "follow"
    }
    Alamofire.request(Constants.BASE_URL + "user/" + url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers)
      .validate(statusCode: 200..<300)
      .responseJSON { response in
        if let user = Mapper<User>().map(JSONObject: response.result.value) {
          let response = DataResponse(request: response.request, response: response.response, data: response.data, result: Result.success(user))
          //AuthService.instance.currentUser = user
          completion(response)
        }
    }
  }

  func getUser(id: String, completion: @escaping (DataResponse<User>) -> Void) {
    Alamofire.request(Constants.BASE_URL + "user/model", method: .get, parameters: ["id": id], headers: headers)
      .validate(statusCode: 200..<300)
      .responseJSON { response in
        if let user = Mapper<User>().map(JSONObject: response.result.value) {
          let response = DataResponse(request: response.request, response: response.response, data: response.data, result: Result.success(user))
          completion(response)
        }
    }
  }
}
