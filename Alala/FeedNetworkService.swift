//
//  FeedNetworkService.swift
//  Alala
//
//  Created by hoemoon on 07/08/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import Alamofire

protocol FeedNetworkService {
  func feed(
    userId: String?,
    paging: Paging,
    completion: @escaping (DataResponse<Feed>) -> Void)
}
