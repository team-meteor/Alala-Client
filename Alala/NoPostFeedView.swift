//
//  NoPostFeedView.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 8. 7..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import SnapKit

protocol NoPostFeedViewDelegate: class {
  func NoPostFeedViewWelcomeButtonDidTap()
}

class NoPostFeedView: UIScrollView {

  weak var noFeedDelegate: NoPostFeedViewDelegate?

  let welcomeBoxView = UIView().then {
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.layer.cornerRadius = 5
    $0.layer.borderWidth = 1
  }

  let welcomeIconView = CircleImageView().then {
    $0.layer.borderWidth = 2
    $0.layer.masksToBounds = false
    $0.layer.borderColor = UIColor.darkGray.cgColor
    $0.image = UIImage(named: "home")?.imageWithInset(insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    $0.contentMode = .center
  }

  let welcomeTitle = UILabel().then {
    $0.font = UIFont(.small)
    $0.text = LS("welcome_title")
    $0.textAlignment = .center
    $0.textColor = UIColor.darkGray
    $0.sizeToFit()
  }

  let welcomeDesc = UILabel().then {
    $0.font = UIFont(.tiny)
    $0.text = LS("welcome_desc")
    $0.textAlignment = .center
    $0.textColor = UIColor.lightGray
    $0.sizeToFit()
  }

  let welcomeButton = RoundCornerButton(.buttonColorTypeBlue).then {
    $0.setTitle(LS("welcome_button"), for: .normal)
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    $0.sizeToFit()
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
    self.addSubview(welcomeBoxView)
    welcomeBoxView.addSubview(welcomeIconView)
    welcomeBoxView.addSubview(welcomeTitle)
    welcomeBoxView.addSubview(welcomeDesc)
    welcomeBoxView.addSubview(welcomeButton)

    welcomeBoxView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

    welcomeBoxView.snp.makeConstraints { (make) in
      make.centerX.equalTo(self)
      make.edges.equalTo(self).inset(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
      make.bottom.equalTo(welcomeButton.snp.bottom).offset(20)
    }

    welcomeIconView.snp.makeConstraints { (make) in
      make.top.equalTo(welcomeBoxView).offset(20)
      make.centerX.equalTo(welcomeBoxView)
      make.width.height.equalTo(100)
    }

    welcomeTitle.sizeToFit()
    welcomeTitle.snp.makeConstraints { (make) in
      make.top.equalTo(welcomeIconView.snp.bottom).offset(10)
      make.leftMargin.rightMargin.equalTo(welcomeBoxView)
      make.height.equalTo(welcomeTitle.frame.height)
    }

    welcomeDesc.sizeToFit()
    welcomeDesc.snp.makeConstraints { (make) in
      make.top.equalTo(welcomeTitle.snp.bottom).offset(10)
      make.leftMargin.rightMargin.equalTo(welcomeBoxView)
      make.height.equalTo(welcomeDesc.frame.height)
    }

    welcomeButton.sizeToFit()
    welcomeButton.snp.makeConstraints { (make) in
      make.top.equalTo(welcomeDesc.snp.bottom).offset(10)
      make.leftMargin.rightMargin.equalTo(welcomeBoxView)
      make.height.equalTo(30)
    }
    welcomeButton.addTarget(self, action: #selector(welcomeButtonDidTap), for: .touchUpInside)

    self.backgroundColor = UIColor(rgb: 0xefefef)
    welcomeBoxView.backgroundColor = UIColor.white
  }

  func welcomeButtonDidTap() {
    noFeedDelegate?.NoPostFeedViewWelcomeButtonDidTap()
  }
}
