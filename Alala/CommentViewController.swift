//
//  CommentViewController.swift
//  Alala
//
//  Created by hoemoon on 21/07/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController {
  let comments: [Comment]!
  init(comments: [Comment]) {
    self.comments = comments
    super.init(nibName: nil, bundle: nil)
  }

  let tableView: UITableView = {
    let view = UITableView()
    view.register(CommentTableCell.self, forCellReuseIdentifier: "commentCell")
    return view
  }()

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Comments"
    self.view.backgroundColor = UIColor.white
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.allowsSelection = false
    self.view.addSubview(tableView)
    self.tabBarController?.tabBar.isHidden = true
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.snp.makeConstraints { (make) in
      make.edges.equalTo(self.view)
    }
  }
}

extension CommentViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentTableCell
    cell.configure(comment: self.comments[indexPath.row])
    return cell
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return comments.count
  }
}

extension CommentViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let comment = comments[indexPath.row]
    return TextSize.size(
      comment.createdBy.profileName! + comment.content,
      font: UIFont.systemFont(ofSize: 15),
      width: self.view.frame.width,
      insets: UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 10)
      ).height + 10
  }
}
