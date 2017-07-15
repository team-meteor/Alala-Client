//
//  TableViewWrapperController.swift
//  Alala
//
//  Created by junwoo on 2017. 7. 14..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit
import Photos

class TableViewWrapperController: UIViewController {
  var photoAlbum = PhotoAlbum.sharedInstance
  let initialRequestOptions = PHImageRequestOptions().then {
    $0.isSynchronous = true
    $0.resizeMode = .fast
    $0.deliveryMode = .fastFormat
  }
  var allPhotos: PHFetchResult<PHAsset>!
  var smartAlbums: PHFetchResult<PHAssetCollection>!
  var userCollections: PHFetchResult<PHCollection>!
  var smartAlbumsFetchResult: PHFetchResult<PHAsset>!
  var smartAlbumsArr = [PHAssetCollection]()
  var userCollectionsFetchResult: PHFetchResult<PHAsset>!
  var userAlbumsArr = [PHAssetCollection]()
  var assetCollection: PHAssetCollection?
  let imageManager = PHCachingImageManager()
  enum Section: Int {
    case allPhotos = 0
    case smartAlbums
    case userCollections

    static let count = 3
  }
  let sectionLocalizedTitles = ["", NSLocalizedString("Smart Albums", comment: ""), NSLocalizedString("Albums", comment: "")]

  let tableView = UITableView().then {
    $0.isScrollEnabled = true
    $0.register(GridViewCell.self, forCellReuseIdentifier: CellIdentifier.allPhotos.rawValue)
    $0.register(GridViewCell.self, forCellReuseIdentifier: CellIdentifier.collection.rawValue)
  }

  enum CellIdentifier: String {
    case allPhotos, collection
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    self.modalPresentationStyle = .overCurrentContext
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.allPhotos = photoAlbum.allPhotos
    self.smartAlbumsArr = photoAlbum.smartAlbumsArr
    self.userAlbumsArr = photoAlbum.userAlbumsArr

    self.tableView.delegate = self
    self.tableView.dataSource = self
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

//    self.view.superview?.snp.makeConstraints { make in
//      make.width.equalTo(UIScreen.main.bounds.width)
//      make.height.equalTo(UIScreen.main.bounds.height)
//      make.centerX.equalTo(UIScreen.main.bounds.width/2)
//      make.centerY.equalTo(UIScreen.main.bounds.height/2 + 44)
//    }
    self.view.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.view.addSubview(tableView)
    self.tableView.snp.makeConstraints { make in
      make.edges.equalTo(self.view)
      make.width.height.equalTo(self.view)
    }
  }

}

extension TableViewWrapperController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {

    return Section.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    switch Section(rawValue: section)! {
    case .allPhotos: return 1
    case .smartAlbums: return smartAlbumsArr.count
    case .userCollections: return userAlbumsArr.count
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let AllOptions = PHFetchOptions()
    AllOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

    switch Section(rawValue: indexPath.section)! {
    case .allPhotos:
      let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.allPhotos.rawValue, for: indexPath)

      if allPhotos.count != 0 {
        cell.textLabel!.text = NSLocalizedString("All Photos", comment: "")
        let asset = allPhotos.object(at: 0)
        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: 100 * scale, height: 100 * scale)
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: nil, resultHandler: { image, _ in
          cell.imageView?.image = image

        })
        return cell
      } else {
        return cell
      }

    case .smartAlbums:

      let collection = smartAlbumsArr[indexPath.row]
      self.smartAlbumsFetchResult = PHAsset.fetchAssets(in: collection, options: AllOptions)

      let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.collection.rawValue, for: indexPath)
      cell.textLabel!.text = collection.localizedTitle

      if smartAlbumsFetchResult.count != 0 {
        let asset = smartAlbumsFetchResult.object(at: 0)
        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: 100 * scale, height: 100 * scale)
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: initialRequestOptions, resultHandler: { image, _ in
          cell.imageView?.image = image

        })
        return cell
      } else {
        return cell
      }

    case .userCollections:
      let collection = userAlbumsArr[indexPath.row]
      let assetCollection = collection
      self.userCollectionsFetchResult = PHAsset.fetchAssets(in: assetCollection, options: AllOptions)

      let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.collection.rawValue, for: indexPath)
      cell.textLabel!.text = collection.localizedTitle

      if userCollectionsFetchResult.count != 0 {
        let asset = userCollectionsFetchResult.object(at: 0)
        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: 100 * scale, height: 100 * scale)
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: initialRequestOptions, resultHandler: { image, _ in
          cell.imageView?.image = image

        })
        return cell
      } else {
        return cell
      }

    }
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sectionLocalizedTitles[section]
  }
}

extension TableViewWrapperController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let AllOptions = PHFetchOptions()
    AllOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

    switch Section(rawValue: indexPath.section)! {

    case .allPhotos:

      photoAlbum.getAllPhotos()

    case .smartAlbums:

      photoAlbum.getSmartFetchResult(index: indexPath.item)

    case .userCollections:

      photoAlbum.getUserFetchResult(index: indexPath.item)
    }

    NotificationCenter.default.post(name: Notification.Name("tableViewOffMode"), object: nil)
  }
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

    return 100
  }
}
