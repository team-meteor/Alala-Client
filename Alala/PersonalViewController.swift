//
//  PersonalViewController.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//
import UIKit
import Alamofire
import ObjectMapper

/**
 * '내 프로필 & 포스트' 화면
 *
 * **[PATH]** 하단 Main Tap Bar > 가장 우측의 Personal 아이콘 선택
 * - Note : '프로필'View는 PersonalInfoView 클래스에 구현되어있고 이곳에서는 유저의 액션을 받아 delegate만 처리
 */
class PersonalViewController: UIViewController {

  // MARK: - UI Objects
  fileprivate var posts: [Post] = []
  fileprivate var nextPage: String?
  fileprivate var isLoading: Bool = false

  let discoverPeopleButton = UIBarButtonItem(
    image: UIImage(named: "add_user")?.resizeImage(scaledTolength: 25),
    style: .plain,
    target: self,
    action: #selector(PersonalViewController.discoverPeopleButtonTap)
  )

  let archiveButton = UIBarButtonItem(
    image: UIImage(named: "personal")?.resizeImage(scaledTolength: 25),
    style: .plain,
    target: nil,
    action: nil
  )

  let scrollView = UIScrollView().then {
    $0.showsHorizontalScrollIndicator = false
    $0.showsVerticalScrollIndicator = true
    $0.bounces = true
  }

  let personalInfoView = PersonalInfoView()

  let contentsView = UIView()

  let noContentsGuideView = NoContentsView()

  let postGridCollectionView: UICollectionView = {
    let columnLayout = ColumnFlowLayout(
      cellsPerRow: 3,
      minimumInteritemSpacing: 1,
      minimumLineSpacing: 1,
      sectionInset: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    )
    let view = UICollectionView(frame: .zero, collectionViewLayout: columnLayout)
    view.register(PostGridCell.self, forCellWithReuseIdentifier: PostGridCell.cellReuseIdentifier)
    view.showsHorizontalScrollIndicator = false
    view.showsVerticalScrollIndicator = false
    view.backgroundColor = UIColor.white
    return view
  }()

  var postViewController: PostViewController!
  var postListCollectionView: UICollectionView!

  // MARK: - Initialize
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    self.tabBarItem.image = UIImage(named: "personal")?.resizeImage(scaledTolength: 25)
    self.tabBarItem.selectedImage = UIImage(named: "personal-selected")?.resizeImage(scaledTolength: 25)
    self.tabBarItem.imageInsets.top = 5
    self.tabBarItem.imageInsets.bottom = -5

    self.navigationItem.leftBarButtonItem = discoverPeopleButton
    self.navigationItem.rightBarButtonItem = archiveButton
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem.titleView = UILabel().then {
      $0.font = UIFont(name: "HelveticaNeue", size: 20)
      $0.text = AuthService.instance.currentUser?.profileName
      $0.sizeToFit()
    }
    self.navigationController?.navigationBar.topItem?.title = ""

    self.view.addSubview(scrollView)
    scrollView.snp.makeConstraints { (make) in
      make.top.equalTo(self.view)
      make.left.equalTo(self.view)
      make.right.equalTo(self.view)
      make.bottom.equalTo(self.view)
    }

    //-- Section 1 : closable notice view (Optional)
    // (todo)
    //-- Section 2 : personal infomation view (Required)
    scrollView.addSubview(personalInfoView)
    personalInfoView.snp.makeConstraints { (make) in
      make.top.equalTo(scrollView)
      make.left.equalTo(scrollView)
      make.right.equalTo(scrollView)
      //make.bottom.equalTo(personalInfoView.profileNameLabel.snp.bottom).offset(10)
      make.bottom.equalTo(personalInfoView.subMenuBar.snp.bottom)
      make.width.equalTo(scrollView)
    }
    personalInfoView.delegate = self
    personalInfoView.setupUserInfo(userInfo: AuthService.instance.currentUser!)

    //-- Section 3 : personal post list or no contents view (one of both)
    scrollView.addSubview(contentsView)
    contentsView.snp.makeConstraints { (make) in
      make.top.equalTo(personalInfoView.snp.bottom)
      make.left.equalTo(scrollView)
      make.right.equalTo(scrollView)
      make.bottom.equalTo(self.view.snp.bottom)
    }

    self.fetchFeedMine(paging: .refresh)

    NotificationCenter.default.addObserver(self, selector: #selector(postDidCreate), name: .postDidCreate, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(profileUpdated), name: .profileUpdated, object: nil)
  }

  func setupNoContents() {
    if noContentsGuideView.superview == nil {
      contentsView.addSubview(noContentsGuideView)
      noContentsGuideView.snp.makeConstraints { (make) in
        make.top.equalTo(contentsView)
        make.left.equalTo(contentsView)
        make.right.equalTo(contentsView)
        make.bottom.equalTo(contentsView)
      }
      noContentsGuideView.delegate = self
    }
  }

  func setupPostGrid() {
    if postGridCollectionView.superview == nil {
      contentsView.addSubview(postGridCollectionView)
      postGridCollectionView.snp.makeConstraints { (make) in
        make.top.equalTo(contentsView)
        make.left.equalTo(contentsView)
        make.right.equalTo(contentsView)
        make.bottom.equalTo(contentsView)
      }
      postGridCollectionView.dataSource = self
      postGridCollectionView.delegate = self
      postGridCollectionView.isScrollEnabled = false
    }

    postGridCollectionView.isHidden = false
    if postViewController != nil {
      postViewController.view.isHidden = true
    }
  }

  func setupPostList() {
    if postViewController == nil {
      postViewController = PostViewController(posts)
      postListCollectionView = postViewController.collectionView
      self.addChildViewController(postViewController)

      postViewController.delegate = self
      postListCollectionView.isScrollEnabled = false

      contentsView.addSubview(postViewController.view)
      postViewController.view.snp.makeConstraints { (make) in
        make.top.equalTo(contentsView)
        make.left.equalTo(contentsView)
        make.right.equalTo(contentsView)
        make.bottom.equalTo(contentsView).offset(-44)
      }
    }

    postGridCollectionView.isHidden = true
    postViewController.view.isHidden = false
  }

  fileprivate func fetchFeedMine(paging: Paging) {
    guard !self.isLoading else { return }
    self.isLoading = true
    FeedService.feedMine(paging: paging) { [weak self] response in
      guard let `self` = self else { return }
      //self.refreshControl.endRefreshing()
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
        print("fetchFeed : ", self.posts)
        DispatchQueue.main.async {
          self.personalInfoView.postsCountLabel.text = self.posts.count.description
          if self.posts.count == 0 {
            self.setupNoContents()
          } else {
            if self.personalInfoView.isGridMode {
              self.setupPostGrid()
              self.postGridCollectionView.reloadData()
            } else {
              self.setupPostList()
              self.postViewController.updateNewPost(self.posts)
            }
          }
        }
      case .failure(let error):
        print(error)
      }
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.isNavigationBarHidden = false
  }

  func profileUpdated(_ notification: Notification) {
    guard let userInfo = notification.userInfo?["user"] as? User else { return }

    personalInfoView.setupUserInfo(userInfo: userInfo)
  }

  func postDidCreate(_ notification: Notification) {
    guard let post = notification.userInfo?["post"] as? Post else { return }
    self.posts.insert(post, at: 0)

    if noContentsGuideView.superview != nil {
      noContentsGuideView.removeFromSuperview()
    }

    if self.personalInfoView.isGridMode {
      self.postGridCollectionView.reloadData()
    } else {
      postViewController.adapter.performUpdates(animated: true, completion: nil)
    }
  }
}

extension PersonalViewController: PersonalInfoViewDelegate {
  func discoverPeopleButtonTap() {
    let sampleVC = DiscoverPeopleViewController()
    self.navigationController?.pushViewController(sampleVC, animated: true)
  }

  func postsAreaTap() {
    var moveRect = scrollView.frame
    moveRect.origin.y = personalInfoView.frame.size.height - 64

    scrollView.setContentOffset(moveRect.origin, animated: true)
  }

  func followersAreaTap() {
    let followerVC = FollowViewController(type:.follower)
    self.navigationController?.pushViewController(followerVC, animated: true)
  }

  func followingAreaTap() {
    let followingVC = FollowViewController(type:.following)
    self.navigationController?.pushViewController(followingVC, animated: true)
  }

  func editProfileButtonTap(sender: UIButton) {
    let editProfileVC = UINavigationController(rootViewController: EditProfileViewController())
    self.present(editProfileVC, animated: true, completion: nil)
  }

  func optionsButtonTap(sender: UIButton) {
    let optionsVC = OptionsViewController()
    self.navigationController?.pushViewController(optionsVC, animated: true)
  }

  func gridPostMenuButtonTap(sender: UIButton) {
    if self.posts.count <= 0 {
      return
    }
    self.setupPostGrid()
    self.postGridCollectionView.reloadData()
  }

  func listPostMenuButtonTap(sender: UIButton) {
    if self.posts.count <= 0 {
      return
    }
    self.setupPostList()
    self.postViewController.updateNewPost(self.posts)
  }

  func photosForYouMenuButtonTap(sender: UIButton) {
    let photosVC = PhotosForYouViewController()
    self.navigationController?.pushViewController(photosVC, animated: true)
  }

  func savedMenuButtonTap(sender: UIButton) {
    let savedVC = SavedViewController()
    self.navigationController?.pushViewController(savedVC, animated: true)
  }
}

/**
 * PostViewController에서 post그리기가 완료된 후 실행되는 delegate
 * : 이 때 전체 스크롤뷰의 contentSize를 재구성
 */
extension PersonalViewController: PostViewControllerDelegate {
  func postUpdateFinished() {
    var size = postViewController.collectionView.contentSize as CGSize
    size.height += personalInfoView.frame.height
    self.scrollView.contentSize = size
  }
}
/**
 * 내가 작성한 포스트가 없을 경우 노출되는 NoContentsView에서 'Share your first photo or video' 버튼을 선택했을 때 발생하는 delegate
 */
extension PersonalViewController: NoContentsViewDelegate {
  func addContentButtonTap(sender: UIButton) {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let tabBarVC = appDelegate.window?.rootViewController as! MainTabBarController
    tabBarVC.presentWrapperViewController()
  }
}

extension PersonalViewController: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

    //personalInfoView.bounds.size.height
    let size = CGSize(width: scrollView.frame.size.width, height: scrollView.bounds.size.height)
    scrollView.contentSize = size

    return posts.count
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell: PostGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: PostGridCell.cellReuseIdentifier, for: indexPath) as! PostGridCell
    let post = posts[indexPath.row] as Post

    guard post.multipartIds.count > 0 else {
      return cell
    }

    let filename = post.multipartIds[0] as String

    if filename.characters.count > 0 {
      cell.thumbnailImageView.setImage(with: post.multipartIds[0], size: .thumbnail)
    }

    if filename.isVideoPathExtension {
      cell.isVideo = true
    } else {
      cell.isMultiPhotos = post.multipartIds.count > 1 ? true : false
    }
    return cell
  }
}

extension PersonalViewController: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let postArray = [self.posts[indexPath.row]]
    let postVC = PostViewController(postArray)
    self.navigationController?.pushViewController(postVC, animated: true)
  }

  public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if indexPath.row == posts.count - 1 {
      if self.nextPage != nil {
        self.fetchFeedMine(paging: .next(String(describing: self.nextPage)))
      }
    }
  }
}

// MARK: -
class ColumnFlowLayout: UICollectionViewFlowLayout {

  let cellsPerRow: Int
  override var itemSize: CGSize {
    get {
      guard let collectionView = collectionView else { return super.itemSize }
      let marginsAndInsets = sectionInset.left + sectionInset.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
      let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
      return CGSize(width: itemWidth, height: itemWidth)
    }
    set {
      super.itemSize = newValue
    }
  }

  init(cellsPerRow: Int, minimumInteritemSpacing: CGFloat = 0, minimumLineSpacing: CGFloat = 0, sectionInset: UIEdgeInsets = .zero) {
    self.cellsPerRow = cellsPerRow
    super.init()

    self.minimumInteritemSpacing = minimumInteritemSpacing
    self.minimumLineSpacing = minimumLineSpacing
    self.sectionInset = sectionInset
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
    let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
    context.invalidateFlowLayoutDelegateMetrics = newBounds != collectionView?.bounds
    return context
  }
}
