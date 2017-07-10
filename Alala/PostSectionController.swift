//
//  PostSectionController.swift
//  Alala
//
//  Created by hoemoon on 29/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import IGListKit
//import ImageIO

class PostSectionController: ListSectionController {
  var post: Post!

  override init() {
    super.init()
    inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
  override func numberOfItems() -> Int {
    return 4
  }
  override func sizeForItem(at index: Int) -> CGSize {
    let width = collectionContext!.containerSize.width

    var multimediaCellRatio = Float(post.multipartIds[0].components(separatedBy: "_")[0])

    if multimediaCellRatio == nil {
      multimediaCellRatio = 1
    }

    switch index {
    case 0: // usercell
      return CGSize(width: width, height: 56)
    case 1: // multimediaCell
      return CGSize(width: width * CGFloat(post.multipartIds.count), height: width * CGFloat(multimediaCellRatio!))
    case 2: // buttonGroupcell
      return CGSize(width: width, height: 50)
    case 3: // likeCountCell
      if post.isLiked {
        return CGSize(width: width, height: 20)
      } else {
        return CGSize()
      }
    default:
      return CGSize()
    }
  }

  override func didUpdate(to object: Any) {

    post = object as? Post
  }

  override func cellForItem(at index: Int) -> UICollectionViewCell {
    let cellClass: AnyClass
    switch index {
    case 0:
      cellClass = UserCell.self
    case 1:
      cellClass = MultimediaCell.self
    case 2:
      cellClass = ButtonGroupCell.self
    case 3:
      cellClass = LikeCountCell.self
    default:
      cellClass = UICollectionViewCell.self
    }
    let cell = collectionContext!.dequeueReusableCell(of: cellClass, for: self, at: index)
    if let cell = cell as? UserCell {
      cell.profilePhoto.setImage(with: post.createdBy.profilePhotoId, size: .thumbnail)
      cell.profileNameLabel.text = post.createdBy.profileName
    } else if let cell = cell as? MultimediaCell {
      cell.multimediaImageView.setImage(with: post.multipartIds[0], size: .hd)
    } else if let cell = cell as? LikeCountCell, post.isLiked == true {
      cell.likeCount.text = String(describing: post.likedUsers!.count)
    }
    return cell
  }
}
