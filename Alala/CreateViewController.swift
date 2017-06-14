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
    
    fileprivate let scrollView = UIScrollView().then {
        $0.alwaysBounceHorizontal = true
        $0.alwaysBounceVertical = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.maximumZoomScale = 3
    }
    
    fileprivate let imageView = UIImageView()
    
    var fetchResult: PHFetchResult<PHAsset>!
    let tileCellSpacing = CGFloat(3)
    let imageManager = PHCachingImageManager()
    
    fileprivate let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .white
        $0.alwaysBounceVertical = true
        $0.register(TileCell.self, forCellWithReuseIdentifier: "tileCell")
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
        
        print("init")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        scrollView.delegate = self
        
        self.scrollView.addSubview(self.imageView)
        self.view.addSubview(self.scrollView)
        self.view.addSubview(self.collectionView)
        
        self.scrollView.snp.makeConstraints { make in
            make.left.right.equalTo(self.view)
            make.height.equalTo(self.view.bounds.width)
        }
        
        self.collectionView.snp.makeConstraints { make in
            make.left.bottom.right.equalTo(self.view)
            make.top.equalTo(self.scrollView.snp.bottom)
        }
        
        fetchAllPhotos()
        let firstAsset = fetchResult.object(at: 0)
        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: 600 * scale, height: 600 * scale)
        imageManager.requestImage(for: firstAsset, targetSize: targetSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            let imageWidth = image!.size.width
            let imageHeight = image!.size.height
            if imageWidth > imageHeight {
                self.scrollView.contentSize.height = self.scrollView.frame.height
                self.scrollView.contentSize.width = imageWidth * self.scrollView.frame.height / imageHeight
            } else if imageWidth < imageHeight {
                self.scrollView.contentSize.width = self.scrollView.frame.width
                self.scrollView.contentSize.height = imageHeight * self.scrollView.frame.width / imageWidth
            } else {
                self.scrollView.contentSize.width = self.scrollView.frame.width * 1.2
                self.scrollView.contentSize.height = self.scrollView.frame.height * 1.2
            }
            self.imageView.frame.size = self.scrollView.contentSize
            self.imageView.center.x = UIScreen.main.bounds.size.width / 2
            self.imageView.center.y = self.scrollView.center.y
            self.imageView.image = image
        })
        print("viewdid")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.navigationController!.navigationBar.snp.bottom)
        }
        print("layout")
    }

    func fetchAllPhotos() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
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
        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: 600 * scale, height: 600 * scale)
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
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
        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: 600 * scale, height: 600 * scale)
        
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            self.imageView.image = image
        })
    }
}

extension CreateViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
