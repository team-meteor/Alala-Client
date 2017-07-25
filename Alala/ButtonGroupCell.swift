//
//  ButtonGroupCell.swift
//  Alala
//
//  Created by hoemoon on 29/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

protocol InteractiveButtonGroupCellDelegate: class {
  func commentButtondidTap(_ post: Post)
}

extension InteractiveButtonGroupCellDelegate {
  func commentButtondidTap(_ post: Post) {}
}

class ButtonGroupCell: UICollectionViewCell {
  weak var delegate: InteractiveButtonGroupCellDelegate?
  var post: Post!
  var postID = String()
  let likeButton: UIButton = {
    let button = UIButton()
    let unlikeImage = UIImage(named: "heart")?.resizeImage(scaledToFit: 30)
    let likeImage = UIImage(named: "heart-selected")?.resizeImage(scaledToFit: 30)
    button.setBackgroundImage(unlikeImage, for: .normal)
    button.setBackgroundImage(likeImage, for: .selected)
    return button
  }()
  let commentButton: UIButton = {
    let button = UIButton()
    let image = UIImage(named: "comment")?.resizeImage(scaledToFit: 25)
    button.setImage(image, for: .normal)
    return button
  }()
  let sendButton: UIButton = {
    let button = UIButton()
    let image = UIImage(named: "send")?.resizeImage(scaledToFit: 25)
    button.setImage(image, for: .normal)
    return button
  }()
  let saveButton: UIButton = {
    let button = UIButton()
    let image = UIImage(named: "save")?.resizeImage(scaledToFit: 25)
    button.setImage(image, for: .normal)
    return button
  }()
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(likeButton)
    contentView.addSubview(commentButton)
    contentView.addSubview(sendButton)
    contentView.addSubview(saveButton)
    self.likeButton.addTarget(self, action: #selector(likeButtonDidTap), for: .touchUpInside)
    self.commentButton.addTarget(self, action: #selector(commentButtonDidTap), for: .touchUpInside)
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    likeButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.contentView)
      make.left.equalTo(self.contentView).offset(10)
    }
    commentButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.likeButton)
      make.left.equalTo(self.likeButton.snp.right).offset(15)
    }
    sendButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.commentButton)
      make.left.equalTo(self.commentButton.snp.right).offset(15)
    }
    saveButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.sendButton)
      make.right.equalTo(self.contentView).offset(-10)
    }
  }

  func configure(post: Post) {
    self.likeButton.isSelected = post.isLiked
    self.postID = post.id
    self.post = post
    self.setNeedsLayout()
  }

  func commentButtonDidTap() {
    self.delegate?.commentButtondidTap(post)
  }

  func likeButtonDidTap() {
    if !self.likeButton.isSelected {
      print("좋아요")
      self.like()
    } else {
      print("좋아요 취소")
      self.unlike()
    }
  }

  func like() {
    print("like", postID)
    NotificationCenter.default.post(
      name: .postDidLike,
      object: self,
      userInfo: ["post": post]
    )
    PostService.like(postID: self.postID) { response in
      switch response.result {
      case .success:
        print("좋아요 성공!")

      case .failure:
        print("좋아요 실패 ㅠㅠ")
        NotificationCenter.default.post(
          name: .postDidUnlike,
          object: self,
          userInfo: ["post": self.post]
        )
      }
    }
  }

  func unlike() {
    print("unlike", postID)
    NotificationCenter.default.post(
      name: .postDidUnlike,
      object: self,
      userInfo: ["post": self.post]
    )
    PostService.unlike(postID: self.postID) { response in
      switch response.result {
      case .success:
        print("좋아요 취소 성공!")
      case .failure:
        print("좋아요 취소 실패 ㅠㅠ")
        NotificationCenter.default.post(
          name: .postDidLike,
          object: self,
          userInfo: ["post": self.post]
        )
      }
    }
  }
}
