//
//  DiscoverView.swift
//  Alala
//
//  Created by lee on 2017. 7. 15..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit

class DiscoverView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupUI()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  func setupUI() {
    self.backgroundColor = .blue
  }

}
