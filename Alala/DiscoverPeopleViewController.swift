//
//  DiscoverPeopleViewController.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 6. 27..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class DiscoverPeopleViewController: UIViewController {

  var contentTableView = UITableView()
  var allUsers = [User]()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.titleView = UILabel().then {
      $0.font = UIFont(name: "HelveticaNeue", size: 20)
      $0.text = LS("DiscoverPeople")
      $0.sizeToFit()
    }
    AuthService.instance.me { _ in}
    UserService.instance.getAllRegisterdUsers { users in
      self.allUsers = (users?.filter({$0?.email != AuthService.instance.currentUser?.email}))! as! [User]
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

    if let followingUsers = AuthService.instance.currentUser?.following {
      if followingUsers.contains(where: { $0.email == cell.userInfo.email }) {
        cell.isFollowingUser = true
        return cell
      }
    }
    cell.isFollowingUser = false
    return cell
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIBorderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
    view.bottomBorderLine.isHidden = false

    let label = UILabel()
    label.text = LS("discover_all_suggesions")
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
    UserService.instance.followUser(id: userInfo.id) { bool in
      if bool {
        if let cell = sender.superview as? PeoplesTableViewCell {
          cell.isFollowingUser = true
        }
      }
    }
  }

  func followingButtonDidTap(_ userInfo: User, _ sender: UIButton) {
    UserService.instance.unfollowUser(id: userInfo.id) { bool in
      if bool {
        if let cell = sender.superview as? PeoplesTableViewCell {
          cell.isFollowingUser = false
        }
      }
    }
  }

  func hideButtonDidTap(_ userInfo: User, _ sender: UIButton) {
    if let cell = sender.superview as? PeoplesTableViewCell {
      let indexPath = contentTableView.indexPath(for: cell)
      let newUsers = self.allUsers.filter({$0.email != self.allUsers[(indexPath?.row)!].email})
      self.allUsers = newUsers
      contentTableView.reloadData()
    }
  }
}
