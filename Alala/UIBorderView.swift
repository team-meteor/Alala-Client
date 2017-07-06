//
//  UIBorderView.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 6. 27..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

/**
 * border를 상단/하단 특정side에만 설정해주는 커스텀 UIView
 *
 * topBorderLine, bottomBorderLine의 isHidden속성을 변경하여 설정 *(default:hidden)*
 */
class UIBorderView: UIView {
  let topBorderLine = UIView().then {
    $0.backgroundColor = UIColor.lightGray
    $0.isHidden = true
  }
  let bottomBorderLine = UIView().then {
    $0.backgroundColor = UIColor.lightGray
    $0.isHidden = true
  }

  // MARK: - Initialize
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupUI()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupUI() {
    // Setup UI
    self.addSubview(topBorderLine)
    self.addSubview(bottomBorderLine)

    // Setup Constraints
    topBorderLine.snp.makeConstraints { (make) in
      make.top.equalTo(self)
      make.left.equalTo(self)
      make.right.equalTo(self)
      make.height.equalTo(0.5)
    }

    bottomBorderLine.snp.makeConstraints { (make) in
      make.left.equalTo(self)
      make.right.equalTo(self)
      make.bottom.equalTo(self)
      make.height.equalTo(0.5)
    }
  }
}
