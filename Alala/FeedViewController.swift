//
//  FeedViewController.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import Alamofire

class FeedViewController: UIViewController {

  fileprivate let cameraButton = UIBarButtonItem(
    image: UIImage(named: "camera")?.resizeImage(scaledTolength: 25),
    style: .plain,
    target: nil,
    action: nil
  )

  fileprivate let messageButton = UIBarButtonItem(
    image: UIImage(named: "message")?.resizeImage(scaledTolength: 25),
    style: .plain,
    target: nil,
    action: nil
  )

  fileprivate var posts: [Post] = []
  fileprivate var nextPage: Int?
  fileprivate var isLoading: Bool = false

  fileprivate let refreshControl = UIRefreshControl()

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    self.tabBarItem.image = UIImage(named: "feed")?.resizeImage(scaledTolength: 25)
    self.tabBarItem.selectedImage = UIImage(named: "feed-selected")?.resizeImage(scaledTolength: 25)
    self.tabBarItem.imageInsets.top = 5
    self.tabBarItem.imageInsets.bottom = -5
    self.navigationItem.leftBarButtonItem = cameraButton
    self.navigationItem.rightBarButtonItem = messageButton
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.titleView = UILabel().then {
      $0.font = UIFont(name: "IowanOldStyle-BoldItalic", size: 20)
      $0.text = "Alala"
      $0.sizeToFit()
    }
    self.fetchFeed(paging: .refresh)
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.isNavigationBarHidden = false
  }

  fileprivate func fetchFeed(paging: Paging) {
    guard !self.isLoading else { return }
    self.isLoading = true
    FeedService.feed(paging: paging) { [weak self] response in
      guard let `self` = self else { return }
      self.refreshControl.endRefreshing()
      self.isLoading = false

      switch response.result {
      case .success(let feed):
        let newPosts = feed.posts ?? []
        switch paging {
        case .refresh:
          self.posts = newPosts
        case .next:
          self.posts.append(contentsOf: newPosts)
        }
        self.nextPage = feed.nextPage
        print(self.posts)
//        self.collectionView.reloadData()
      case .failure(let error):
        print(error)
      }

    }
  }

}
