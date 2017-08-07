//
//  AuthNetworkManager.swift
//  Alala
//
//  Created by hoemoon on 13/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import Alamofire
import ObjectMapper

class UserNetworkManager {
  func register(email: String, password: String, completion: @escaping (_ success: Bool, _ message: String) -> Void) {
    let json = ["email": email, "password": password]
    let sessionConfig = URLSessionConfiguration.default
    let session = URLSession(configuration: sessionConfig)
    guard let URL = URL(string: Constants.BASE_URL + "user/register") else {
      completion(false, "Register failed")
      return
    }
    var request = URLRequest(url: URL)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    do {
      request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
      let task = session.dataTask(with: request, completionHandler: { (_: Data?, response: URLResponse?, error: Error?) in
        if error == nil {
          let statusCode = (response as! HTTPURLResponse).statusCode
          print(statusCode)
          if statusCode == 200 {
            completion(true, "Register successe")
            return
          } else if statusCode == 409 {
            completion(false, "User Exists")
            return
          } else {
            completion(false, "Register failed")
            return
          }
        } else {
          completion(false, "Register failed")
        }
      })
      task.resume()
      session.finishTasksAndInvalidate()

    } catch let err {
      completion(false, "Register failed")
      print(err)
    }
  }

  func me(headers: [String: String], completion: @escaping (_ user: User?) -> Void) {
    Alamofire.request(
      Constants.BASE_URL + "user/me",
      method: .get,
      headers: headers)
      .validate(statusCode: 200..<300)
      .responseJSON { response in
        if response.result.error == nil {
          let currentUser = Mapper<User>().map(JSONObject: response.result.value)
          print(currentUser ?? "")
          completion(currentUser)
        } else {
          completion(nil)
        }
    }
  }

  func login(
    email: String,
    password: String,
    completion: @escaping (_ success: Bool, _ token: String?) -> Void) {

    let json = ["email": email, "password": password]
    let sessionConfig = URLSessionConfiguration.default
    let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

    guard let URL = URL(string: Constants.BASE_URL + "user/login") else {
      completion(false, nil)
      return
    }
    var request = URLRequest(url: URL)
    request.httpMethod = "POST"
    request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    do {
      request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
      let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
        if error == nil {
          let statusCode = (response as! HTTPURLResponse).statusCode
          if statusCode != 200 {
            completion(false, nil)
            return
          } else {
            guard let data = data else {
              completion(false, nil)
              return
            }
            do {
              let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]
              if result != nil {
                if let token = result?["token"] as? String {
                  completion(true, token)
                } else {
                  completion(false, nil)
                }
//                if let email = result?["user"] as? String {
//                  if let token = result?["token"] as? String {
////                    self.email = email
////                    self.authToken = token
//                    completion(true, token)
//                  } else {
//                    completion(false, nil)
//                  }
//                } else {
//                  completion(false, nil)
//                }
              } else {
                completion(false, nil)
              }
            } catch let err {
              completion(false, nil)
              print(err)
            }
          }
        } else {
          print("URL Session Task Failed: \(error!.localizedDescription)")
          completion(false, nil)
          return
        }
      })
      task.resume()
      session.finishTasksAndInvalidate()

    } catch let err {
      completion(false, nil)
      print(err)
    }
  }

  func logout(
    headers: [String: String],
    completion: @escaping (_ success: Bool) -> Void) {

    Alamofire.request(
      Constants.BASE_URL + "user/logout",
      method: .get,
      headers: headers)
      .validate(statusCode: 200..<300)
      .response { (dataResponse) in
        if dataResponse.response?.statusCode == 200 {
          completion(true)
        } else {
          completion(false)
        }
    }
  }

  func checkProfileNameUnique(
    headers: [String: String],
    profilename: String,
    completion: @escaping (_ isUnique: Bool) -> Void) {

    Alamofire.request(
      Constants.BASE_URL + "user/profile/checkname",
      method: .post,
      parameters: ["name": profilename],
      encoding: JSONEncoding.default,
      headers: headers)
      .validate(statusCode: 200..<300)
      .responseJSON { response in
        switch response.result {
        case .success(let json):
          let dict = json as! [String: Any]
          completion(dict["isunique"] as! Bool)
        case .failure:
          completion(false)
        }
    }
  }

  func updateProfile(
    headers: [String:String],
    profileName: String,
    profileImageId: String,
    completion: @escaping (_ success: Bool) -> Void) {

    let body: [String : Any] = [
      "profileName": profileName,
      "multipartId": profileImageId
    ]

    Alamofire.request(Constants.BASE_URL + "/user/profile/", method: .put, parameters: body, encoding: JSONEncoding.default, headers: headers)
      .validate(statusCode: 200..<300)
      .responseJSON { response in
        if response.result.error == nil {
          completion(true)
        } else {
          completion(false)
        }
    }
  }

  func updateProfile(
    headers: [String:String],
    userInfo: User,
    completion: @escaping (_ success: Bool) -> Void) {

    let body = userInfo.toJSON() as [String : Any]

    Alamofire.request(Constants.BASE_URL + "/user/profile/", method: .put, parameters: body, encoding: JSONEncoding.default, headers: headers)
      .validate(statusCode: 200..<300)
      .responseJSON { response in
        if response.result.error == nil {
          completion(true)
        } else {
          completion(false)
        }
    }
  }

  func getAllRegisterdUsers(
    headers: [String: String],
    completion: @escaping (_ users: [User?]?) -> Void) {

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

  func follow(
    headers: [String: String],
    id: String,
    url: String,
    completion: @escaping (_ response: DataResponse<User>, _ user: User) -> Void) {

    Alamofire.request(
      Constants.BASE_URL + "user/" + url,
      method: .post,
      parameters: ["id": id],
      encoding: JSONEncoding.default, headers: headers)
      .validate(statusCode: 200..<300)
      .responseJSON { response in
        if let user = Mapper<User>().map(JSONObject: response.result.value) {
          let response = DataResponse(request: response.request, response: response.response, data: response.data, result: Result.success(user))
          completion(response, user)
        }
    }
  }

  func getUser(
    headers: [String: String],
    id: String,
    completion: @escaping (DataResponse<User>) -> Void) {

    Alamofire.request(Constants.BASE_URL + "user/model", method: .get, parameters: ["id": id], headers: headers)
      .validate(statusCode: 200..<300)
      .responseJSON { response in
        if let user = Mapper<User>().map(JSONObject: response.result.value) {
          let response = DataResponse(request: response.request, response: response.response, data: response.data, result: Result.success(user))
          completion(response)
        }
    }
  }

  func bookmarkPost(
    headers: [String: String],
    post: Post,
    url: String,
    completion: @escaping (User, DataResponse<User>) -> Void) {

    let body: [String : Any] = ["id": post.id!]
    Alamofire.request(
      Constants.BASE_URL + "post/" + url,
      method: .post,
      parameters: body,
      encoding: JSONEncoding.default,
      headers: headers)
      .validate(statusCode: 200..<300)
      .responseJSON { response in
        if let user = Mapper<User>().map(JSONObject: response.result.value) {
          let response = DataResponse(request: response.request, response: response.response, data: response.data, result: Result.success(user))
          completion(user, response)
        }
    }
  }
}
