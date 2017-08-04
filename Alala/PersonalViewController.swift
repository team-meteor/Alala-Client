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
import AVFoundation

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

  fileprivate var profileUser: User?

  fileprivate let refreshControl = UIRefreshControl()

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

    if profileUser == nil {
      profileUser = AuthService.instance.currentUser

      self.tabBarItem.image = UIImage(named: "personal")?.resizeImage(scaledTolength: 25)
      self.tabBarItem.selectedImage = UIImage(named: "personal-selected")?.resizeImage(scaledTolength: 25)
      self.tabBarItem.imageInsets.top = 5
      self.tabBarItem.imageInsets.bottom = -5

      self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "add_user")?.resizeImage(scaledTolength: 25),
                                                              style: .plain,
                                                              target: self,
                                                              action: #selector(discoverPeopleButtonTap))

      self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "archive")?.resizeImage(scaledTolength: 25),
                                                              style: .plain,
                                                              target: self,
                                                              action: #selector(archiveButtonTap))
    } else {

    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(user: User) {
    super.init(nibName: nil, bundle: nil)

    profileUser = user
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = UIColor.white
    self.scrollView.backgroundColor = UIColor.white

    self.navigationItem.titleView = UILabel().then {
      $0.font = UIFont(name: "HelveticaNeue", size: 20)
      $0.text = profileUser?.profileName
      $0.sizeToFit()
    }
    self.navigationController?.navigationBar.topItem?.title = ""

    self.refreshControl.addTarget(self, action: #selector(self.refreshControlDidChangeValue), for: .valueChanged)
    self.scrollView.addSubview(self.refreshControl)

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

    //-- Section 3 : personal post list or no contents view (one of both)
    scrollView.addSubview(contentsView)
    contentsView.snp.makeConstraints { (make) in
      make.top.equalTo(personalInfoView.snp.bottom)
      make.left.equalTo(scrollView)
      make.right.equalTo(scrollView)
      make.bottom.equalTo(self.view.snp.bottom)
    }

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
      contentsView.addSubview(postViewController.view)
      postViewController.view.snp.makeConstraints { (make) in
        make.top.equalTo(contentsView)
        make.left.equalTo(contentsView)
        make.right.equalTo(contentsView)
        make.bottom.equalTo(contentsView).offset(-44)
      }

      postViewController.delegate = self
      postListCollectionView.isScrollEnabled = false
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
          self.personalInfoView.postsCount = self.posts.count
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

    if(profileUser?.id == AuthService.instance.currentUser?.id) {
      profileUser = AuthService.instance.currentUser
      self.fetchFeedMine(paging: .refresh)
    } else {
      // todo : 해당 유저의 id로 서버에 user정보를 새로 요청해야 함
      // todo : 해당 유저의 post를 받아오는 api가 필요함
    }

    personalInfoView.setupUserInfo(userInfo: profileUser!)
  }

  func refreshControlDidChangeValue() {
    self.fetchFeedMine(paging: .refresh)
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

  func getThumbnailImage(forUrl url: URL) -> UIImage? {
    let asset: AVAsset = AVAsset(url: url)
    let imageGenerator = AVAssetImageGenerator(asset: asset)

    do {
      let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
      return UIImage(cgImage: thumbnailImage)
    } catch let error {
      print(error)
    }

    return nil
  }

  func discoverPeopleButtonTap() {
    let discoverVC = DiscoverPeopleViewController()
    self.navigationController?.pushViewController(discoverVC, animated: true)
  }

  func archiveButtonTap() {
    let archiveVC = ArchiveViewController()
    self.navigationController?.pushViewController(archiveVC, animated: true)
  }
}

extension PersonalViewController: PersonalInfoViewDelegate {

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

    guard post.multipartIds.count > 0 else { return cell }

    let filename = post.multipartIds[0] as String

    guard filename.characters.count > 0 else { return cell }

    if filename.isVideoPathExtension {
      cell.isVideo = true
      DispatchQueue.global(qos: .default).async {
        let url = URL(string: "https://s3.ap-northeast-2.amazonaws.com/alala-static/\(post.multipartIds[0])")
        if let thumbnailImage = self.getThumbnailImage(forUrl: url!) {
          DispatchQueue.main.async { [weak cell] in
            guard let strongCell = cell else { return }
            strongCell.thumbnailImageView.image = thumbnailImage
            strongCell.thumbnailImageView.layoutIfNeeded()
          }
        }
      }
    } else {
      cell.thumbnailImageView.setImage(with: post.multipartIds[0], size: .medium)
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
