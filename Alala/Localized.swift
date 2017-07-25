//
//  Localized.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 7. 24..
//  Copyright © 2017 team-meteor. All rights reserved.
//
import UIKit

/**
 * 앱의 다국어 지원을 위한 NSLocalizedString을 보다 간결하게 사용하기 위한 커스텀 함수
 *
 * - parameter stringKey: Localizable.strings파일의 좌측에 정의되는 string key
 * - returns: 해당 사용자의 언어에 해당하는 string value
 */
func LS(_ stringKey: String) -> String {
  return NSLocalizedString(stringKey, comment: "")
}
