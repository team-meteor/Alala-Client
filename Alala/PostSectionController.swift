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
    inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    self.displayDelegate = self

  }
  override func numberOfItems() -> Int {
    return 5
  }
  override func sizeForItem(at index: Int) -> CGSize {
    let width = collectionContext!.containerSize.width

    var multimediaCellRatio: Float = 1.0
    if post.multipartIds[0].contains("_") && post.multipartIds.count > 0 {
      multimediaCellRatio = Float(post.multipartIds[0].components(separatedBy: "_")[0])!
    }
    switch index {
    case 0: // usercell
      return CGSize(width: width, height: 56)
    case 1: // multimediaCell
      return CGSize(width: width, height: width * CGFloat(multimediaCellRatio))
    case 2: // buttonGroupcell
      return CGSize(width: width, height: 50)
    case 3: // likeCountCell
      if post.isLiked {
        return CGSize(width: width, height: 20)
      } else {
        return CGSize()
      }
    case 4: // comment cell
      guard let comments = post.comments, comments.count > 0 else {
        return CGSize()
      }
      if let profileName = comments[0].createdBy.profileName {
        let firstCommentHeight = TextSize.size(profileName + comments[0].content, font: UIFont.systemFont(ofSize: 17), width: UIScreen.main.bounds.width, insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)).height
        // TODO : dynamic cell expand
        return CGSize(width: width, height: firstCommentHeight)
      }
      return CGSize()

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
    case 4:
      cellClass = CommentCell.self
    default:
      cellClass = UICollectionViewCell.self
    }

    let cell = collectionContext!.dequeueReusableCell(of: cellClass, for: self, at: index)
    if let cell = cell as? UserCell {
      cell.configure(post: post)
    } else if let cell = cell as? MultimediaCell {
      cell.configure(post: post)
    } else if let cell = cell as? ButtonGroupCell {
      cell.configure(post: post)
      cell.delegate = self.viewController as? InteractiveButtonGroupCellDelegate
    } else if let cell = cell as? LikeCountCell {
      cell.configure(post: post)
    } else if let cell = cell as? CommentCell, let comments = post.comments {
      cell.configure(comments: comments)
    }
    return cell
  }

}

extension PostSectionController: ListDisplayDelegate {
  func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController) {
  }
  func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController) {
  }
  func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
  }
  func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
    if let multiCell = cell as? MultimediaCell {

      print(multiCell)
    }
  }

}
