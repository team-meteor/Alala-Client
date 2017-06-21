//
//  Constants.swift
//  Alala
//
//  Created by hoemoon on 14/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

extension UIDevice {
  static var isSimulator: Bool {
    return ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil
  }
}

struct Constants {
  static var BASE_URL: String {
    if UIDevice.isSimulator {
      return "http://localhost:3005/api/v1/"
    } else {
      return "http://52.78.76.63/api/v1/"
    }
  }
  
  static var STATIC_URL: String {
    if UIDevice.isSimulator {
      return "http://localhost:3005/static"
    } else {
      return "http://52.78.76.63/static"
    }
  }
  
  static let DEFAULTS_REGISTERED = "isRegistered"
  static let DEFAULTS_AUTHENTICATED = "isAuthenticated"

  // Auth Email
  static let DEFAULTS_EMAIL = "email"

  // Auth Token
  static let DEFAULTS_TOKEN = "authToken"
}
