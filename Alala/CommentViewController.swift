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

  let tableView: UITableView = {
    let view = UITableView()
    view.register(CommentTableCell.self, forCellReuseIdentifier: "commentCell")
    view.allowsSelection = false

    return view
  }()

  let commentInputView: UIView = {
    let view = UIView()
    return view
  }()

  let sendButton: UIButton = {
    let button = UIButton()
    return button
  }()

  let textView: UITextView = {
    let view = UITextView()
    return view
  }()

  let postButton: UIButton = {
    let button = UIButton()
    button.setTitle("Post", for: .normal)
    return button
  }()

  init(comments: [Comment]) {
    self.comments = comments
    super.init(nibName: nil, bundle: nil)
    self.view.addSubview(tableView)
    self.view.addSubview(commentInputView)
    self.commentInputView.addSubview(sendButton)
    self.commentInputView.addSubview(textView)
    self.commentInputView.addSubview(postButton)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Comments"
    self.view.backgroundColor = UIColor.white
    self.tableView.delegate = self
    self.tableView.dataSource = self
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.snp.makeConstraints { (make) in
      make.left.right.top.equalTo(self.view)
      make.height.equalTo(max(50 + 64, self.tableViewHeight(comments: self.comments)))
    }
  }
  func tableViewHeight(comments: [Comment]) -> CGFloat {
    var height = CGFloat()
    for comment in comments {
      height += TextSize.size(
        comment.createdBy.profileName! + comment.content,
        font: UIFont.systemFont(ofSize: 15),
        width: self.view.frame.width,
        insets: UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 10)
        ).height + 10
    }
    return height + 64
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
    let size = TextSize.size(
      comment.createdBy.profileName! + comment.content,
      font: UIFont.systemFont(ofSize: 15),
      width: self.view.frame.width,
      insets: UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 10)
      ).height + 10
    return max(size, 50)
  }
}
