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
import ActiveLabel

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

  fileprivate let refreshControl = UIRefreshControl()
  fileprivate var isLoading: Bool = false

  fileprivate var noPostFeedView: NoPostFeedView?

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
    self.refreshControl.addTarget(self, action: #selector(refreshControlDidChangeValue), for: .valueChanged)
    self.collectionView.addSubview(self.refreshControl)
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
    self.fetchFeed(needRefresh: true)
  }

  fileprivate func fetchFeed(needRefresh: Bool) {
    if needRefresh {
      collection.refreshCollection()
    }
    guard !self.isLoading else { return }
    self.isLoading = true

    collection.loadFromCloud { [weak self] isSuccess in
      guard let strongSelf = self else { return }
      guard isSuccess == true else { return }
      strongSelf.adapter.performUpdates(animated: true) { _ in
        strongSelf.noPostFeedViewIfNeeded()
      }
      strongSelf.refreshControl.endRefreshing()
      strongSelf.isLoading = false
    }
  }

  func noPostFeedViewIfNeeded() {
    if self.collection.isNoPost == true, self.noPostFeedView == nil {
      //print("포스트 없음, 웰컴뷰 없음 --> 웰컴뷰 추가")
      self.noPostFeedView = NoPostFeedView()
      self.noPostFeedView?.noFeedDelegate = self
      self.view.addSubview(self.noPostFeedView!)
      let naviFrame = self.navigationController?.navigationBar.frame
      let topMargin = (naviFrame?.origin.y)! + (naviFrame?.size.height)!
      self.noPostFeedView?.snp.makeConstraints { (make) in
        make.top.equalTo(self.view).offset(topMargin)
        make.left.right.bottom.equalTo(self.view)
      }
      self.noPostFeedView?.contentSize = self.view.frame.size
    } else if self.collection.isNoPost == false, self.noPostFeedView != nil {
      //print("포스트 있음, 웰컴뷰 있음 --> 웰컴뷰 제거")
      self.noPostFeedView?.removeFromSuperview()
      self.noPostFeedView = nil
    }
  }

  func refreshControlDidChangeValue() {
    fetchFeed(needRefresh: true)
  }

  func postDidCreate(_ notification: Notification) {
    guard let post = notification.userInfo?["post"] as? Post else { return }
    self.collection.insertPost(post)
    self.adapter.reloadObjects([post])
    self.adapter.performUpdates(animated: true) { _ in
      self.noPostFeedViewIfNeeded()
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
    if didReachBottom {
      self.fetchFeed(needRefresh: false)
    }
  }
}

extension FeedViewController: ActiveLabelDelegate {
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
    UserService.instance.getUser(id: userID) { response in
      if case .success(let user) = response.result {
        let personalVC = PersonalViewController(user: user)
        self.navigationController?.pushViewController(personalVC, animated: true)
      }
    }
  }
}

extension FeedViewController: NoPostFeedViewDelegate {
  func NoPostFeedViewWelcomeButtonDidTap() {
    let discoverPeopleVC = DiscoverPeopleViewController()
    self.navigationController?.pushViewController(discoverPeopleVC, animated: true)
  }
}
