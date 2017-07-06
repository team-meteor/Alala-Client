//
//  RoundCornerButton.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 7. 1..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

/**
 * 모서리가 둥글게 라운딩 된 커스텀 버튼
 *
 * - 사용처 : 프로필 정보 화면, 팔로우/팔로잉 화면 등
 * - 버튼 컬러 타입
 * 1. buttonColorTypeWhite : backgroundColor white, titleColor black
 * 2. buttonColorTypeBlue  : backgroundColor blue,  titleColor white
 */
class RoundCornerButton: UIButton {

  enum ButtonColorType: Int {
    case buttonColorTypeWhite  = 0
    case buttonColorTypeBlue   = 1
  }

  var nomalBorderColor: UIColor!
  var highlightBorderColor: UIColor!

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupWhiteType()
    setupCommon()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  required init(type: ButtonColorType) {
    super.init(frame: .zero)

    switch type {
    case .buttonColorTypeWhite:
      setupWhiteType()
    case .buttonColorTypeBlue:
      setupBlueType()
    }

    setupCommon()
  }

  func setupCommon() {
    self.layer.borderColor = nomalBorderColor.cgColor
    self.layer.cornerRadius = 3
    self.layer.borderWidth = 1

    self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
  }

  func setupWhiteType() {
    nomalBorderColor = UIColor(rgb: 0xdddddd)
    highlightBorderColor = UIColor(rgb: 0xeeeeee)
    self.setTitleColor(UIColor.black, for: .normal)
    self.backgroundColor = UIColor.white
  }

  func setupBlueType() {
    nomalBorderColor = UIColor(rgb: 0xdddddd)
    highlightBorderColor = UIColor(rgb: 0xeeeeee)
    self.setTitleColor(UIColor.white, for: .normal)
    self.backgroundColor = UIColor.blue
  }

  override var isHighlighted: Bool {
    didSet {
      switch isHighlighted {
      case true:
        layer.borderColor = highlightBorderColor.cgColor
      case false:
        layer.borderColor = nomalBorderColor.cgColor
      }
    }
  }
}
