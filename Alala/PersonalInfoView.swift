//
//  PersonalInfoView.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 6. 27..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

protocol PersonalInfoViewDelegate: class {
  func postsAreaTap()
  func followersAreaTap()
  func followingAreaTap()

  func editProfileButtonTap(sender: UIButton)
  func optionsButtonTap(sender: UIButton)
}

// MARK: -
class PersonalInfoView: UIView {
  var delegate: PersonalInfoViewDelegate?

  //var userInfo : User

  // MARK: - UI Objects
  let infoView = UIView()

  let profileImageView = CircleImageView().then {
    $0.layer.borderWidth = 1
    $0.layer.masksToBounds = false
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.clipsToBounds = true
    $0.isUserInteractionEnabled = true
  }

  let profileNameLabel = UILabel().then {
    $0.font = UIFont(name: "HelveticaNeue", size: 16)
    $0.text = "User Name up to 30 character"
    $0.sizeToFit()
  }

  let postsButton = UIButton().then {
     $0.addTarget(self, action: #selector(postsButtonTap(sender:)), for: .touchUpInside)
  }

  let postsCountLabel = UILabel().then {
    $0.font = UIFont(name: "HelveticaNeue", size: 14)
    $0.text = "0"
    $0.textAlignment = .center
    $0.sizeToFit()
  }

  let postsTextLabel = UILabel().then {
    $0.font = UIFont(name: "HelveticaNeue", size: 12)
    $0.text = "posts"
    $0.textAlignment = .center
    $0.sizeToFit()
  }

  let followersButton = UIButton().then {
    $0.addTarget(self, action: #selector(followersButtonTap(sender:)), for: .touchUpInside)
  }

  let followersCountLabel = UILabel().then {
    $0.font = UIFont(name: "HelveticaNeue", size: 14)
    $0.text = "0"
    $0.textAlignment = .center
    $0.sizeToFit()
  }

  let followersTextLabel = UILabel().then {
    $0.font = UIFont(name: "HelveticaNeue", size: 12)
    $0.text = "followers"
    $0.textAlignment = .center
    $0.sizeToFit()
  }

  let followingButton = UIButton().then {
    $0.addTarget(self, action: #selector(followingButtonTap(sender:)), for: .touchUpInside)
  }

  let followingCountLabel = UILabel().then {
    $0.font = UIFont(name: "HelveticaNeue", size: 14)
    $0.text = "0"
    $0.textAlignment = .center
    $0.sizeToFit()
  }

  let followingTextLabel = UILabel().then {
    $0.font = UIFont(name: "HelveticaNeue", size: 12)
    $0.text = "following"
    $0.textAlignment = .center
    $0.sizeToFit()
  }

  let editProfileButton = UIButton().then {
    $0.layer.cornerRadius = 5
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    $0.setTitle("Edit Profile", for: .normal)
    $0.setTitleColor(UIColor.black, for: .normal)
    $0.addTarget(self, action: #selector(editProfileButtonTap(sender:)), for: .touchUpInside)
  }

  let optionsButton = UIButton().then {
    $0.layer.cornerRadius = 5
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.setImage(UIImage(named: "heart"), for: UIControlState.normal)
    $0.setImage(UIImage(named: "heart-selected"), for: UIControlState.highlighted)
    $0.imageView?.contentMode = UIViewContentMode.scaleAspectFit
    $0.addTarget(self, action: #selector(optionsButtonTap(sender:)), for: .touchUpInside)
  }

  let subMenuBar = UIBorderView().then {
    $0.topBorderLine.isHidden = false
    $0.bottomBorderLine.isHidden = false
  }

  let gridPostMenuButton = UIButton().then {
    $0.setImage(UIImage(named: "heart"), for: UIControlState.normal)
    $0.setImage(UIImage(named: "heart-selected"), for: UIControlState.highlighted)
  }

  let listPostMenuButton = UIButton().then {
    $0.setImage(UIImage(named: "heart"), for: UIControlState.normal)
    $0.setImage(UIImage(named: "heart-selected"), for: UIControlState.highlighted)
  }

  let photosForYouMenuButton = UIButton().then {
    $0.setImage(UIImage(named: "heart"), for: UIControlState.normal)
    $0.setImage(UIImage(named: "heart-selected"), for: UIControlState.highlighted)
  }

  let savedMenuButton = UIButton().then {
    $0.setImage(UIImage(named: "heart"), for: UIControlState.normal)
    $0.setImage(UIImage(named: "heart-selected"), for: UIControlState.highlighted)
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
    self.addSubview(infoView)
    infoView.addSubview(profileImageView)
    infoView.addSubview(profileNameLabel)

    infoView.addSubview(postsButton)
    postsButton.addSubview(postsCountLabel)
    postsButton.addSubview(postsTextLabel)

    infoView.addSubview(followersButton)
    followersButton.addSubview(followersCountLabel)
    followersButton.addSubview(followersTextLabel)

    infoView.addSubview(followingButton)
    followingButton.addSubview(followingCountLabel)
    followingButton.addSubview(followingTextLabel)

    infoView.addSubview(editProfileButton)
    infoView.addSubview(optionsButton)

    self.addSubview(subMenuBar)
    subMenuBar.addSubview(gridPostMenuButton)
    subMenuBar.addSubview(listPostMenuButton)
    subMenuBar.addSubview(photosForYouMenuButton)
    subMenuBar.addSubview(savedMenuButton)

    // Setup Constraints
    infoView.snp.makeConstraints { (make) in
      make.top.equalTo(self)
      make.left.equalTo(self)
      make.right.equalTo(self)
      make.leftMargin.equalTo(10)
      make.rightMargin.equalTo(10)
      make.bottom.equalTo(profileNameLabel).offset(10)
    }

    profileImageView.snp.makeConstraints { (make) in
      make.top.equalTo(infoView).offset(10)
      make.left.equalTo(infoView.snp.leftMargin)
      make.width.equalTo(70)
      make.height.equalTo(70)
    }

    profileNameLabel.snp.makeConstraints { (make) in
      make.top.equalTo(profileImageView.snp.bottom).offset(3)
      make.left.equalTo(profileImageView.snp.left)
      make.width.equalTo(infoView).offset(-40)
      make.height.equalTo(20)
    }

    postsButton.snp.makeConstraints { (make) in
      make.top.equalTo(profileImageView.snp.top).offset(5)
      make.left.equalTo(profileImageView.snp.right).offset(10)
      make.right.equalTo(followersCountLabel.snp.left)
      make.height.equalTo(30)
    }
    postsCountLabel.snp.makeConstraints { (make) in
      make.top.equalTo(postsButton)
      make.left.equalTo(postsButton).offset(10)
      make.right.equalTo(postsButton)
      make.height.equalTo(15)
    }
    postsTextLabel.snp.makeConstraints { (make) in
      make.top.equalTo(postsCountLabel.snp.bottom)
      make.left.equalTo(postsButton)
      make.right.equalTo(postsButton)
      make.height.equalTo(15)
    }

    followersButton.snp.makeConstraints { (make) in
      make.top.equalTo(profileImageView.snp.top).offset(5)
      make.left.equalTo(postsButton.snp.right)
      make.right.equalTo(followingCountLabel.snp.left)
      make.width.equalTo(postsButton.snp.width)
      make.height.equalTo(30)
    }
    followersCountLabel.snp.makeConstraints { (make) in
      make.top.equalTo(followersButton)
      make.left.equalTo(followersButton)
      make.right.equalTo(followersButton)
      make.width.equalTo(postsButton)
      make.height.equalTo(15)
    }
    followersTextLabel.snp.makeConstraints { (make) in
      make.top.equalTo(followersCountLabel.snp.bottom)
      make.left.equalTo(followersButton)
      make.right.equalTo(followersButton)
      make.height.equalTo(15)
    }

    followingButton.snp.makeConstraints { (make) in
      make.top.equalTo(profileImageView.snp.top).offset(5)
      make.left.equalTo(followersCountLabel.snp.right)
      make.right.equalTo(infoView.snp.rightMargin)
      make.width.equalTo(postsButton.snp.width)
      make.height.equalTo(30)
    }
    followingCountLabel.snp.makeConstraints { (make) in
      make.top.equalTo(followingButton)
      make.left.equalTo(followingButton)
      make.right.equalTo(followingButton)
      make.width.equalTo(postsButton)
      make.height.equalTo(15)
    }
    followingTextLabel.snp.makeConstraints { (make) in
      make.top.equalTo(followingCountLabel.snp.bottom)
      make.left.equalTo(followingButton)
      make.right.equalTo(followingButton)
      make.height.equalTo(15)
    }

    editProfileButton.snp.makeConstraints { (make) in
      make.top.equalTo(postsTextLabel.snp.bottom).offset(5)
      make.left.equalTo(postsTextLabel.snp.left)
      make.right.equalTo(optionsButton.snp.left).offset(-5)
      make.height.equalTo(25)
    }

    optionsButton.snp.makeConstraints { (make) in
      make.top.equalTo(editProfileButton.snp.top)
      make.left.equalTo(editProfileButton.snp.right).offset(5)
      make.right.equalTo(infoView.snp.right).offset(-10)
      make.width.equalTo(30)
      make.height.equalTo(25)
    }

    subMenuBar.snp.makeConstraints { (make) in
      make.top.equalTo(infoView.snp.bottom)
      make.left.equalTo(self)
      make.right.equalTo(self)
      make.height.equalTo(40)
    }
    gridPostMenuButton.snp.makeConstraints { (make) in
      make.top.equalTo(subMenuBar)
      make.left.equalTo(subMenuBar)
      make.right.equalTo(listPostMenuButton.snp.left)
      make.bottom.equalTo(subMenuBar)
    }
    listPostMenuButton.snp.makeConstraints { (make) in
      make.top.equalTo(subMenuBar)
      make.left.equalTo(gridPostMenuButton.snp.right)
      make.right.equalTo(photosForYouMenuButton.snp.left)
      make.bottom.equalTo(subMenuBar)
      make.width.equalTo(gridPostMenuButton)
    }
    photosForYouMenuButton.snp.makeConstraints { (make) in
      make.top.equalTo(subMenuBar)
      make.left.equalTo(listPostMenuButton.snp.right)
      make.right.equalTo(savedMenuButton.snp.left)
      make.bottom.equalTo(subMenuBar)
      make.width.equalTo(gridPostMenuButton)
    }
    savedMenuButton.snp.makeConstraints { (make) in
      make.top.equalTo(subMenuBar)
      make.left.equalTo(photosForYouMenuButton.snp.right)
      make.right.equalTo(subMenuBar)
      make.bottom.equalTo(subMenuBar)
      make.width.equalTo(gridPostMenuButton)
    }
  }

  // MARK: - User Action
  func postsButtonTap(sender: UIButton) {
    delegate?.postsAreaTap()
  }

  func followersButtonTap(sender: UIButton) {
    delegate?.followersAreaTap()
  }

  func followingButtonTap(sender: UITapGestureRecognizer) {
    delegate?.followingAreaTap()
  }

  func editProfileButtonTap(sender: UIButton) {
    delegate?.editProfileButtonTap(sender: sender)
  }

  func optionsButtonTap(sender: UIButton) {
    delegate?.optionsButtonTap(sender: sender)
  }
}
