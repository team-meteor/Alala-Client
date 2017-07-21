//
//  CommentLabel.swift
//  Alala
//
//  Created by hoemoon on 20/07/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class CommentLabel: UILabel {
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.numberOfLines = 0
    self.lineBreakMode = .byCharWrapping
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
