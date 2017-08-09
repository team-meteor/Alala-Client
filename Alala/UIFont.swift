//
//  UIFont.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 8. 9..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

extension UIFont {
  static let DEFAULT_FONT_NAME = FontName.helveticaNeue.value

  convenience init(_ size: CGFloat) {
    self.init(name: UIFont.DEFAULT_FONT_NAME, size: size)!
  }

  convenience init(_ size: FontSize) {
    self.init(name: UIFont.DEFAULT_FONT_NAME, size: size.value)!
  }

  convenience init(_ name: FontName, _ size: FontSize) {
    self.init(name: name.value, size: size.value)!
  }
}


enum FontSize {

  case navigation

  case large

  case medium

  case small

  case tiny

  var value: CGFloat {
    switch self {
    case .navigation: return 20.0
    case .large: return 30.0
    case .medium: return 16.0
    case .small: return 14.0
    case .tiny: return 12.0
    }
  }

}

enum FontName {

  case helveticaNeue

  case iowanOldStyleBoldItalic

  var value: String {
    switch self {
    case .helveticaNeue: return "HelveticaNeue"
    case .iowanOldStyleBoldItalic: return "IowanOldStyle-BoldItalic"
    }
  }

}
