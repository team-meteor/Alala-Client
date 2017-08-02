//
//  AuthService.swift
//  Alala
//
//  Created by hoemoon on 13/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import Alamofire
import ObjectMapper

class AuthService {
  static let instance = AuthService()
  var currentUser: User? {
    willSet {
      if let bookmarks = newValue?.bookMarks {
        for post in bookmarks {
          currentUserMeta["bookmarkIDs"]?.append(post.id)
        }
      }
    }
  }
  var currentUserMeta = [String: [String]]()
  let defaults = UserDefaults.standard
  var isRegistered: Bool? {
    get {
      return defaults.bool(forKey: Constants.DEFAULTS_REGISTERED) == true
    }
    set {
      defaults.set(newValue, forKey: Constants.DEFAULTS_REGISTERED)
    }
  }
  var isAuthenticated: Bool? {
    get {
      return defaults.bool(forKey: Constants.DEFAULTS_AUTHENTICATED) == true
    }
    set {
      defaults.set(newValue, forKey: Constants.DEFAULTS_AUTHENTICATED)
    }
  }
  var email: String? {
    get {
      return defaults.value(forKey: Constants.DEFAULTS_EMAIL) as? String
    }
    set {
      defaults.set(newValue, forKey: Constants.DEFAULTS_EMAIL)
    }
  }
  var authToken: String? {
    get {
      return defaults.value(forKey: Constants.DEFAULTS_TOKEN) as? String
    }
    set {
      defaults.set(newValue, forKey: Constants.DEFAULTS_TOKEN)
    }
  }
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

  func me(completion: @escaping (_ user: User?) -> Void) {
    let urlString = Constants.BASE_URL + "user/me"
    guard let token = self.authToken else {
      completion(nil)
      return
    }
    let headers = [
      "Authorization": "Bearer " + token
    ]
    Alamofire.request(urlString, method: .get, headers: headers)
      .validate(statusCode: 200..<300)
      .responseJSON { response in
        if response.result.error == nil {
          self.currentUser = Mapper<User>().map(JSONObject: response.result.value)
          print(self.currentUser ?? "")
          completion(self.currentUser)
        } else {
          print("HTTP Request failed: \(String(describing: response.result.error))")
          completion(nil)
        }
    }
  }

  func login(email: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
    let json = ["email": email, "password": password]
    let sessionConfig = URLSessionConfiguration.default
    let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

    guard let URL = URL(string: Constants.BASE_URL + "user/login") else {
      completion(false)
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
            completion(false)
            return
          } else {
            guard let data = data else {
              completion(false)
              return
            }
            do {
              let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]
              if result != nil {
                if let email = result?["user"] as? String {
                  if let token = result?["token"] as? String {
                    self.email = email
                    self.authToken = token
                    completion(true)
                  } else {
                    completion(false)
                  }
                } else {
                  completion(false)
                }
              } else {
                completion(false)
              }
            } catch let err {
              completion(false)
              print(err)
            }
          }
        } else {
          print("URL Session Task Failed: \(error!.localizedDescription)")
          completion(false)
          return
        }
      })
      task.resume()
      session.finishTasksAndInvalidate()

    } catch let err {
      completion(false)
      print(err)
    }
  }

  func logout(completion: @escaping (_ success: Bool) -> Void) {
    guard let token = self.authToken else {
      completion(false)
      return
    }
    let headers = [
      "Authorization": "Bearer " + token
    ]
    Alamofire.request(Constants.BASE_URL + "user/logout", method: .get, headers: headers)
      .validate(statusCode: 200..<300)
      .response { (dataResponse) in
        if dataResponse.response?.statusCode == 200 {
          self.authToken = nil
          completion(true)
        } else {
          completion(false)
        }
    }
  }

  func checkUsernameUnique(username: String, completion: @escaping (_ isUnique: Bool) -> Void) {
    let headers = [
      "Content-Type": "application/json; charset=utf-8"
    ]
    let body: [String : Any] = [
      "name": username
    ]
    Alamofire.request(Constants.BASE_URL + "user/profile/checkname", method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers)
      .validate(statusCode: 200..<300)
      .responseJSON { response in
        switch response.result {
        case .success(let json):
          let dict = json as! [String: Any]
          completion(dict["isunique"] as! Bool)
        case .failure(let error):
          print(error)
          completion(false)
        }
    }
  }

  func updateProfile(profileName: String, profileImageId: String, completion: @escaping (_ success: Bool) -> Void) {
    guard let token = self.authToken else { return }
    let headers = [
      "Authorization": "Bearer " + token,
      "Content-Type": "application/json; charset=utf-8"
    ]
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

  func updateProfile(userInfo: User, completion: @escaping (_ success: Bool) -> Void) {
    guard let token = self.authToken else { return }
    let headers = [
      "Authorization": "Bearer " + token,
      "Content-Type": "application/json; charset=utf-8"
    ]
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
}
