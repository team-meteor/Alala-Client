//
//  String.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 7. 6..
//  Copyright © 2017 team-meteor. All rights reserved.
//
import UIKit

extension String {
  var ns: NSString {
    return self as NSString
  }
  var pathExtension: String {
    return ns.pathExtension
  }
  var isVideoPathExtension: Bool {
    if pathExtension == "mp4" {
      return true
    } else {
      return false
    }
  }
  var lastPathComponent: String {
    return ns.lastPathComponent
  }
}
