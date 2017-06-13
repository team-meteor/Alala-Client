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
    
    fileprivate let imageView = UIImageView().then {
        $0.backgroundColor = UIColor.yellow
    }
    
    var fetchResult: PHFetchResult<PHAsset>!
    let tileCellSpacing = CGFloat(3)
    let imageManager = PHCachingImageManager()
    
    fileprivate let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .white
        $0.alwaysBounceVertical = true
        $0.register(TileCell.self, forCellWithReuseIdentifier: "tileCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.view.addSubview(self.imageView)
        self.view.addSubview(self.collectionView)
        
        //상대적 위치 선정
        self.imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(self.collectionView.snp.top)
        }
        
        self.collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.imageView.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
        
        fetchAllPhotos()
        
        //가장 최근 사진 프리뷰
        let firstAsset = fetchResult.object(at: 0)
        imageManager.requestImage(for: firstAsset, targetSize: CGSize(width: 640, height: 640), contentMode: .aspectFit, options: nil, resultHandler: { image, _ in
            self.imageView.image = image
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.initializeContentSizeIfNeeded()
    }
    
    func initializeContentSizeIfNeeded() {
        imageView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height/2)
        collectionView.frame = CGRect(x: 0, y: self.view.bounds.midY, width: self.view.bounds.width, height: self.view.bounds.height/2)
    }
    
    func fetchAllPhotos() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        //cancle 버튼 생성
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonDidTap)
        )
        
        //done 버튼 생성
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneButtonDidTap)
        )
        
        self.automaticallyAdjustsScrollViewInsets = false
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cancelButtonDidTap() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidTap() {
        
    }
}

extension CreateViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tileCell", for: indexPath) as! TileCell
        let asset = fetchResult.object(at: indexPath.item)
        
        cell.representedAssetIdentifier = asset.localIdentifier
        
        //메타데이터를 이미지로 변환
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 640, height: 640), contentMode: .aspectFit, options: nil, resultHandler: { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.configure(photo: image!)
            }
        })
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
}

extension CreateViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.frame.width
        let cellWidth = round((collectionViewWidth - 2 * tileCellSpacing) / 3)
        return TileCell.size(width: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return tileCellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return tileCellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = fetchResult.object(at: indexPath.item)
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 640, height: 640), contentMode: .aspectFit, options: nil, resultHandler: { image, _ in
            self.imageView.image = image
        })
    }
}
