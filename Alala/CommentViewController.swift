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
  let post: Post!
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
    self.view.addSubview(tableView)
    self.view.addSubview(commentInputView)
    self.commentInputView.addSubview(topBorder)
    self.commentInputView.addSubview(sendButton)
    self.commentInputView.addSubview(textInputView)
    self.commentInputView.addSubview(postButton)
    self.commentInputView.addSubview(placeholderLabel)

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
      UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    )

    self.textInputView.becomeFirstResponder()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.snp.makeConstraints { (make) in
      make.left.right.top.bottom.equalTo(self.view)
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
    PostService.createComment(post: self.post, content: self.textInputView.text) { (response) in
      switch response.result {
      case .success(let resultComment):
        self.post.comments?.append(resultComment)
        self.tableView.reloadData()
        self.postButton.isEnabled = true
        self.postButton.setTitleColor(UIColor(red:0.24, green:0.60, blue:0.93, alpha:1.00), for: .normal)
        self.textInputView.text = ""
      case .failure:
        print("failure")
      }
    }
  }

  func keyboardWillShow(_ notification: Notification) {
    if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
      let keyboardRectangle = keyboardFrame.cgRectValue
      UIView.animate(withDuration: 10, animations: {
        self.commentInputView.snp.remakeConstraints({ (make) in
          make.width.equalTo(self.view)
          make.height.equalTo(51.5)
          make.centerX.equalTo(self.view)
          make.bottom.equalTo(self.view).offset(-keyboardRectangle.height)
        })
      })
    }
  }
  func keyboardWillHide(_ notification: Notification) {
    UIView.animate(withDuration: 10, animations: {
      self.commentInputView.snp.remakeConstraints({ (make) in
        make.width.equalTo(self.view)
        make.height.equalTo(51.5)
        make.centerX.equalTo(self.view)
        make.bottom.equalTo(self.view)
      })
    })
  }

  func dismissKeyboard(recognizer: UITapGestureRecognizer) {
    view.endEditing(true)
  }
}

extension CommentViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentTableCell
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
      insets: UIEdgeInsets(top: 0, left: 45, bottom: 10, right: 10)
      ).height + 10
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
