//
//  SavedViewController.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 7. 3..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation

/**
 * # '저장됨' 화면
 *
 * **[PATH]** 내 프로필 화면 > SubMenuBar 네번째 아이콘 탭
 */
class SavedViewController: UIScrollTapMenuViewController {

  var noContentsViewForAll: NoContentsView!
  var noContentsViewForCollection: NoContentsView!
  fileprivate var posts: [Post] = []
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

  override func viewDidLoad() {
    self.edgesForExtendedLayout = []
    self.navigationItem.titleView = UILabel().then {
      $0.font = UIFont(name: "HelveticaNeue", size: 20)
      $0.text = LS("saved")
      $0.sizeToFit()
    }

    // NOTE :
    // 부모VC인 UIScrollTapMenuViewController에서 NavigationItem의 유무에 따라 상단 margin을 조정하기 때문에
    // super.viewDidLoad()보다 navigationItem.titleView가 먼저 선행되어야 함
    super.viewDidLoad()

    self.firstButton.setTitle(LS("all"), for: .normal)
    self.secondButton.setTitle(LS("collection"), for: .normal)

    self.posts = (AuthService.instance.currentUser?.bookMarks)!
    if posts.count != 0 {
      setupPostGrid()
    } else {
      noContentsViewForAll = NoContentsView()
      noContentsViewForAll.guideTitleLabel.text = LS("saved")
      noContentsViewForAll.guideDescLabel.text = LS("saved_guide")
      noContentsViewForAll.addContentButton.isHidden = true
      self.firstTabView.addSubview(noContentsViewForAll)
      noContentsViewForAll.snp.makeConstraints { (make) in
        make.size.equalTo(self.firstTabView)
        make.center.equalTo(self.firstTabView)
      }
    }

    noContentsViewForCollection = NoContentsView()
    noContentsViewForCollection.guideTitleLabel.text = LS("saved_collection")
    noContentsViewForCollection.guideDescLabel.text = LS("saved_collection_guide")
    self.secondTabView.addSubview(noContentsViewForCollection)
    noContentsViewForCollection.snp.makeConstraints { (make) in
      make.size.equalTo(self.secondTabView)
      make.center.equalTo(self.secondTabView)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.posts = (AuthService.instance.currentUser?.bookMarks)!
    postGridCollectionView.reloadData()
  }

  func setupPostGrid() {
    if postGridCollectionView.superview == nil {
      firstTabView.addSubview(postGridCollectionView)
      postGridCollectionView.snp.makeConstraints { (make) in
        make.edges.equalTo(firstTabView)
      }
      postGridCollectionView.dataSource = self
      postGridCollectionView.delegate = self
      postGridCollectionView.isScrollEnabled = false
    }

    postGridCollectionView.isHidden = false
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
}

extension SavedViewController: UICollectionViewDataSource {
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

extension SavedViewController: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let postArray = [self.posts[indexPath.row]]
    let postVC = PostViewController(postArray)
    self.navigationController?.pushViewController(postVC, animated: true)
  }
}
