//
//  CircleImageView.swift
//  Alala
//
//  Created by hoemoon on 19/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class CircleImageView: UIImageView {
  override func layoutSubviews() {
    super.layoutSubviews()
    self.contentMode = .scaleAspectFill
    updateCornerRadius()
  }

  private func updateCornerRadius() {
    self.layer.cornerRadius = min(bounds.width, bounds.height) / 2
  }
}
