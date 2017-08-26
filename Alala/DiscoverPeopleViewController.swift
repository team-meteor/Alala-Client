//
//  DiscoverPeopleViewController.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 6. 27..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class DiscoverPeopleViewController: UIViewController {
  let userDataManager = UserDataManager.shared
  var contentTableView = UITableView()
  var allUsers = [User]()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.titleView = UILabel().then {
      $0.font = UIFont(name: "HelveticaNeue", size: 20)
      $0.text = LS("discover_people")
      $0.sizeToFit()
    }
    userDataManager.getMeWithCloud { _ in}
    userDataManager.getAllUsersWithCloud { users in
      self.allUsers = (users.filter({$0.email != self.userDataManager.currentUser?.email}))
      self.contentTableView.reloadData()
    }
    setupUI()
  }

  func setupUI() {
    self.view.addSubview(contentTableView)
    contentTableView.snp.makeConstraints { (make) in
      make.top.left.right.bottom.equalTo(self.view)
    }

    contentTableView.dataSource = self
    contentTableView.delegate = self

    contentTableView.register(PeoplesTableViewCell.self, forCellReuseIdentifier: PeoplesTableViewCell.cellReuseIdentifier)
    contentTableView.tableFooterView = UIView()
  }
}

extension DiscoverPeopleViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.allUsers.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell: PeoplesTableViewCell = tableView.dequeueReusableCell(withIdentifier: PeoplesTableViewCell.cellReuseIdentifier) as! PeoplesTableViewCell

    cell.delegate = self
    cell.selectionStyle = .none

    cell.userInfo = self.allUsers[indexPath.item]

    if userDataManager.isFollowing(with: cell.userInfo.id) {
      cell.isFollowingUser = true
      return cell
    }
    cell.isFollowingUser = false
    return cell
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIBorderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
    view.bottomBorderLine.isHidden = false

    let label = UILabel()
    label.text = LS("discover_people_all_suggesions")
    view.addSubview(label)
    label.font = UIFont.boldSystemFont(ofSize: 12)
    label.textColor = UIColor.lightGray
    view.backgroundColor = UIColor(rgb: 0xeeeeee)
    label.snp.makeConstraints { (make) in
      make.left.equalTo(view).offset(10)
      make.bottom.equalTo(view).offset(-3)
      make.rightMargin.equalTo(view)
      make.height.equalTo(18)
    }
    return view
  }
}

extension DiscoverPeopleViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return CGFloat(PeoplesTableViewCell.cellHeight)
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
      cell.separatorInset = PeoplesTableViewCell.cellSeparatorInsets
    }
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let rowUser = self.allUsers[indexPath.row]
    let profileVC = PersonalViewController(user:rowUser)
    self.navigationController?.pushViewController(profileVC, animated: true)
  }
}

extension DiscoverPeopleViewController: PeoplesTableViewCellDelegate {
  func followButtonDidTap(_ userInfo: User, _ sender: UIButton) {
    requestChangeFollowStatus(userInfo, sender)
  }

  func followingButtonDidTap(_ userInfo: User, _ sender: UIButton) {

    let alertController = UIAlertController(title: "\n\n\n\n", message: "", preferredStyle: .actionSheet)
    let contentView = UIView(frame: CGRect(x: 8.0, y: 8.0, width: alertController.view.bounds.size.width - 8.0 * 4.5, height: 120.0))
    alertController.view.addSubview(contentView)

    let photoImageView = CircleImageView()
    let guideLabel = UILabel().then {
      $0.textAlignment = .center
    }
    contentView.addSubview(photoImageView)
    contentView.addSubview(guideLabel)
    photoImageView.snp.makeConstraints { (make) in
      make.centerX.equalTo(contentView)
      make.top.equalTo(10)
      make.width.height.equalTo(50)
    }
    guideLabel.snp.makeConstraints { (make) in
      make.left.right.bottom.equalTo(contentView)
      make.top.equalTo(photoImageView.snp.bottom)
    }

    photoImageView.setImage(with: userInfo.profilePhotoId, placeholder: UIImage(named: "default_user"), size: .medium)
    guideLabel.text = String(format: LS("actionsheet_unfollow_check"), userInfo.profileName!)

    let cancelAction = UIAlertAction(title: LS("cancel"), style: .cancel)
    alertController.addAction(cancelAction)

    let unfollowAction = UIAlertAction(title: LS("actionsheet_unfollow"), style: .destructive) { _ in
      self.requestChangeFollowStatus(userInfo, sender)
    }
    alertController.addAction(unfollowAction)

    self.present(alertController, animated: true, completion: nil)
  }

  func hideButtonDidTap(_ userInfo: User, _ sender: UIButton) {
    if let cell = sender.superview as? PeoplesTableViewCell {
      let indexPath = contentTableView.indexPath(for: cell)
      let newUsers = self.allUsers.filter({$0.email != self.allUsers[(indexPath?.row)!].email})
      self.allUsers = newUsers
      contentTableView.reloadData()
    }
  }

  func requestChangeFollowStatus(_ userInfo: User, _ sender: UIButton) {
    userDataManager.followWithCloud(id: userInfo.id) { response in
      switch response.result {
      case .success:
        if let cell = sender.superview as? PeoplesTableViewCell {
          cell.isFollowingUser = !cell.isFollowingUser
        }
      case .failure:
        print("failure")
      }
    }
  }
}
