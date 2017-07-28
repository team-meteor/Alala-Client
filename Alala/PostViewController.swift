//
//  PostViewController.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 7. 10..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import IGListKit

protocol PostViewControllerDelegate: class {
  func postUpdateFinished()
}

/**
 * # Post List 화면
 *
 * **[PATH 1]** 내 프로필 화면 > Grid모드에서 아이템 선택 시 이동
 *
 * **[PATH 2]** 내 프로필 화면 > List모드에서 내가 작성한 모든 Post를 List로 노출
 */
class PostViewController: UIViewController {

  weak var delegate: PostViewControllerDelegate?

  lazy var adapter: ListAdapter = {
    return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
  }()

  var posts: [Post] = []
  fileprivate var nextPage: String?
  fileprivate var isLoading: Bool = false

  let collectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    view.backgroundColor = UIColor.white
    return view
  }()

  convenience init() {
    self.init([])
  }

  init(_ posts: [Post]) {
    self.posts = posts

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setupNavigation()

    adapter.collectionView = collectionView
    adapter.dataSource = self
    adapter.collectionViewDelegate = self
    self.view.addSubview(collectionView)
    collectionView.snp.makeConstraints { (make) in
      make.top.equalTo(self.view)
      make.left.equalTo(self.view)
      make.right.equalTo(self.view)
      make.bottom.equalTo(self.view)
    }

    if posts.count > 0 {
      self.adapter.performUpdates(animated: true, completion: nil)
    }
  }

  /**
   * Setup NavigationItem
   */
  func setupNavigation() {
    let rootVC = self.navigationController?.viewControllers.first
    if rootVC?.isKind(of: PersonalViewController.self) == true {
      self.title = "사진"
    } else {
      self.title = "둘러보기"
    }
  }

  func updateNewPost(_ posts: [Post]) {
    self.posts = posts
    self.adapter.performUpdates(animated: true) { (result) in
      if result == true {
        self.delegate?.postUpdateFinished()
      }
    }
  }
}

extension PostViewController: ListAdapterDataSource {
  func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
    let items: [ListDiffable] = self.posts
    print("in objects", items)
    return items
  }
  func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
    if object is Post {
      return PostSectionController()
    } else {
      return ListSectionController()
    }
  }
  func emptyView(for listAdapter: ListAdapter) -> UIView? {
    return nil
  }
}

extension PostViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.row == 0 {
      let selectedPost = self.posts[indexPath.section]
      let profileVC = PersonalViewController(user:selectedPost.createdBy)
      self.navigationController?.pushViewController(profileVC, animated: true)
    }
  }
}
