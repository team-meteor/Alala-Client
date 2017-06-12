//
//  CreateViewController.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import Photos

class CreateViewController: UIViewController {
    
    var allPhotos: PHFetchResult<PHAsset>!
    
    let imageManager = PHCachingImageManager()
    
    
    //collectionview 인스턴스 생성
    fileprivate let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .white
        $0.alwaysBounceVertical = true
        $0.register(CameraCell.self, forCellWithReuseIdentifier: "cameraCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        //뷰에 올리고 크기설정
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        fetchAllPhotos()
        
    }
    
    func fetchAllPhotos() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        
        //collectionView.reloadData()
    }
    
    
}

extension CreateViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cameraCell", for: indexPath) as! CameraCell
        let asset = allPhotos.object(at: indexPath.item)
        cell.restorationIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            if cell.restorationIdentifier == asset.localIdentifier {
                cell.configure(photo: image!)
            }
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos.count
    }
}

extension CreateViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.frame.width
        let cellWidth = round((collectionViewWidth - 2 * CGFloat(3)) / 3)
        return CameraCell.size(width: cellWidth)
    }
}

