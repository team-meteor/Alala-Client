//
//  PhotoAlbum.swift
//  Alala
//
//  Created by junwoo on 2017. 7. 14..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import Foundation
import Photos

final class PhotoAlbum {

  static let sharedInstance = PhotoAlbum()

  var allPhotos: PHFetchResult<PHAsset>!
  var smartAlbums: PHFetchResult<PHAssetCollection>!
  var smartAlbumsArr = [PHAssetCollection]()
  var userCollections: PHFetchResult<PHCollection>!
  var userAlbumsArr = [PHAssetCollection]()
  let photosLimit: Int = 500
  var assetCollection: PHAssetCollection?
  var fetchResult: PHFetchResult<PHAsset>?

  func getLimitedPhotos() {

    let sortOptions = PHFetchOptions()
    sortOptions.fetchLimit = photosLimit
    sortOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

    allPhotos = PHAsset.fetchAssets(with: sortOptions)
    print("getLimitedPhotos")
  }

  func getAllPhotos() {
    print("get")
    let AllOptions = PHFetchOptions()
    AllOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    allPhotos = PHAsset.fetchAssets(with: AllOptions)
    fetchResult = allPhotos

    NotificationCenter.default.post(name: Notification.Name("fetchAllPhotoAlbum"), object: nil)
  }

  func getSmartUserAlbums() {
    smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
    var smartArr = [PHAssetCollection]()
    smartAlbums.enumerateObjects({ (object, _, _) -> Void in
      let collection = object
      let smartAlbum: PHFetchResult = PHAsset.fetchAssets(in: collection, options: nil)
      if smartAlbum.count > 0 {
        smartArr.append(collection)
      }

    })
    smartAlbumsArr = smartArr

    userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
    var userArr = [PHAssetCollection]()
    userCollections.enumerateObjects({ (object, _, _) -> Void in
      guard let collection = object as? PHAssetCollection else { return }
      let userAlbum: PHFetchResult = PHAsset.fetchAssets(in: collection, options: nil)
      if userAlbum.count > 0 {
        userArr.append(collection)
      }
    })
    userAlbumsArr = userArr
    NotificationCenter.default.post(name: Notification.Name("fetchSmartUserAlbums"), object: nil)
    print("getSmartUserAlbums")
  }

  func getSmartFetchResult(index: Int) {
    let AllOptions = PHFetchOptions()
    AllOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    let collection: PHCollection
    collection = smartAlbumsArr[index]
    guard let assetCollection = collection as? PHAssetCollection
      else { fatalError("expected asset collection") }

    self.assetCollection = assetCollection
    self.fetchResult = PHAsset.fetchAssets(in: assetCollection, options: AllOptions)
  }

  func getUserFetchResult(index: Int) {
    let AllOptions = PHFetchOptions()
    AllOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    let collection: PHCollection
    collection = userAlbumsArr[index]
    guard let assetCollection = collection as? PHAssetCollection
      else { fatalError("expected asset collection") }

    self.assetCollection = assetCollection
    self.fetchResult = PHAsset.fetchAssets(in: assetCollection, options: AllOptions)
  }
}
