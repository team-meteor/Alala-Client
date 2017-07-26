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

class FeedViewController: UIViewController {

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

  fileprivate var posts: [Post] = []
  fileprivate var nextPage: String?
  fileprivate var isLoading: Bool = false

  fileprivate let refreshControl = UIRefreshControl()

  let collectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    view.backgroundColor = UIColor.white
    return view
  }()

  lazy var adapter: ListAdapter = {
    return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
  }()

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
    NotificationCenter.default.addObserver(self, selector: #selector(preparePosting), name: .preparePosting, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(postDidCreate), name: .postDidCreate, object: nil)
    self.refreshControl.addTarget(self, action: #selector(self.refreshControlDidChangeValue), for: .valueChanged)
    self.collectionView.addSubview(self.refreshControl)
    self.navigationItem.titleView = UILabel().then {
      $0.font = UIFont(name: "IowanOldStyle-BoldItalic", size: 20)
      $0.text = "Alala"
      $0.sizeToFit()
    }
    adapter.scrollViewDelegate = self
    adapter.collectionView = collectionView
    adapter.dataSource = self
    view.addSubview(collectionView)
    self.adapter.reloadData(completion: nil)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.collectionView.frame = view.bounds
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
      print("prepare", idArr)
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

extension FeedViewController: ListAdapterDataSource {
  func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
    let items: [ListDiffable] = self.posts
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

extension FeedViewController: InteractiveButtonGroupCellDelegate {
  func commentButtondidTap(_ post: Post) {
    guard let comments = post.comments else { return }
    self.navigationController?.pushViewController(CommentViewController(comments: comments), animated: true)
  }
  func likeButtonDidTap(_ post: Post) {
    let post = post
    PostService.like(post: post) { response in
      switch response.result {
      case .success(let resultPost):
        post.likeCount = resultPost.likeCount
        post.isLiked = resultPost.isLiked
        self.adapter.performUpdates(animated: false, completion: { _ in
          self.adapter.reloadObjects([post])
        })
      case .failure:
        print("failure")
      }
    }
  }
}

extension FeedViewController: VideoPlayButtonDelegate {
  func playButtonDidTap(sender: UIButton, player: AVPlayer) {
    print("feed tap")
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
