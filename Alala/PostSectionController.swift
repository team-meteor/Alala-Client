//
//  PostSectionController.swift
//  Alala
//
//  Created by hoemoon on 29/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import IGListKit

class PostSectionController: ListSectionController {
  var post: Post!

  override init() {
    super.init()

    inset = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
  }
  override func sizeForItem(at index: Int) -> CGSize {
    return CGSize(width: collectionContext!.containerSize.width, height: 55)
  }

  override func didUpdate(to object: Any) {
    post = object as? Post
  }

  override func cellForItem(at index: Int) -> UICollectionViewCell {
    let cellClass: AnyClass
    if index == 0 {
      cellClass = UserCell.self
    } else if index == 1 {
      cellClass = MultimediaCell.self
    } else {
      cellClass = ButtonGroupCell.self
    }
    let cell = collectionContext!.dequeueReusableCell(of: cellClass, for: self, at: index)
    if let cell = cell as? UserCell {

//      cell.profilePhoto.setImage(with: post.createdBy.profilePhotoId, size: .thumbnail)
      cell.profilePhoto.setImage(with: "1498753560814.jpg", size: .thumbnail)
      cell.profileNameLabel.text = post.createdBy.profileName
    } else if let cell = cell as? MultimediaCell {
      cell.multimediaImageView.setImage(with: post.multipartIds[0], size: .hd)
    }
    return cell
  }
}
