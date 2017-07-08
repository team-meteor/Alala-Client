//
//  FollowViewController.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 6. 27..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

/**
 * # 팔로워/팔로잉 목록 화면
 *
 * **[PATH]** 프로필 화면 > 팔로워/팔로잉 텍스트 터치 시 진입
 *
 * * 팔로워/팔로잉 두 화면의 UI가 동일하므로 FollowViewController에서 공통으로 지원하되
 * ViewController생성시 'FollowType'을 지정하여 구분하도록 한다.
 *
 */
class FollowViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

  enum FollowType: String {
    case follower  = "follower"
    case following = "following"
  }

  var currentType: String

  var dataArray = [String]()

  var filteredArray = [String]()

  var shouldShowSearchResults = false

  var searchController: UISearchController!
  var searchBar = UISearchBar()
  var contentTableView = UITableView()

  // MARK: - Initialize
  convenience init() {
    self.init(type:.follower)
  }

  init(type: FollowType) {
    currentType = type.rawValue

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.edgesForExtendedLayout = []

    if(FollowType.follower.rawValue==currentType) {
      setupUIForFollowerType()
    } else {
      setupUIForFollowingType()
    }

    setupUI()
   //configureSearchController()
  }

  func setupUIForFollowerType() {
    self.navigationItem.titleView = UILabel().then {
      $0.font = UIFont(name: "HelveticaNeue", size: 20)
      $0.text = "Followers"
      $0.sizeToFit()
    }
  }

  func setupUIForFollowingType() {
    self.navigationItem.titleView = UILabel().then {
      $0.font = UIFont(name: "HelveticaNeue", size: 20)
      $0.text = "Following"
      $0.sizeToFit()
    }
  }

  func setupUI() {

    self.view.addSubview(searchBar)
    searchBar.delegate = self
    searchBar.snp.makeConstraints { (make) in
      make.top.equalTo(self.view)
      make.left.equalTo(self.view)
      make.right.equalTo(self.view)
      make.height.equalTo(44)
    }
    searchBar.searchBarStyle = .minimal
    searchBar.placeholder = "검색"
    //searchBar.showsSearchResultsButton = false

    self.view.addSubview(contentTableView)
    contentTableView.snp.makeConstraints { (make) in
      make.top.equalTo(searchBar.snp.bottom)
      make.left.equalTo(self.view)
      make.right.equalTo(self.view)
      make.bottom.equalTo(self.view)
    }

    contentTableView.dataSource = self
    contentTableView.delegate = self
    contentTableView.register(FollowTableViewCell.self, forCellReuseIdentifier: FollowTableViewCell.cellReuseIdentifier)
    contentTableView.register(EditProfileTableViewCell.self, forCellReuseIdentifier: EditProfileTableViewCell.cellReuseIdentifier)
    contentTableView.tableFooterView = UIView()
  }

  // MARK: Tableview DataSource
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if(section == 0) {
      return 1
    } else {
      //    if shouldShowSearchResults {
      //      return filteredArray.count
      //    } else {
      //      return dataArray.count
      //    }
      return 3
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    if(indexPath.section == 0) {
      let cell: EditProfileTableViewCell = tableView.dequeueReusableCell(withIdentifier: EditProfileTableViewCell.cellReuseIdentifier) as! EditProfileTableViewCell
      cell.textView.text = "Facebook친구"
      cell.textView.isEditable = false
      cell.rightButton.setImage(UIImage(named: "foward")?.resizeImage(scaledTolength: 15), for: .normal)
      cell.rightButtonWidthConstraint?.constant = 20
      return cell
    } else {
      let cell: FollowTableViewCell = tableView.dequeueReusableCell(withIdentifier: FollowTableViewCell.cellReuseIdentifier) as! FollowTableViewCell
      //let cell = tableView.dequeueReusableCell(withIdentifier: "idCell", for: indexPath as IndexPath)

      //    if shouldShowSearchResults {
      //      cell.textLabel?.text = filteredArray[indexPath.row]
      //    } else {
      //      cell.textLabel?.text = dataArray[indexPath.row]
      //    }

      return cell
    }
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIBorderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
    view.topBorderLine.isHidden = false
    view.bottomBorderLine.isHidden = false

    let label = UILabel()
    view.addSubview(label)
    label.font = UIFont.systemFont(ofSize: 10)
    view.backgroundColor = UIColor(rgb: 0xeeeeee)
    label.snp.makeConstraints { (make) in
      make.leftMargin.equalTo(view).offset(10)
      make.bottomMargin.equalTo(view)
      make.rightMargin.equalTo(view)
      make.height.equalTo(18)
    }

    if(section == 0) {
      label.text = "초대"
    } else {
      label.text = "팔로잉"
    }

    return view
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
      cell.separatorInset = FollowTableViewCell.cellSeparatorInsets
    }
  }
}

class FollowTableViewCell: UITableViewCell {
  static let cellReuseIdentifier = "followCell"
  static let cellSeparatorInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)

  var deleteButtonWidthConstraint: NSLayoutConstraint?

  let userPhotoImageView = CircleImageView().then {
    $0.layer.borderWidth = 1
    $0.layer.masksToBounds = false
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.clipsToBounds = true
    $0.isUserInteractionEnabled = true
  }

  let userIDLabel = UILabel().then {
    $0.font = UIFont(name: "HelveticaNeue", size: 10)
    $0.text = "아이디"
    $0.sizeToFit()
  }

  let userNameLabel = UILabel().then {
    $0.font = UIFont(name: "HelveticaNeue", size: 10)
    $0.text = "이름"
    $0.sizeToFit()
  }

  let followingButton = RoundCornerButton(type: .buttonColorTypeWhite).then {
    $0.setTitle("팔로잉", for: .normal)
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
    //$0.addTarget(self, action: #selector(editProfileButtonTap(sender:)), for: .touchUpInside)
  }

  let deleteButton = UIButton().then {
    $0.setImage(UIImage(named: "more")?.resizeImage(scaledTolength: 10), for: .normal)
    //$0.addTarget(self, action: #selector(editProfileButtonTap(sender:)), for: .touchUpInside)
  }

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.addSubview(userPhotoImageView)
    self.addSubview(userIDLabel)
    self.addSubview(userNameLabel)
    self.addSubview(followingButton)
    self.addSubview(deleteButton)

    userPhotoImageView.snp.makeConstraints { (make) in
      make.centerY.equalTo(self)
      make.left.equalTo(self).offset(10)
      make.width.equalTo(30)
      make.height.equalTo(30)
    }

    userIDLabel.snp.makeConstraints { (make) in
      make.top.equalTo(self).offset(5)
      make.left.equalTo(userPhotoImageView.snp.right).offset(5)
      make.right.equalTo(followingButton.snp.left)
      make.bottom.equalTo(userNameLabel.snp.top)
    }

    userNameLabel.snp.makeConstraints { (make) in
      make.top.equalTo(userIDLabel.snp.bottom)
      make.left.equalTo(userIDLabel)
      make.right.equalTo(userIDLabel)
      make.bottom.equalTo(self).offset(-5)
    }

    followingButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self)
      make.right.equalTo(deleteButton.snp.left).offset(-5)
      make.width.equalTo(80)
      make.height.equalTo(20)
    }

    deleteButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self)
      make.right.equalTo(self).offset(-5)
      make.width.equalTo(20)
      make.height.equalTo(20)
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}