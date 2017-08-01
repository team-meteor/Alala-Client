//
//  PersonalInfoView.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 6. 27..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import SnapKit

protocol PersonalInfoViewDelegate: class {
  func postsAreaTap()
  func followersAreaTap()
  func followingAreaTap()

  func editProfileButtonTap(sender: UIButton)
  func optionsButtonTap(sender: UIButton)

  func gridPostMenuButtonTap(sender: UIButton)
  func listPostMenuButtonTap(sender: UIButton)
  func photosForYouMenuButtonTap(sender: UIButton)
  func savedMenuButtonTap(sender: UIButton)
}

// MARK: -
class PersonalInfoView: UIView {
  weak var delegate: PersonalInfoViewDelegate?

  var isGridMode = true

  //var userInfo : User

  // MARK: - UI Objects
  let infoView = UIView()

  let profileImageView = CircleImageView().then {
    $0.layer.borderWidth = 1
    $0.layer.masksToBounds = false
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.clipsToBounds = true
    $0.isUserInteractionEnabled = true
    $0.image = UIImage(named: "default_user")
    $0.contentMode = .scaleAspectFill
  }

  var profileNameHeightConstraint: Constraint?
  let profileNameLabel = UILabel().then {
    $0.font = UIFont(name: "HelveticaNeue", size: 16)
    $0.sizeToFit()
  }

  var bioHeightConstraint: Constraint?
  let bioLabel = UILabel().then {
    $0.font = UIFont(name: "HelveticaNeue", size: 16)
    $0.numberOfLines = 0
    $0.sizeToFit()
  }

  var websiteHeightConstraint: Constraint?
  let websiteLabel = UILabel().then {
    $0.font = UIFont(name: "HelveticaNeue", size: 16)
    $0.sizeToFit()
  }

  var postsCount: Int = 0 {
    didSet {
      self.postsCountLabel.text = String(describing: postsCount)
      if postsCount <= 0 {
        postsButton.isEnabled = false
        postsCountLabel.isEnabled = false
        postsTextLabel.isEnabled = false

        gridPostMenuButton.isEnabled = false
        listPostMenuButton.isEnabled = false
      } else {
        postsButton.isEnabled = true
        postsCountLabel.isEnabled = true
        postsTextLabel.isEnabled = true

        gridPostMenuButton.isEnabled = true
        listPostMenuButton.isEnabled = true
      }
    }
  }
  fileprivate let postsButton = UIButton().then {
     $0.addTarget(self, action: #selector(postsButtonTap(sender:)), for: .touchUpInside)
  }

  fileprivate let postsCountLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 14)
    $0.text = "0"
    $0.textAlignment = .center
    $0.sizeToFit()
  }

  fileprivate let postsTextLabel = UILabel().then {
    $0.font = UIFont(name: "HelveticaNeue", size: 12)
    $0.text = LS("posts")
    $0.textAlignment = .center
    $0.sizeToFit()
  }

  fileprivate let followersButton = UIButton().then {
    $0.addTarget(self, action: #selector(followersButtonTap(sender:)), for: .touchUpInside)
  }

  fileprivate let followersCountLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 14)
    $0.text = "0"
    $0.textAlignment = .center
    $0.sizeToFit()
  }

  fileprivate let followersTextLabel = UILabel().then {
    $0.font = UIFont(name: "HelveticaNeue", size: 12)
    $0.text = LS("followers")
    $0.textAlignment = .center
    $0.sizeToFit()
  }

  fileprivate let followingButton = UIButton().then {
    $0.addTarget(self, action: #selector(followingButtonTap(sender:)), for: .touchUpInside)
  }

  fileprivate let followingCountLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 14)
    $0.text = "0"
    $0.textAlignment = .center
    $0.sizeToFit()
  }

  fileprivate let followingTextLabel = UILabel().then {
    $0.font = UIFont(name: "HelveticaNeue", size: 12)
    $0.text = LS("following")
    $0.textAlignment = .center
    $0.sizeToFit()
  }

  fileprivate let editProfileButton = RoundCornerButton(.buttonColorTypeWhite).then {
    $0.setTitle(LS("edit_profile"), for: .normal)
    $0.addTarget(self, action: #selector(editProfileButtonTap(sender:)), for: .touchUpInside)
  }

  fileprivate let optionsButton = RoundCornerButton(.buttonColorTypeWhite).then {
    $0.setImage(UIImage(named: "settings")?.resizeImage(scaledTolength: 15), for: UIControlState.normal)
    $0.setImage(UIImage(named: "settings")?.resizeImage(scaledTolength: 15), for: UIControlState.highlighted)
    $0.imageView?.contentMode = UIViewContentMode.scaleAspectFit
    $0.addTarget(self, action: #selector(optionsButtonTap(sender:)), for: .touchUpInside)
  }

  let subMenuBar = UIBorderView().then {
    $0.topBorderLine.isHidden = false
    $0.bottomBorderLine.isHidden = false
  }

  fileprivate let gridPostMenuButton = UIButton().then {
    $0.setImage(UIImage(named: "grid")?.resizeImage(scaledTolength: 26), for: UIControlState.normal)
    $0.setImage(UIImage(named: "grid_selected")?.resizeImage(scaledTolength: 26), for: UIControlState.selected)
    $0.addTarget(self, action: #selector(gridPostMenuButtonTap(sender:)), for: .touchUpInside)
  }

  fileprivate let listPostMenuButton = UIButton().then {
    $0.setImage(UIImage(named: "list")?.resizeImage(scaledTolength: 21), for: UIControlState.normal)
    $0.setImage(UIImage(named: "list_selected")?.resizeImage(scaledTolength: 21), for: UIControlState.selected)
    $0.addTarget(self, action: #selector(listPostMenuButtonTap(sender:)), for: .touchUpInside)
  }

  fileprivate let photosForYouMenuButton = UIButton().then {
    $0.setImage(UIImage(named: "my_photo")?.resizeImage(scaledTolength: 23), for: UIControlState.normal)
    $0.addTarget(self, action: #selector(photosForYouMenuButtonTap(sender:)), for: .touchUpInside)
  }

  fileprivate let savedMenuButton = UIButton().then {
    $0.setImage(UIImage(named: "save-gray")?.resizeImage(scaledTolength: 25), for: UIControlState.normal)
    $0.addTarget(self, action: #selector(savedMenuButtonTap(sender:)), for: .touchUpInside)
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
    infoView.addSubview(bioLabel)
    infoView.addSubview(websiteLabel)

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
      make.bottom.equalTo(websiteLabel).offset(10)
    }

    profileImageView.snp.makeConstraints { (make) in
      make.top.equalTo(infoView).offset(10)
      make.left.equalTo(infoView).offset(10)
      make.width.equalTo(70)
      make.height.equalTo(70)
    }

    postsButton.snp.makeConstraints { (make) in
      make.top.equalTo(profileImageView.snp.top).offset(5)
      make.left.equalTo(profileImageView.snp.right).offset(10)
      make.right.equalTo(followersCountLabel.snp.left)
      make.height.equalTo(30)
    }
    postsCountLabel.snp.makeConstraints { (make) in
      make.top.equalTo(postsButton)
      make.left.equalTo(postsButton)
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
      make.right.equalTo(infoView).offset(-10)
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

    profileNameLabel.snp.makeConstraints { (make) in
      make.top.equalTo(profileImageView.snp.bottom).offset(3)
      make.left.equalTo(profileImageView.snp.left)
      make.width.equalTo(infoView).offset(-40)
      profileNameHeightConstraint = make.height.equalTo(0).constraint
    }

    bioLabel.snp.makeConstraints { (make) in
      make.top.equalTo(profileNameLabel.snp.bottom).offset(3)
      make.left.equalTo(profileNameLabel)
      make.right.equalTo(profileNameLabel)
      bioHeightConstraint = make.height.equalTo(0).constraint
    }

    websiteLabel.snp.makeConstraints { (make) in
      make.top.equalTo(bioLabel.snp.bottom).offset(3)
      make.left.equalTo(profileNameLabel)
      make.right.equalTo(profileNameLabel)
      websiteHeightConstraint = make.height.equalTo(0).constraint
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

    gridPostMenuButton.isSelected = true
  }

  /**
   * User객체의 정보를 UIControl들에 설정
   * @param userInfo 프로필 내용을 설정할 User객체
   */
  func setupUserInfo(userInfo: User) {
    if userInfo.profilePhotoId != nil {
      profileImageView.setImage(with: userInfo.profilePhotoId, size: .medium)
    }

    profileNameLabel.text = userInfo.displayName
    let profileNameOffset = (profileNameLabel.text?.characters.count==0) ? 0 : 20
    self.profileNameHeightConstraint?.update(offset: profileNameOffset)

    bioLabel.text = userInfo.bio
    bioLabel.sizeToFit()
    let bioOffset = (bioLabel.text?.characters.count==0) ? 0 : bioLabel.frame.height
    self.bioHeightConstraint?.update(offset: bioOffset)

    websiteLabel.text = userInfo.website
    let websiteOffset = (websiteLabel.text?.characters.count==0) ? 0 : 20
    self.websiteHeightConstraint?.update(offset: websiteOffset)

    if userInfo.followers != nil && (userInfo.followers?.count)! > 0 {
      followersButton.isEnabled = true
      followersCountLabel.isEnabled = true
      followersTextLabel.isEnabled = true
      followersCountLabel.text = userInfo.followers?.count.description
    } else {
      followersButton.isEnabled = false
      followersCountLabel.isEnabled = false
      followersTextLabel.isEnabled = false
      followersCountLabel.text = "0"
    }

    if userInfo.following != nil && (userInfo.following?.count)! > 0 {
      followingButton.isEnabled = true
      followingCountLabel.isEnabled = true
      followingTextLabel.isEnabled = true
      followingCountLabel.text = userInfo.following?.count.description
    } else {
      followingButton.isEnabled = false
      followingCountLabel.isEnabled = false
      followingTextLabel.isEnabled = false
      followingCountLabel.text = "0"
    }

    self.updateConstraints()
  }

  /**
   * 컨텐츠 유무에 따른 개인프로필 뷰의 서브메뉴바 아이콘 세팅
   * @param hasContents - 해당 유저가 작성한 Post가 있는지의 유무
   *
   * - Post가 없으면 grid/list 아이콘이 비활성화
   * - Post가 있으면 grid/list 아이콘 중 기본값 혹은 마지막 선택값이 활성화
   */
  func setupNoContentsMode(hasContents: Bool) {
    gridPostMenuButton.isEnabled = hasContents
    listPostMenuButton.isEnabled = hasContents

    if hasContents == true {
      gridPostMenuButton.isSelected = true
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

  func gridPostMenuButtonTap(sender: UIButton) {
    isGridMode = true
    gridPostMenuButton.isSelected = isGridMode
    listPostMenuButton.isSelected = !isGridMode

    delegate?.gridPostMenuButtonTap(sender: sender)
  }

  func listPostMenuButtonTap(sender: UIButton) {
    isGridMode = false
    gridPostMenuButton.isSelected = isGridMode
    listPostMenuButton.isSelected = !isGridMode

    delegate?.listPostMenuButtonTap(sender: sender)
  }

  func photosForYouMenuButtonTap(sender: UIButton) {
    delegate?.photosForYouMenuButtonTap(sender: sender)
  }

  func savedMenuButtonTap(sender: UIButton) {
    delegate?.savedMenuButtonTap(sender: sender)
  }
}
