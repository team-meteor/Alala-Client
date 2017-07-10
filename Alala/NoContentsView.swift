//
//  NoContentsView.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 6. 27..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

protocol NoContentsViewDelegate: class {
  func addContentButtonTap(sender: UIButton)
}

// MARK: -
class NoContentsView: UIView {

  let GUIDE_ICON_SIZE = 80
  weak var delegate: NoContentsViewDelegate?

  // MARK: - UI Objets
  let innerView = UIView()

  let guideIconImageView = UIImageView().then {
    $0.image = (UIImage(named: "plus"))
  }

  let guideTitleLabel = UILabel().then {
    $0.font = UIFont(name: "HelveticaNeue", size: 30)
    $0.text = "Share Photos and Videos"
    $0.textAlignment = .center
    $0.sizeToFit()
  }

  let guideDescLabel = UILabel().then {
    $0.font = UIFont(name: "HelveticaNeue", size: 16)
    $0.text = "When you share photos and videos, they'll appear on your profile."
    $0.textAlignment = .center
    $0.numberOfLines = 0
    $0.sizeToFit()
  }

  let addContentButton = UIButton().then {
    $0.setTitle("Share your first photo or video", for: .normal)
    $0.addTarget(self, action: #selector(addContentButtonTap(sender:)), for: .touchUpInside)
    $0.setTitleColor(UIColor.blue, for: .normal)
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
    self.addSubview(innerView)
    innerView.addSubview(guideIconImageView)
    innerView.addSubview(guideTitleLabel)
    innerView.addSubview(guideDescLabel)
    innerView.addSubview(addContentButton)

    // Setup Constraints
    innerView.snp.makeConstraints { (make) in
      make.top.equalTo(guideIconImageView)
      make.left.equalTo(self)
      make.right.equalTo(self)
      make.bottom.equalTo(addContentButton)
      make.centerX.equalTo(self)
      make.centerY.equalTo(self)
    }

    guideIconImageView.snp.makeConstraints { (make) in
      make.top.equalTo(innerView)
      make.centerX.equalTo(innerView)
      make.width.equalTo(GUIDE_ICON_SIZE)
      make.height.equalTo(GUIDE_ICON_SIZE)
    }

    guideTitleLabel.snp.makeConstraints { (make) in
      make.top.equalTo(guideIconImageView.snp.bottom).offset(10)
      make.left.equalTo(innerView)
      make.right.equalTo(innerView)
    }

    guideDescLabel.snp.makeConstraints { (make) in
      make.top.equalTo(guideTitleLabel.snp.bottom).offset(10)
      make.left.equalTo(innerView)
      make.right.equalTo(innerView)
    }
    addContentButton.snp.makeConstraints { (make) in
      make.top.equalTo(guideDescLabel.snp.bottom).offset(30)
      make.left.equalTo(innerView)
      make.right.equalTo(innerView)
    }
  }

  // MARK: - User Action
  func addContentButtonTap(sender: UIButton) {
    delegate?.addContentButtonTap(sender: sender)
  }
}
