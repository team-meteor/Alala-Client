//
//  CommentViewController.swift
//  Alala
//
//  Created by hoemoon on 21/07/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import SnapKit

class CommentViewController: UIViewController {
  let comments: [Comment]!
  var commentInputBottomConstraint: Constraint!

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

  let topBorder: UIView = {
    let view = UIView()
    view.layer.borderColor = UIColor(red:0.86, green:0.86, blue:0.86, alpha:1.00).cgColor
    view.layer.borderWidth = 1
    return view
  }()

  let sendButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "send-gray"), for: .normal)
    return button
  }()

  let textInputView: UITextView = {
    let view = UITextView()
    view.text = "Add a comment..."
    view.textColor = UIColor(red:0.86, green:0.86, blue:0.86, alpha:1.00)
    view.textContainerInset = UIEdgeInsets.zero
    view.textContainer.lineFragmentPadding = 0
    view.font = UIFont.systemFont(ofSize: 15)
    return view
  }()

  let postButton: UIButton = {
    let button = UIButton()
    button.contentEdgeInsets = UIEdgeInsets.zero
    button.setTitle("Post", for: .normal)
    button.setTitleColor(UIColor(red:0.71, green:0.86, blue:0.99, alpha:1.00), for: .normal)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
    return button
  }()

  init(comments: [Comment]) {
    self.comments = comments
    super.init(nibName: nil, bundle: nil)
    self.view.addSubview(tableView)
    self.view.addSubview(commentInputView)
    self.commentInputView.addSubview(topBorder)
    self.commentInputView.addSubview(sendButton)
    self.commentInputView.addSubview(textInputView)
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
    self.textInputView.delegate = self
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    self.view.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    )

//    self.textInputView.becomeFirstResponder()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.snp.makeConstraints { (make) in
      make.left.right.top.equalTo(self.view)
      make.height.equalTo(max(50 + 64, self.tableViewHeight(comments: self.comments)))
    }
    commentInputView.snp.makeConstraints { (make) in
      make.width.equalTo(self.view)
      make.height.equalTo(51.5)
      make.centerX.equalTo(self.view)
      commentInputBottomConstraint = make.bottom.equalTo(self.view).offset(0).constraint
    }
    topBorder.snp.makeConstraints { (make) in
      make.width.equalTo(self.commentInputView)
      make.height.equalTo(1)
      make.top.equalTo(self.commentInputView)
      make.centerX.equalTo(self.commentInputView)
    }
    sendButton.snp.makeConstraints { (make) in
      make.width.height.equalTo(30)
      make.centerY.equalTo(self.commentInputView)
      make.left.equalTo(self.commentInputView).offset(10)
    }
    postButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.commentInputView)
      make.right.equalTo(self.commentInputView).offset(-10)
    }
    let inputViewHeight = TextSize.size(textInputView.text, font: UIFont.systemFont(ofSize: 17), width: commentInputView.frame.width - sendButton.frame.width - postButton.frame.height - 20).height

    textInputView.snp.makeConstraints { (make) in
      make.left.equalTo(sendButton.snp.right).offset(10)
      make.right.equalTo(postButton.snp.left)
      make.centerY.equalTo(commentInputView)
      make.height.equalTo(inputViewHeight)
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

  func keyboardWillShow(_ notification: Notification) {
    if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
      let keyboardRectangle = keyboardFrame.cgRectValue
//      commentInputBottomConstraint.deactivate()
      commentInputBottomConstraint.update(offset: -keyboardRectangle.height)
    }
  }

  func dismissKeyboard(recognizer: UITapGestureRecognizer) {
    print(recognizer)
//    view.endEditing(true)
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

extension CommentViewController: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    textView.text = nil
    textView.textColor = UIColor.black
  }

  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = "Placeholder"
      textView.textColor = UIColor.lightGray
    }
  }
}
