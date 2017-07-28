//
//  FeedViewController.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import IGListKit
import Alamofire
import AVFoundation

class FeedViewController: PostViewController {

  fileprivate let cameraButton = UIBarButtonItem(
    image: UIImage(named: "camera")?.resizeImage(scaledTolength: 25),
    style: .plain,
    target: nil,
    action: nil
  )

  fileprivate let messageButton = UIBarButtonItem(
    image: UIImage(named: "send")?.resizeImage(scaledTolength: 25),
    style: .plain,
    target: nil,
    action: nil
  )

  fileprivate var nextPage: String?
  fileprivate var isLoading: Bool = false

  fileprivate let refreshControl = UIRefreshControl()

  override init(_ posts: [Post] = []) {
    super.init(posts)

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
    NotificationCenter.default.addObserver(self, selector: #selector(preparePosting), name: .preparePosting, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(postDidCreate), name: .postDidCreate, object: nil)
    self.refreshControl.addTarget(self, action: #selector(self.refreshControlDidChangeValue), for: .valueChanged)
    self.collectionView.addSubview(self.refreshControl)
    self.fetchFeed(paging: .refresh)
//    self.adapter.reloadData(completion: nil)
  }

  override func setupNavigation() {
    self.navigationItem.titleView = UILabel().then {
      $0.font = UIFont(name: "IowanOldStyle-BoldItalic", size: 20)
      $0.text = "Alala"
      $0.sizeToFit()
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.isNavigationBarHidden = false
    self.tabBarController?.tabBar.isHidden = false
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
          self.adapter.performUpdates(animated: true, completion: nil)
      case .failure(let error):
        print(error)
  }
      }
    }

  func refreshControlDidChangeValue() {
    self.fetchFeed(paging: .refresh)
  }

  func postDidCreate(_ notification: Notification) {
    guard let post = notification.userInfo?["post"] as? Post else { return }
    self.posts.insert(post, at: 0)
    self.adapter.reloadObjects([post])
    self.adapter.performUpdates(animated: true) { _ in
      self.adapter.reloadObjects([post])
    }
  }

  func preparePosting(_ notification: Notification) {
    self.moveToFeedViewController()
    guard let postDic = notification.userInfo?["postDic"] as? [String:Any],
      let multipartArr = postDic["multipartArr"] as? [Any],
      let message = postDic["message"] as? String? else { return }
    self.getMultipartsIdArr(multipartArray: multipartArr) { idArr in
      PostService.postWithMultipart(idArr: idArr, message: message, progress: nil, completion: { [weak self] response in
        guard self != nil else { return }
        switch response.result {
        case .success(let post):
          NotificationCenter.default.post(
            name: .postDidCreate,
            object: self,
            userInfo: ["post": post]
          )
        case .failure(let error):
          print(error)
        }}
      )}
  }

  func getMultipartsIdArr(multipartArray: [Any], completion: @escaping (_ idArr: [String]) -> Void) {
    let progressView: UIProgressView = {
      let view = UIProgressView()
      view.backgroundColor = UIColor.yellow
      view.progress = 0.0
      view.isHidden = false
      view.frame = CGRect(
        x: 0,
        y: (self.navigationController?.navigationBar.frame.height)! + 50,
        width: self.view.bounds.width,
        height: 50
      )
      return view
    }()
    self.collectionView.addSubview(progressView)

    let progressCompletion: (Float) -> Void = { percent in
      progressView.setProgress(percent, animated: true)
    }
    let uploadCompletion: ([String]) -> Void = { multipartIdArray in
      progressView.isHidden = true
      progressView.removeFromSuperview()
      completion(multipartIdArray)
    }

    MultipartService.uploadMultipart(
      multiPartDataArray: multipartArray,
      progressCompletion: progressCompletion,
      uploadCompletion: uploadCompletion
    )
  }

  /**
   * TabBarViewController중 피드 화면으로 이동
   *
   * - Note : 포스트를 업로드할 때는 무조건 피드VC로 이동되어야 함
   */
  func moveToFeedViewController() {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let tabBarVC = appDelegate.window?.rootViewController as! MainTabBarController
    if tabBarVC.selectedViewController != self {
      tabBarVC.selectedIndex = 0
    }
  }
}

extension FeedViewController: VideoPlayButtonDelegate {
  func playButtonDidTap(sender: UIButton, player: AVPlayer) {
    if player.rate == 0 {
      player.play()
      sender.setImage(nil, for: .normal)
    } else {
      player.pause()
      sender.setImage(UIImage(named: "pause"), for: .normal)
    }
  }
}

extension FeedViewController: UICollectionViewDelegateFlowLayout {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let contentOffsetBottom = scrollView.contentOffset.y + scrollView.frame.height
    let didReachBottom = scrollView.contentSize.height > 0
      && contentOffsetBottom >= scrollView.contentSize.height - 300
    if let nextPage = self.nextPage, didReachBottom {
      self.fetchFeed(paging: .next(nextPage))
    }
  }
}
