//
//  CommentViewController.swift
//  Alala
//
//  Created by hoemoon on 21/07/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import SnapKit
import ActiveLabel

class CommentViewController: UIViewController {
  let userDataManager = UserDataManager.shared
  let post: Post!
  var commentInputViewBottomConstraint: Constraint?
  var tableViewBottomConstraint: Constraint?
  let tableView: UITableView = {
    let view = UITableView()
    view.register(CommentTableCell.self, forCellReuseIdentifier: "commentCell")
    view.allowsSelection = false
    return view
  }()

  let commentInputView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.white
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
    view.backgroundColor = UIColor.clear
    view.textContainerInset = UIEdgeInsets.zero
    view.textContainer.lineFragmentPadding = 0
    view.font = UIFont.systemFont(ofSize: 15)
    return view
  }()

  let placeholderLabel: UILabel = {
    let label = UILabel()
    label.text = "Add a comment..."
    label.textColor = UIColor(red:0.86, green:0.86, blue:0.86, alpha:1.00)
    label.font = UIFont.systemFont(ofSize: 15)
    return label
  }()

  let postButton: UIButton = {
    let button = UIButton()
    button.contentEdgeInsets = UIEdgeInsets.zero
    button.setTitle("Post", for: .normal)
    button.setTitleColor(UIColor(red:0.71, green:0.86, blue:0.99, alpha:1.00), for: .normal)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
    button.isEnabled = false
    return button
  }()

  init(post: Post) {
    self.post = post
    super.init(nibName: nil, bundle: nil)
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
    self.tableView.tableFooterView = UIView()
    self.postButton.addTarget(self, action: #selector(postButtonDidTap), for: .touchUpInside)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    self.view.addGestureRecognizer(
      UIPanGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    )
    self.setupSubview()
    self.setupConstraints()
    self.textInputView.becomeFirstResponder()
  }

  func setupSubview() {
    self.view.addSubview(tableView)
    self.view.addSubview(commentInputView)
    self.commentInputView.addSubview(topBorder)
    self.commentInputView.addSubview(sendButton)
    self.commentInputView.addSubview(textInputView)
    self.commentInputView.addSubview(postButton)
    self.commentInputView.addSubview(placeholderLabel)
  }

  func setupConstraints() {
    tableView.snp.makeConstraints { (make) in
      make.left.right.top.equalTo(self.view)
      tableViewBottomConstraint = make.bottom.equalTo(self.view).constraint
    }
    commentInputView.snp.makeConstraints({ (make) in
      make.width.equalTo(self.view)
      make.height.equalTo(51.5)
      make.centerX.equalTo(self.view)
      commentInputViewBottomConstraint = make.bottom.equalTo(self.view).constraint
    })
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
    postButton.sizeToFit()
    postButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.commentInputView)
      make.right.equalTo(self.commentInputView).offset(-10)
      make.left.equalTo(textInputView.snp.right)
      make.width.equalTo(postButton.frame.width)
    }
    let inputViewHeight = TextSize.size(
      textInputView.text,
      font: UIFont.systemFont(ofSize: 17),
      width: commentInputView.frame.width - sendButton.frame.width - postButton.frame.height - 20
      ).height
    textInputView.snp.makeConstraints { (make) in
      make.left.equalTo(sendButton.snp.right).offset(10)
      make.right.equalTo(postButton.snp.left)
      make.centerY.equalTo(commentInputView)
      make.height.equalTo(inputViewHeight)
    }
    placeholderLabel.sizeToFit()
    placeholderLabel.snp.makeConstraints { (make) in
      make.left.equalTo(sendButton.snp.right).offset(10)
      make.right.equalTo(postButton.snp.left)
      make.centerY.equalTo(commentInputView)
    }
  }

  func postButtonDidTap() {
    self.postButton.isEnabled = false
    postButton.setTitleColor(UIColor(red:0.71, green:0.86, blue:0.99, alpha:1.00), for: .normal)
    PostDataManager.createCommentWithCloud(post: self.post, content: self.textInputView.text) { (response) in
      switch response.result {
      case .success(let resultComment):
        self.post.comments?.append(resultComment)
        self.tableView.reloadData()
        self.postButton.isEnabled = true
        self.postButton.setTitleColor(UIColor(red:0.24, green:0.60, blue:0.93, alpha:1.00), for: .normal)
        self.textInputView.text = ""
        self.tableView.scrollToRow(at: IndexPath.init(row: self.post.comments!.count - 1, section: 0), at: UITableViewScrollPosition.top, animated: false)
      case .failure:
        print("failure")
      }
    }
  }

  func keyboardWillShow(_ notification: Notification) {
    if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
      let keyboardRectangle = keyboardFrame.cgRectValue
      self.commentInputViewBottomConstraint?.update(offset: -keyboardRectangle.height)
      self.tableViewBottomConstraint?.update(offset: -keyboardRectangle.height)
      if self.post.comments!.count > 0 {
        let lastRow = self.post.comments!.count - 1
        self.tableView.scrollToRow(at: IndexPath.init(row: lastRow, section: 0), at: UITableViewScrollPosition.top, animated: false)
      }
    }
  }
  func keyboardWillHide(_ notification: Notification) {
    self.commentInputViewBottomConstraint?.update(offset: 0)
    self.tableViewBottomConstraint?.update(offset: 0)
  }

  func dismissKeyboard(_ recognizer: UITapGestureRecognizer) {
    view.endEditing(true)
    // todo : 일정 속도 일상일 때 닫기
    // 손가락이 키보드랑 닿으면 닫기
  }
}

extension CommentViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentTableCell
    cell.delegate = self
    cell.configure(comment: self.post.comments![indexPath.row])
    return cell
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.post.comments!.count
  }
}

extension CommentViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let comment = self.post.comments![indexPath.row]
    let size = TextSize.size(
      comment.createdBy.profileName! + comment.content,
      font: UIFont.systemFont(ofSize: 15),
      width: self.view.frame.width,
      insets: UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 10)
      ).height
    return max(size, 50)
  }
}

extension CommentViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    if textView.text.characters.count > 0 {
      self.placeholderLabel.isHidden = true
      postButton.isEnabled = true
      postButton.setTitleColor(UIColor(red:0.24, green:0.60, blue:0.93, alpha:1.00), for: .normal)
    } else {
      self.placeholderLabel.isHidden = false
      postButton.isEnabled = false
      postButton.setTitleColor(UIColor(red:0.71, green:0.86, blue:0.99, alpha:1.00), for: .normal)
    }
  }
}

extension CommentViewController: ActiveLabelDelegate {
  func didSelect(_ text: String, type: ActiveType) {
    switch type {
    case .mention:
      pushToPersonalViewController(userID: text)
    case .hashtag:
      print(text)
    case .url:
      print(text)
    case .custom(pattern: "^([\\w]+)"):
      pushToPersonalViewController(userID: text)
    default: break
    }
  }
  func pushToPersonalViewController(userID: String) {
    userDataManager.getUserWithCloud(id: userID) { response in
      if case .success(let user) = response.result {
        let personalVC = PersonalViewController(user: user)
        self.navigationController?.pushViewController(personalVC, animated: true)
      }
    }
  }
}
