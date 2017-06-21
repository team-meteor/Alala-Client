//
//  PhotoLibraryViewController.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 21..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit
import Photos

class PhotoLibraryViewController: UIViewController {
  enum Section: Int {
    case allPhotos = 0
    case smartAlbums
    case userCollections

    static let count = 3
  }
  enum CellIdentifier: String {
    case allPhotos, collection
  }
  var allPhotos: PHFetchResult<PHAsset>!
  var smartAlbums: PHFetchResult<PHAssetCollection>!
  var userCollections: PHFetchResult<PHCollection>!
  let sectionLocalizedTitles = ["", NSLocalizedString("Smart Albums", comment: ""), NSLocalizedString("Albums", comment: "")]
  
  fileprivate let tableView = UITableView().then {
    $0.isScrollEnabled = true
    $0.register(GridViewCell.self, forCellReuseIdentifier: CellIdentifier.allPhotos.rawValue)
    $0.register(GridViewCell.self, forCellReuseIdentifier: CellIdentifier.collection.rawValue)
  }
  override func viewDidLoad() {
    super.viewDidLoad()

    let allPhotosOptions = PHFetchOptions()
    allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
    smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
    userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)

    self.view.addSubview(self.tableView)
    self.tableView.delegate = self
    self.tableView.dataSource = self

    self.tableView.snp.makeConstraints { make in
      make.edges.equalTo(self.view)
      make.width.height.equalTo(self.view)
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
  }

}

extension PhotoLibraryViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }
  
//  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    switch SegueIdentifier(rawValue: segue.identifier!)! {
//    case .showAllPhotos:
//      destination.fetchResult = allPhotos
//      
//    case .showCollection:
//      
//      let collection: PHCollection
//      switch Section(rawValue: indexPath.section)! {
//      case .smartAlbums:
//        collection = smartAlbums.object(at: indexPath.row)
//      case .userCollections:
//        collection = userCollections.object(at: indexPath.row)
//      default: return // not reached; all photos section already handled by other segue
//      }
//      
//      // configure the view controller with the asset collection
//      guard let assetCollection = collection as? PHAssetCollection
//        else { fatalError("expected asset collection") }
//      destination.fetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
//      destination.assetCollection = assetCollection
//    }
//    self.dismiss(animated: true, completion: nil)
//  }
}

extension PhotoLibraryViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return Section.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch Section(rawValue: section)! {
    case .allPhotos: return 1
    case .smartAlbums: return smartAlbums.count
    case .userCollections: return userCollections.count
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch Section(rawValue: indexPath.section)! {
    case .allPhotos:
      let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.allPhotos.rawValue, for: indexPath)
      cell.textLabel!.text = NSLocalizedString("All Photos", comment: "")
      return cell

    case .smartAlbums:
      let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.collection.rawValue, for: indexPath)
      let collection = smartAlbums.object(at: indexPath.row)
      cell.textLabel!.text = collection.localizedTitle
      return cell

    case .userCollections:
      let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.collection.rawValue, for: indexPath)
      let collection = userCollections.object(at: indexPath.row)
      cell.textLabel!.text = collection.localizedTitle
      return cell
    }
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sectionLocalizedTitles[section]
  }
}
