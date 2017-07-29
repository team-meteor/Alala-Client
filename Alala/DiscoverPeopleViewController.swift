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

  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem.titleView = UILabel().then {
      $0.font = UIFont(name: "HelveticaNeue", size: 20)
      $0.text = LS("DiscoverPeople")
      $0.sizeToFit()
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

    contentTableView.register(FollowTableViewCell.self, forCellReuseIdentifier: FollowTableViewCell.cellReuseIdentifier)
    contentTableView.tableFooterView = UIView()
    contentTableView.allowsSelection = false
  }
}

extension DiscoverPeopleViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: FollowTableViewCell = tableView.dequeueReusableCell(withIdentifier: FollowTableViewCell.cellReuseIdentifier) as! FollowTableViewCell

    cell.delegate = self

    cell.userInfo = AuthService.instance.currentUser
    //cell.userIDLabel.text = "아이디"
    //cell.userNameLabel.text = "설명"

    cell.followingButtonWidthConstraint?.update(offset: 0)
    cell.deleteButtonWidthConstraint?.update(offset: 0)

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
      make.bottom.equalTo(view)
      make.rightMargin.equalTo(view)
      make.height.equalTo(18)
    }
    return view
  }
}

extension DiscoverPeopleViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
      cell.separatorInset = FollowTableViewCell.cellSeparatorInsets
    }
  }
}

extension DiscoverPeopleViewController: FollowTableViewCellDelegate {
  func followButtonDidTap(_ userInfo: User) {
    print("followButtonDidTap : \(userInfo)")
  }

  func hideButtonDidTap(_ userInfo: User) {
    print("hideButtonDidTap : \(userInfo)")
  }
}
