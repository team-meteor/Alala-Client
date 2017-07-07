//
//  FeedService.swift
//  Alala
//
//  Created by hoemoon on 24/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import Alamofire
import ObjectMapper

enum Paging {
  case refresh
  case next(String)
}

struct FeedService {
  static func feed(paging: Paging, completion: @escaping (DataResponse<Feed>) -> Void) {
    guard let token = AuthService.instance.authToken else {
      return
    }
    let headers = [
      "Authorization": "Bearer " + token
    ]
    let body: [String: Any]
    switch paging {
    case .refresh:
      body = ["page": ""]
    case .next(let nextpage):
      body = ["page": nextpage]
    }
    Alamofire.request(Constants.BASE_URL + "post/feed", method: .post, parameters: body, headers: headers)
      .validate(statusCode: 200..<300)
      .responseJSON { (response) in
        if let feed = Mapper<Feed>().map(JSONObject: response.result.value) {
          let response = DataResponse(request: response.request, response: response.response, data: response.data, result: Result.success(feed))
          completion(response)
        }
    }
  }

  static func feedMine(paging: Paging, completion: @escaping (DataResponse<Feed>) -> Void) {
    guard let token = AuthService.instance.authToken else {
      return
    }
    let headers = [
      "Authorization": "Bearer " + token
    ]
    let body: [String: Any]
    switch paging {
    case .refresh:
      body = ["page": ""]
    case .next(let nextpage):
      body = ["page": nextpage]
    }
    Alamofire.request(Constants.BASE_URL + "post/mine", method: .post, parameters: body, headers: headers)
      .validate(statusCode: 200..<300)
      .responseJSON { (response) in
        if let feed = Mapper<Feed>().map(JSONObject: response.result.value) {
          let response = DataResponse(request: response.request, response: response.response, data: response.data, result: Result.success(feed))
          completion(response)
        }
    }
  }
}
